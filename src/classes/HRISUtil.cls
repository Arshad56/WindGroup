public class HRISUtil {

    public static final string HRIS_Requisite_Const = 'Requisite';
    public static final string HRIS_Hire_Const = 'Hire';
    public static final string HRIS_Job_Change = 'Job Change';
    public static final string HRIS_Onboard = 'On-boarding';
    public static final string HRIS_Offboard = 'Off-boarding';
    public static final string HRIS_Corporate_Onboarding = 'Corporate - Onboarding';
    public static final string HRIS_Corporate_Offboarding = 'Corporate - Offboarding';
    public static final string HRIS_Approval_In_Progress = 'In-Progress';
    public static final string HRIS_Approval_Draft = 'Draft';
    public static final string HRIS_Approval_Pending = 'Pending';
    public static final string HRIS_Approval_Approved = 'Approved';

    public static List <Job_Description__c> getJobDescriptionList(){
        
        List <Job_Description__c> jdList = new List <Job_Description__c>();
        
        jdList = [SELECT Job_Description__c, Job_Level__c, Job_Requirements__c, English__c,Cantonese__c,Other_languages__c,Computer_Skills__c, Position__c, Cultural_Competency__c,Customer_Focus__c,Ethics_and_Values_Outcome__c,Execution__c, Generating_Talent_Org_Capability__c,
              Innovation_Change__c, Innovation_and_Business_Acumen__c, Leadership__c, Managing_Execution__c, Self_Management__c,
              Team_Work__c FROM Job_Description__c];
        
        return jdList;
    }
    
    public static List <Job_Description__c> getJobDescriptionListByProperty(Id propertyId){
        
        List <Job_Description__c> jdList = new List <Job_Description__c>();
        
        jdList = [SELECT Job_Description__c, Job_Level__c, Job_Requirements__c, English__c,Cantonese__c,Other_languages__c,Computer_Skills__c, Position__c, Cultural_Competency__c,Customer_Focus__c,Ethics_and_Values_Outcome__c,Execution__c, Generating_Talent_Org_Capability__c,
              Innovation_Change__c, Innovation_and_Business_Acumen__c, Leadership__c, Managing_Execution__c, Self_Management__c,
              Team_Work__c FROM Job_Description__c where Property__c =: propertyId];
        
        return jdList;
    }
    
    public static Job_Description__c getJobDescriptionByJobId(Id jobDescId){
        
        Job_Description__c jd = null;
        
        jd = [SELECT Job_Description__c, Job_Level__c, Job_Requirements__c, English__c,Cantonese__c,Other_languages__c,Computer_Skills__c, Position__c, Cultural_Competency__c,Customer_Focus__c,Ethics_and_Values_Outcome__c,Execution__c, Generating_Talent_Org_Capability__c,
              Innovation_Change__c, Innovation_and_Business_Acumen__c, Leadership__c, Managing_Execution__c, Self_Management__c,
              Team_Work__c FROM Job_Description__c WHERE Id = :jobDescId];
        
        return jd;
    }
    
    public static List <Headcount_Budget__c> getHeadcountBudgetList(String property, String division, String department){
        
        List <Headcount_Budget__c> hbList = new List<Headcount_Budget__c>();
        
        hbList = [Select Id, Available_Headcount__c, approved_headcount__c, current_headcount__c, department__c, division__c, Property__c from Headcount_Budget__c 
                  where property__c =:property and division__c = :division and department__c = :department]; 
        
        return hbList;
    }

    public static Id getPropertyIdbyAccountId (Id accountId){
        Id propId = [Select Id from Property__c where ParentCompany__c = :accountId].Id;
        return propId; 
    }
    
    public static Id getAccountIdbyProperty(Id propId){
        Id acctId = [Select ParentCompany__c from Property__c where Id = :propId].ParentCompany__c;
        return acctId; 
    }
    
    public static String getCompanyHotelName(Id propId){
        String shortcode = [Select short_code__c from Property__c where Id = :propId].short_code__c;
        return shortcode; 
    }
    
    public static Contact getEmployeeContactbyConId (Id conId){
        
        Contact con = [Select Currency_of_Salary__c, AccountId, FirstName, Monthly_Base_Salary__c, LastName, Position__c, Division__c, Job_level__c, Department, Employee_No__c, Date_Join__c from Contact where Id = :conId];
        return con;
    }
    
    public static Requisition__c getRequisitebyId (Id reqId){
        
        Requisition__c req = [Select Current_Headcount__c, Approved_Headcount__c, Position__c, Division__c, Department__c, Job_Level__c from Requisition__c where Id = :reqId];
        return req;
    }
    
    public static List <DOA__c> getDOAListByPropertyAndType (Id propId, String type){
        
        List <DOA__c> doalist = new List <DOA__c> ();
        doalist = [Select Approver__c, Department__c, Division__c, Email__c, Name__c, Action__c, Position__c, Title__c, Sequence__c  from DOA__c where Property__c = :propId and Process_Type__c = :type ORDER BY Sequence__c Desc];
        return doalist;
    }
    
    public static List <DOA_History__c> getDOAHistoryList (Id requisiteId, Id hireId){
        
        List <DOA_History__c> doalist = new List <DOA_History__c> ();
        
        if(requisiteId != null){
            doalist = [Select Approve_Reject_Date__c , Department__c, Division__c, Email__c, Name__c, Action__c, Position__c, Title__c, Comment__c, Status__c, Sequence__c  from DOA_History__c 
            where Requisition__c = :requisiteId ORDER BY Sequence__c Desc]; 
        }else if(hireId != null){
            doalist = [Select Approve_Reject_Date__c , Department__c, Division__c, Email__c, Name__c, Action__c, Position__c, Title__c, Comment__c, Status__c, Sequence__c  from DOA_History__c 
            where Job_Change__c = :hireId ORDER BY Sequence__c Desc]; 
        }
        return doalist;
    }
    
    public static List <DOA_History__c> setDOAHistoryList (List <DOA__c> doaList){
        List <DOA_History__c> doaHistoryList = new List <DOA_History__c> ();
        
         for(DOA__c doa: doaList){
             DOA_History__c doaHistory = new DOA_History__c();
             
             doaHistory.Action__c = doa.Action__c;
             doaHistory.Comment__c = '';
             doaHistory.Department__c = doa.Department__c;
             doaHistory.Email__c = doa.Email__c;
             doaHistory.Name__c = doa.Name__c;
             doaHistory.Position__c = doa.Position__c;
             doaHistory.Sequence__c = doa.Sequence__c;
             doaHistory.Status__c = HRISUtil.HRIS_Approval_Pending;
             doaHistory.Approve_Reject_Date__c = null;
             doaHistoryList.add(doaHistory);
        }
        
        return doaHistoryList;
    }
    
    public static List <DOA_History__c> getDOAHistoryList (Id requisiteId, Id hireId, Id propId, String type){
        List <DOA_History__c> doaHistoryList = new List <DOA_History__c> ();
        
        if(requisiteId != null)
            doaHistoryList = HRISUtil.getDOAHistoryList(requisiteId, null);
        else if(hireId != null)
            doaHistoryList = HRISUtil.getDOAHistoryList(null, hireId);
        
        if(doaHistoryList.isEmpty()){
            List<DOA__c> doaList = new List<DOA__c>(); 
            
            if(type == HRISUtil.HRIS_Requisite_Const)
                doaList = HRISUtil.getDOAListByPropertyAndType(propId, HRISUtil.HRIS_Requisite_Const);
            else if(type == HRISUtil.HRIS_Hire_Const)
                doaList = HRISUtil.getDOAListByPropertyAndType(propId, HRISUtil.HRIS_Hire_Const);
            else if(type == HRISUtil.HRIS_Job_Change)
                doaList = HRISUtil.getDOAListByPropertyAndType(propId, HRISUtil.HRIS_Job_Change);
            doaHistoryList = HRISUtil.setDOAHistoryList(doaList);
           
        }
        
        return doaHistoryList;
    }
    
    
    public static List <Master_Checklist_Item__c> getMasterChecklistItembyPropertyAndType(Id propertyId, String checklistType){
        
        List <Master_Checklist_Item__c> mciList = new List <Master_Checklist_Item__c>();

        List<Master_Checklist__c> masterChecklistId = [select Id from Master_Checklist__c where Master_Checklist__c.Property__c =: propertyId and Master_Checklist__c.Type__c =: checklistType];
        
        if(!masterChecklistId.isEmpty()){
             mciList = [SELECT Assign_To_Team__c, Attachment__c, Completed__c, Department__c,Description__c,Master_Checklist__c,S_N__c, Status__c, Team_In_Charge__c FROM Master_Checklist_Item__c 
                       where Master_Checklist__c =: masterChecklistId.get(0).Id and status__c = 'Active' order by S_N__c asc];
        }
        return mciList;
    }
    
    public static List <Master_Checklist_Item__c> getMasterChecklistItembyType(String checklistType){
        
        List <Master_Checklist_Item__c> mciList = new List <Master_Checklist_Item__c>();

        List<Master_Checklist__c> masterChecklistId = [select Id from Master_Checklist__c where Master_Checklist__c.Type__c =: checklistType];
        
        if(!masterChecklistId.isEmpty()){
             mciList = [SELECT Assign_To_Team__c, Attachment__c, Completed__c, Department__c,Description__c,Master_Checklist__c,S_N__c, Status__c, Team_In_Charge__c FROM Master_Checklist_Item__c 
                       where Master_Checklist__c =: masterChecklistId.get(0).Id and status__c = 'Active' order by S_N__c asc];
        }
        return mciList;
    }
    
   public static List <Employee_Checklist__c> getHireChecklistbyId(Id jobChangeId){
        
        List <Employee_Checklist__c> hireCheckList = new List <Employee_Checklist__c>();
        
        if(jobChangeId != null){
            hireCheckList = [SELECT Assign_To_Team__c, Attachment__c, Completed__c, Department__c,Description__c,S_N__c, Team_In_Charge__c FROM Employee_Checklist__c
                             where Job_Change__c =: jobChangeId order by S_N__c asc];
        }
        
        return hireCheckList;
    }
    
    public static PageReference getMyNewPage (String page, Id pageId){
        PageReference MyNewPage = new PageReference('/apex/'+ page+ '?Id='+pageId);          
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    public static String getPropertyRecordType(Id propId){
        
        List <Property__c> prop = [Select RecordTypeId from Property__c where id =: propId];
        return Schema.SObjectType.Property__c.getRecordTypeInfosById().get(prop.get(0).RecordTypeId).getname();
    }

}