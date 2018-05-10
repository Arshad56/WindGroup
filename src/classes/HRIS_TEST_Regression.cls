@isTest
private class HRIS_TEST_Regression {
    
    public static Account acct = HRIS_TEST_DataFactory.getAccountTestData();
    public static Contact con = HRIS_TEST_DataFactory.getContactTestData(acct.Id);
    public static Property__c prop = HRIS_TEST_DataFactory.getPropertyTestData(acct.Id);
    public static Job_Description__c jd = HRIS_TEST_DataFactory.getJobDescriptionTestData(prop.Id);
    public static Headcount_Budget__c hb = HRIS_TEST_DataFactory.getHeadcountBudgetTestData(prop.Id, 'Corporate Development', 'Corporate Development');
    public static Requisition__c requisition = HRIS_TEST_DataFactory.getRequisitionTestData(prop.Id, jd.Id);
    public static DOA__c doaRequisite = HRIS_TEST_DataFactory.getDOATestData(prop.Id, con.Id, 'Requisite');
    public static DOA__c doaHire = HRIS_TEST_DataFactory.getDOATestData(prop.Id, con.Id, 'Hire');
    public static DOA__c doaJobChange= HRIS_TEST_DataFactory.getDOATestData(prop.Id, con.Id, 'Job Change');
    
    @isTest
    private static void testRequisitionStep(){

        Test.startTest();
        Requisition__c req = new Requisition__c();
        HRISRequisitionExtension testReqExt = new HRISRequisitionExtension(new ApexPages.StandardController(req));
        testReqExt.createRequisition();
        
        Pagereference pageRef = Page.HRISRequisition;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        req.Department__c = 'Corporate Development';
        req.Division__c = 'Corporate Development';
        req.Job_Description__c = jd.Id;
        req.Number_of_Employed__c = 1;
        testReqExt = new HRISRequisitionExtension(new ApexPages.StandardController(req));
        testReqExt.createRequisition();
        testReqExt.setRequisiteInfo();
        testReqExt.saveReq();
        testReqExt.submitReq();
        testReqExt.search();
        List <Requisition__c> reqList = [Select Id, Name, Division__c, Department__c, Position__c, Job_Level__c, Number_of_Employed__c, Approval_Status__c, Status__c From Requisition__c where Property__c = :prop.Id];
        Test.stopTest();
    }

    @isTest
    private static void testHireStep(){
        
        Test.startTest();
        
        Personnel_Action__c pa = new Personnel_Action__c();
        HRISHireCandidateExtension testHireExt = new HRISHireCandidateExtension(new ApexPages.StandardController(pa));
        testHireExt.createHireCandidate();
        
        Pagereference pageRef = Page.HRISHireCandidate;
        pageRef.getParameters().put('propertyId',prop.id);
        pageRef.getParameters().put('rowIndex', String.valueOf('0'));
        Test.setCurrentPage(pageRef);
        pa.Requisition_No__c = requisition.Id;
        pa.Department__c = 'Corporate Development';
        pa.Division__c = 'Corporate Development';
        //pa.Employee__c = con.Id;
        pa.First_Name__c = 'HRIS First Name';
        pa.Last_Name__c = 'HRIS Last Name';
        pa.Comparative_Salary__c = con.Id;

        testHireExt = new HRISHireCandidateExtension(new ApexPages.StandardController(pa));
        testHireExt.createHireCandidate();
        testHireExt.setEmployeeInfo();
        testHireExt.Add();
        testHireExt.deleteRow();
        pa.Comparative_Salary__c = con.Id;
        testHireExt.Add();
        testHireExt.saveHire();
        testHireExt.submitHire();
        pa = [Select Id, Approval_Status__c From Personnel_Action__c where Property__c = :prop.Id and Checklist_Type__c =: HRISUtil.HRIS_Onboard];
        pa.Approval_Status__c = 'Approved';
        upsert pa;
        testHireExt.search();
        
        Test.stopTest();
        
    }
 
    @isTest
    private static void testJobChangeStep(){
        
        Test.startTest();
        
        Personnel_Action__c pa = new Personnel_Action__c();
        HRISJobChangeStep1Extension testJobChangeExt = new HRISJobChangeStep1Extension(new ApexPages.StandardController(pa));
        testJobChangeExt.createJobChange();
        
        Pagereference pageRef = Page.HRISJobChangeEmployee;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        pa.Employee__c = con.Id;
        pa.Movement_Type__c = 'Separation';

        testJobChangeExt = new HRISJobChangeStep1Extension(new ApexPages.StandardController(pa));
        testJobChangeExt.createJobChange();
        testJobChangeExt.setEmployeeInfo();
        testJobChangeExt.saveJobChange();
        testJobChangeExt.submitJobChange();
        pa = [Select Id, Approval_Status__c From Personnel_Action__c where Property__c = :prop.Id and Checklist_Type__c =: HRISUtil.HRIS_Offboard];
        pa.Approval_Status__c = 'Approved';
        upsert pa;
        testJobChangeExt.search();
        
        Test.stopTest();
    }

    @isTest
    private static void testOnboardingEmployeeChecklist(){
        
        Test.startTest();
        
        Personnel_Action__c pa = new Personnel_Action__c();
       
        Test.stopTest();
    }

}