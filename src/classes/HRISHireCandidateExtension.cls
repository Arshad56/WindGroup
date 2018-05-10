public class HRISHireCandidateExtension {
    
    public Personnel_Action__c pa {get;set;}
    public Contact con {get;set;}
    public Requisition__c req {get;set;} 
    public String headerValue {get;set;}
    public List<Personnel_Action__c> paList {get;set;}
    public List<DOA_History__c> doaHistoryList {get;set;}
    public List<Camparative_Salary__c> csList {get;set;}
    public Integer rowIndex {get;set;}
    public Integer rowNumber {get;set;}
    
    public HRISHireCandidateExtension (ApexPages.standardController std) { 
        this.pa = (Personnel_Action__c) std.getRecord();
        this.pa.Property__c = 'a1O7F000000MWxk';
		rowNumber = 0;
        
        if(this.pa.Id != null)
        	csList = [Select Date_Join__c , Job_Level__c, department__c, contact__c, position__c, currency__c, amount__c, net_gross__c from Camparative_Salary__c where job_change__c = : this.pa.Id];
        if(ApexPages.currentpage().getParameters().get('propertyId') != null){
            this.pa.Property__c = ApexPages.currentpage().getParameters().get('propertyId');
            this.pa.Checklist_Type__c = HRISUtil.HRIS_Onboard;
            this.pa.RecordTypeId = Schema.SObjectType.Personnel_Action__c.getRecordTypeInfosByName().get(HRISUtil.getPropertyRecordType(this.pa.Property__c)).getRecordTypeId();
        	
            if(this.pa.Approval_Status__c == null)
            	this.pa.Approval_Status__c = HRISUtil.HRIS_Approval_Draft;
        }

        List <DOA_History__c> newdoaHistoryList =  HRISUtil.getDOAHistoryList(null, this.pa.Id);
        
        if(newdoaHistoryList != null &&!newdoaHistoryList.isEmpty())
            doaHistoryList = newdoaHistoryList;
    }
    
    public void search(){
        
        palist = new List <Personnel_Action__c> ();
        headerValue = '';
        
        String query = 'Select Id, Name, Property__c, Requisition_No__c, Date_of_Join__c, Employee__c, Employee_No__c, Approval_Status__c, Division__c, Department__c, Position__c, Movement_Type__c from Personnel_Action__c where property__c =\''+pa.Property__c+'\'';
        query = query + ' and Status__c !=\'Job Change\'';
        
        //if(pa.Requisition_No__c != null)
            //query = query + ' and Requisition_No__c=\''+pa.Requisition_No__c+'\'';
        if(pa.Employee__c != null)
            query = query + ' and Employee__c=\''+pa.Employee__c+'\'';
        
        List<Personnel_Action__c> newpalist = Database.query(query);
        
        if(newpalist.isEmpty())
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No employee record.'));
        else{
            headerValue = 'Employee No';
            palist = newpalist;
        }
        
    }
    
    public PageReference createHireCandidate(){
        
        if(pa.Property__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Property.'));
        } else {
            PageReference MyNewPage = new PageReference('/apex/HRISHireCandidate?propertyId='+pa.Property__c);          
            MyNewPage.setRedirect(true);
            return MyNewPage;
        }
        
        return null;
        
    }
    
    public void add(){

        Contact con  = HRISUtil.getEmployeeContactbyConId(this.pa.Comparative_Salary__c);
        
        if(con != null){
            
            if(csList == null)
                csList = new List <Camparative_Salary__c> ();
            
            Camparative_Salary__c cs = new Camparative_Salary__c();
            cs.contact__c = con.Id;
            cs.Date_Join__c = con.Date_Join__c;
            cs.division__c = con.division__c;
            cs.department__c = con.Department;
            cs.job_level__c = con.Job_Level__c;
            cs.position__c = con.Position__c;
            cs.currency__c = con.Currency_of_Salary__c;
            cs.amount__c = con.Monthly_Base_Salary__c;
            cs.net_gross__c = 'Gross';
            csList.add(cs);
            this.pa.Comparative_Salary__c = null;
        }
        
        
    }
    
    public void deleteRow(){
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        csList.remove(rowIndex);
        
        if(csList.isEmpty())
            csList = null;
    }
    
    public void setEmployeeInfo(){
        
        if(this.pa.Requisition_No__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Requisition No.'));
        else{
            
            if(this.pa.Employee__c != null){
                con = HRISUtil.getEmployeeContactbyConId(this.pa.Employee__c);
                this.pa.Date_of_Join__c = con.Date_Join__c;
                this.pa.First_Name__c = con.FirstName;
                this.pa.Last_Name__c = con.LastName;
            }
            
            if(this.pa.Requisition_No__c != null){
                req = HRISUtil.getRequisitebyId(this.pa.Requisition_No__c);
                this.pa.Position__c = req.Position__c;
                this.pa.Division__c = req.Division__c;
                this.pa.Department__c = req.Department__c;
                this.pa.Job_Level__c = req.Job_Level__c;
                this.pa.Current_Headcount__c = req.Current_Headcount__c;
                this.pa.Approved_Headcount__c = req.Approved_Headcount__c;
                
            }
        }  
    }
    
    public PageReference saveHire(){
        
        return upsertData(null);
    }
    
    public PageReference submitHire(){
        
        return upsertData('submit');
    }
    
    public PageReference cancelHire(){
        
        PageReference MyNewPage = new PageReference('/apex/HRISHireStep1');          
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    public PageReference createLOA(){

        PageReference MyNewPage = new PageReference('/apex/HRISLetterOfAcceptance?id='+pa.Id);          
        MyNewPage.setRedirect(true);
        return MyNewPage;  
    }
    
    private PageReference upsertData(String type){
        
        if(pa.Requisition_No__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Requisition No.'));
        else if(pa.First_Name__c == null || pa.Last_Name__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Name.'));      
        else{

            pa.Comparative_Salary__c = null;
            upsert this.pa;
            
            if(type == 'submit'){
                //pa.Approval_Status__c = HRISUtil.HRIS_Approval_In_Progress;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted Hire for approval.');
                req.setObjectId(pa.Id);
                Approval.ProcessResult result = Approval.process(req);
            }
            
            if(csList != null){
                for(Camparative_Salary__c cs : csList){
                    cs.job_change__c = this.pa.Id;
                }
                
                upsert csList;
            }
            
            if(doaHistoryList == null)
                doaHistoryList = HRISUtil.getDOAHistoryList(null, this.pa.Id, this.pa.property__c, HRISUtil.HRIS_Hire_Const);
            
            if(!doaHistoryList.isEmpty()){
                for(DOA_History__c doaH : doaHistoryList){
                    doaH.Job_Change__c = this.pa.Id;
                } 
                upsert doaHistoryList;
            }
            
            return HRISUtil.getMyNewPage('HRISHireCandidate', this.pa.Id);
        }
        
        return null;
        
    }
}