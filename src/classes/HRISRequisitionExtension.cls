public class HRISRequisitionExtension {
    
    public Requisition__c requisition {get;set;}
    public boolean error {get;set;}
    public String headerValue {get;set;}
    public Id propId {get;set;}
    public List<Requisition__c> requisitionList {get;set;}
    public List<DOA_History__c> doaHistoryList {get;set;}

    public HRISRequisitionExtension (ApexPages.standardController std) { 
        this.requisition = (Requisition__c) std.getRecord();
        this.requisition.Property__c = 'a1O7F000000MWxk';
        if(ApexPages.currentpage().getParameters().get('propertyId') != null){
            this.requisition.Property__c = ApexPages.currentpage().getParameters().get('propertyId');
            this.requisition.RecordTypeId = Schema.SObjectType.Requisition__c.getRecordTypeInfosByName().get(HRISUtil.getPropertyRecordType(this.requisition.Property__c)).getRecordTypeId();
        	if(this.requisition.Approval_Status__c == null)
            	this.requisition.Approval_Status__c = HRISUtil.HRIS_Approval_Draft;
        	if(this.requisition.Status__c == null)
            	this.requisition.Status__c  = HRISUtil.HRIS_Requisite_Const;
        }
            
        List <DOA_History__c> newdoaHistoryList =  HRISUtil.getDOAHistoryList(this.requisition.Id, null);
        
        if(newdoaHistoryList != null &&!newdoaHistoryList.isEmpty())
            doaHistoryList = newdoaHistoryList;
    }
    
     public void setRequisiteInfo(){
         
         List <Headcount_Budget__c> hbList = HRISUtil.getHeadcountBudgetList(this.requisition.Property__c, this.requisition.Division__c, this.requisition.Department__c); 
         if(!hbList.isEmpty()){
             this.requisition.approved_headcount__c = hbList.get(0).approved_headcount__c;
             this.requisition.current_headcount__c = hbList.get(0).current_headcount__c;
             this.requisition.headcount_variance__c = hbList.get(0).Available_Headcount__c;
         }else{
             this.requisition.approved_headcount__c = 0;
             this.requisition.current_headcount__c = 0;
             this.requisition.headcount_variance__c = 0;
         }
         
         Job_Description__c jobdes = HRISUtil.getJobDescriptionByJobId(this.requisition.Job_Description__c);
        
         if(jobdes != null){
            this.requisition.Position__c = jobdes.position__c;
            this.requisition.Job_Level__c = jobdes.Job_Level__c;
            this.requisition.Job_Info__c = jobdes.Job_Description__c;
            this.requisition.Job_Requirements__c = jobdes.Job_Requirements__c;
            this.requisition.English__c = jobdes.English__c;
            this.requisition.Cantonese__c = jobdes.Cantonese__c;
            this.requisition.Other_languages__c = jobdes.Other_languages__c;
            this.requisition.Computer_Skills__c = jobdes.Computer_Skills__c;
         }
    }
    
    public void search(){
       requisitionList = new List <Requisition__c> ();
       headerValue = '';
       String query = 'Select Id, Name, Division__c, Department__c, Position__c, Job_Level__c, Number_of_Employed__c, Approval_Status__c, Status__c from Requisition__c where property__c=\''+requisition.Property__c+'\'';

       if(requisition.Requisition_No_Lookup__c != null)
           query = query + ' and id=\''+requisition.Requisition_No_Lookup__c+'\'';
       if(requisition.Approval_Status__c != null)
           query = query + ' and Approval_Status__c=\''+requisition.Approval_Status__c+'\'';

       List<Requisition__c> reqList = Database.query(query);
       
       if(reqList.isEmpty())
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No requisition record.'));
       else{
           headerValue = 'Requisition No';
           requisitionList = reqList;
       }
   }
    
   public PageReference createRequisition(){
       
        if(requisition.Property__c == null){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Property.'));
        } else {
            PageReference MyNewPage = new PageReference('/apex/HRISRequisition?propertyId='+requisition.Property__c);          
            MyNewPage.setRedirect(true);
            return MyNewPage;
        }
        
        return null;
  
   }
   
   public PageReference saveReq(){
       
        return upsertData(null);
   }
   
   public PageReference submitReq(){
       
        return upsertData('submit');
  
   }
    
   public PageReference cancelReq(){
        PageReference MyNewPage = new PageReference('/apex/HRISRequisitionStep1');          
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
   private void sendEmail(Requisition__c req){
       
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
       String[] toAddresses = new String[] {'seowhooi.tan@shangri-la.com'};

       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setToAddresses(toAddresses);
       string body = '<p>Dear Approver,</p>'+
                     '<p>For your approval of Personnel Requisition No: SLFT-RC-201802-000040.</p>'+
                     '<p>Please see details below:</p>'+
                     '<p>&nbsp;</p>'+
                     '<table style="width: 522.2px;">'+
                     '<tbody>'+
                     '<tr>'+
                     '<td style="width: 230px;">Property</td>'+
                     '<td style="width: 286.2px;">'+ req.Property__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Division:</td>'+
                     '<td style="width: 286.2px;">'+ req.Division__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Department:</td>'+
                     '<td style="width: 286.2px;">'+ req.Department__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Requisite Headcount:</td>'+
                     '<td style="width: 286.2px;">'+ req.Number_of_Employed__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Current Headcount:</td>'+
                     '<td style="width: 286.2px;">'+ req.Current_Headcount__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Requisite Reason:</td>'+
                     '<td style="width: 286.2px;">'+ req.Reason_for_Requisition__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Position to be filled:</td>'+
                     '<td style="width: 286.2px;">'+ req.Position__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Employment Type:</td>'+
                     '<td style="width: 286.2px;">'+ req.Employment_Type__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Job Level:</td>'+
                     '<td style="width: 286.2px;">'+ req.Job_Level__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Requisite Date:</td>'+
                     '<td style="width: 286.2px;">'+ req.Effective_Start_Date__c +'</td>'+
                     '</tr>'+
                     '<tr>'+
                     '<td style="width: 230px;">Requested By:</td>'+
                     '<td style="width: 286.2px;">'+ req.Name +'</td>'+
                     '</tr>'+
                     '</tbody>'+
                     '</table>'+
                     '<p>&nbsp;</p>'+
                     '<table style="width: 234.2px; height: 22px;">'+
                     '<tbody>'+
                     '<tr>'+
                     '<td style="width: 104px;"><a href="https://cs72.lightning.force.com/one/one.app#/sObject/a1j5D000000EiAdQAK/view">Approve</a></td>'+
                     '<td style="width: 118.2px;"><a href="http://www.google.com">Reject</a></td>'+
                     '</tr>'+
                     '</tbody>'+
                     '</table>'+
                     '<p>&nbsp;</p>'+
                     '<p>Thanks, <br /> System Admin</p>'+
                     '<p>&nbsp;</p>';
       mail.setSubject('Requisite Approval Request: ' + req.Name);
       //mail.setTargetObjectId(con.Id); 
       //mail.setSaveAsActivity(true);
       mail.setHtmlBody(body); 
       mails.add(mail);
      
       Messaging.sendEmail(mails);
        
   }
    
   private PageReference upsertData(String type){
        
        if(this.requisition.Property__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Property.'));
        else if(this.requisition.Job_Description__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Job No.'));
        else if(this.requisition.Number_of_Employed__c == null || this.requisition.Number_of_Employed__c == 0)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Requisite Headcount.'));
        else if(this.requisition.Number_of_Employed__c > this.requisition.headcount_variance__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Requisite headcount has exceeded approved headcount.'));
           
       } else{
            
           
           upsert this.requisition;
           if(type == 'submit'){
                //sendEmail(this.requisition);
                //this.requisition.Approval_Status__c = HRISUtil.HRIS_Approval_In_Progress;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted requisition for approval.');
                req.setObjectId(requisition.Id);
                Approval.ProcessResult result = Approval.process(req);
           }
               
            

            if(doaHistoryList == null)
            	doaHistoryList = HRISUtil.getDOAHistoryList(this.requisition.Id, null, this.requisition.property__c, HRISUtil.HRIS_Requisite_Const);
            
            if(!doaHistoryList.isEmpty()){
                for(DOA_History__c doaH : doaHistoryList){
                    doaH.Requisition__c = this.requisition.Id;
                } 
                upsert doaHistoryList;
            }
             
            return HRISUtil.getMyNewPage('HRISRequisition', requisition.Id);
        }

        return null;
        
    }
   
}