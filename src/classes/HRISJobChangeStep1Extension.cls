public class HRISJobChangeStep1Extension {
    
    public Personnel_Action__c pa {get;set;}
    public List<Personnel_Action__c> candidateList {get;set;}
    public List<DOA_History__c> doaHistoryList {get;set;}
    public String headerValue {get;set;} 
    
    public HRISJobChangeStep1Extension (ApexPages.standardController std) { 
        this.pa = (Personnel_Action__c) std.getRecord();
		this.pa.Property__c ='a1O7F000000MWxk';
        if(ApexPages.currentpage().getParameters().get('propertyId') != null){
            this.pa.Property__c = ApexPages.currentpage().getParameters().get('propertyId');
            this.pa.Status__c = 'Job Change';
            this.pa.RecordTypeId = Schema.SObjectType.Personnel_Action__c.getRecordTypeInfosByName().get(HRISUtil.getPropertyRecordType(this.pa.Property__c)).getRecordTypeId();
        
            if(this.pa.Approval_Status__c == null)
            	this.pa.Approval_Status__c = HRISUtil.HRIS_Approval_Draft;
        
        }

        List <DOA_History__c> newdoaHistoryList =  HRISUtil.getDOAHistoryList(null, this.pa.Id);
        
        if(newdoaHistoryList != null && !newdoaHistoryList.isEmpty())
            doaHistoryList = newdoaHistoryList; 
    }
    
    public void search(){
        
        headerValue = '';
        List<Personnel_Action__c> paEmployeeList = new List <Personnel_Action__c>(); 
        String query = 'Select Id, Name, Property__c, Requisition_No__c, Date_of_Join__c, Employee__c, Employee_No__c, Approval_Status__c, Division__c, Department__c, Position__c,Movement_Type__c  from Personnel_Action__c where property__c =\''+pa.Property__c+'\'';
        query = query + ' and Status__c =\'Job Change\' and Property__c =\'' + pa.Property__c + '\'';
        
        if(pa.Employee__c != null)
            query = query + ' and Employee__c=\''+pa.Employee__c+'\'';
        
        if(pa.Employee_No__c != null && !''.equals(pa.Employee_No__c))
            query = query + ' and Employee_No__c=\''+pa.Employee_No__c+'\'';
        
        paEmployeeList = Database.query(query);
        
        if(paEmployeeList.isEmpty())
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No employee record(s) is found.'));
        else{
            candidateList = paEmployeeList;
            headerValue = 'Employee Number';
        }
        
    }
    
    public void setEmployeeInfo(){
        Contact con = HRISUtil.getEmployeeContactbyConId(this.pa.Employee__c);
        this.pa.Position__c = con.Position__c;
        this.pa.Division__c = con.Division__c;
        this.pa.Department__c = con.Department;
        this.pa.Job_Level__c = con.Job_Level__c;
        this.pa.Date_of_Join__c = con.Date_Join__c;  
        this.pa.Salary__c = con.Monthly_Base_Salary__c;
        this.pa.Employee_No__c = con.Employee_No__c;
    }
    
    public PageReference createJobChange(){
        
        if(pa.Property__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Property.'));
        } else {
            PageReference MyNewPage = new PageReference('/apex/HRISJobChangeEmployee?propertyId='+pa.Property__c);          
            MyNewPage.setRedirect(true);
            return MyNewPage;
        }
        
        return null;
        
    }
    
    public PageReference saveJobChange(){
        
        return upsertData(null);
    }
    
    public PageReference submitJobChange(){
        
        return upsertData('submit');
        
    }
    
    public PageReference cancelJobChange(){
        
        PageReference MyNewPage = new PageReference('/apex/HRISJobChangeStep1');          
        MyNewPage.setRedirect(true);
        return MyNewPage;
        
    }
    
    private PageReference upsertData(String type){
        
        if(pa.Movement_Type__c == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter movement type.'));      
        else{

            
            if(this.pa.Movement_Type__c == 'Separation' || this.pa.Movement_Type__c == 'Transfer')
                this.pa.Checklist_Type__c = HRISUtil.HRIS_Offboard;
            upsert this.pa;
            
            if(type == 'submit'){
                //pa.Approval_Status__c = HRISUtil.HRIS_Approval_In_Progress;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted Job Change for approval.');
                req.setObjectId(pa.Id);
                Approval.ProcessResult result = Approval.process(req);
            
            }
            
            if(doaHistoryList == null)
                doaHistoryList = HRISUtil.getDOAHistoryList(null, this.pa.Id, this.pa.property__c, HRISUtil.HRIS_Job_Change);
            
            if(!doaHistoryList.isEmpty()){
                for(DOA_History__c doaH : doaHistoryList){
                    doaH.Job_Change__c = this.pa.Id;
                } 
                upsert doaHistoryList;
            }
            
            return HRISUtil.getMyNewPage('HRISJobChangeEmployee', this.pa.Id);
        }
        
        return null;
        
    }
    
}