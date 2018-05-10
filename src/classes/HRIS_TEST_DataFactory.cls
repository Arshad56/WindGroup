public class HRIS_TEST_DataFactory {
    
    public static Property__c getPropertyTestData(Id accId){
        Property__c prop = new Property__c();
        prop.Name = 'HRISTestProperty';
        prop.ParentCompany__c = accId;
        prop.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert prop;
        
        return prop;
    }
    
    public static Account getAccountTestData(){
        
        Account acc = new Account();
        acc.Name = 'HRISTestHotel';
        insert acc;

        return acc;
        
    }
    
    public static Contact getContactTestData(Id acctId){
      
        Contact con = new Contact();
        con.FirstName='HRIS';
        con.LastName ='Test';
        con.Region__c = 'Hong Kong';
        con.Email = 'hristest@shangri-la.com';
        con.Position__c = 'Corporate Executive';
        con.AccountId = acctId;
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
        insert con;
        
        return con;
    }
    
    public static Headcount_Budget__c getHeadcountBudgetTestData(Id propId, String department, String division){
        Headcount_Budget__c headB = new Headcount_Budget__c();
        headB.Property__c = propId;
        headB.Department__c = department;
        headB.Division__c = division;
        headB.current_headcount__c = 2;
        headB.RecordTypeId = Schema.SObjectType.Headcount_Budget__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert headB;
        
        Headcount_Budget_Detail__c hbd = new Headcount_Budget_Detail__c();
        hbd.Headcount_Budget__c = headB.Id;
        hbd.Status__c = 'Default';
        hbd.Approved_Headcount__c = 10;
        insert hbd;

        return headB;
       
    }

    public static Job_Description__c getJobDescriptionTestData(Id propId){
        
        Job_Description__c jd = new Job_Description__c();
        jd.Cantonese__c='Fluent';
        jd.Computer_Skills__c='Microsoft';
        jd.Job_Level__c='A';
        jd.Position__c='Corporate Executive';
        jd.Property__c=propId;
        jd.Division__c = 'Corporate Development';
        jd.Department__c = 'Corporate Development';
        jd.RecordTypeId = Schema.SObjectType.Job_Description__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert jd;
        
        return jd;
    }
    
    public static Requisition__c getRequisitionTestData(Id propId, Id jobId){
        
        Requisition__c req = new Requisition__c();
        req.Property__c = propId;
        req.Department__c = 'Corporate Development';
        req.Division__c = 'Corporate Development';
        req.Job_Description__c = jobId;
        req.Position__c = 'Corporate Manager';
        req.Job_Level__c = 'B';
        req.Number_of_Employed__c = 1;
        req.RecordTypeId = Schema.SObjectType.Requisition__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert req;
        
        return req;
    }
    
    public static DOA__c getDOATestData(Id propId, Id conId, String type){

		DOA__c doa = new DOA__c();
        doa.Property__c = propId;
        doa.Approver__c = conId;
        doa.Process_Type__c = type;
        insert doa;
        
        return doa;
        
    }
    
    public static void createOnboardMasterChecklist(Id teamId){
        
        Master_Checklist__c mc = new Master_Checklist__c();
        mc.Type__c = '';
        insert mc;
        
        Master_Checklist_Item__c mci = new Master_Checklist_Item__c();       
        mci.Master_Checklist__c = mc.Id;
        mci.Description__c = 'HRIS Test';
        mci.Assign_To_Team__c = teamId;
        mci.S_N__c = 1.0;
       
    }
    
    public static void createOffboardMasterChecklist(Id teamId){
        
        Master_Checklist__c mc = new Master_Checklist__c();
        mc.Type__c = '';
        insert mc;
        
        Master_Checklist_Item__c mci = new Master_Checklist_Item__c();       
        mci.Master_Checklist__c = mc.Id;
        mci.Description__c = 'HRIS Test';
        mci.Assign_To_Team__c = teamId;
        mci.S_N__c = 1.0;
       
    }
    
    public static Action_Taker__c getTeamTestData(Id propId){
        
        Action_Taker__c team = new Action_Taker__c();
        team.Property__c = propId;
        team.name = 'HRIS Test Support Team';
        insert team;
        
        return team;
       
    }
    
    public static Team_Member__c getTeamMemberTestData(Id teamId, Id conId){
        
        Team_Member__c teamMMBR = new Team_Member__c();
        teamMMBR.Member__c = conId;
        teamMMBR.Team__c = teamId;
        teamMMBR.Status__c = 'Active';
        insert teamMMBR;
        
        return teamMMBR;
       
    }
     

}