@isTest
public class AWSIntegration_TestClass_New
{
    public static Boolean isTestRunning=false;
    
    public static testMethod void test_PushSetup(){
       
       createAWSCreData();
       createSetupData();
       
       AWSIntegrationVFController vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Push Setup';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
       
       vfControllerRec = new AWSIntegrationVFController();
       vfControllerRec.queryDateandEndPoint();
    }
    
    public static testMethod void test_IntegrationwithDefaultASWCre(){
       
       Checklist_Master__c checkMasterRec = new Checklist_Master__c(Description__c='Sample');
       insert checkMasterRec;
       Checklist__c checkRec = new Checklist__c(Checklist_Master__c=checkMasterRec.Id,Last_Updated_From__c='SF',Last_Update_Date_Time__c=System.Now(),Backend_Last_Updated_DateTime__c=System.now());
       insert checkRec;
       Checklist_Item__c checkListRec = new Checklist_Item__c(Checklist__c=checkRec.Id,Last_Updated_From__c='SF',Last_Update_Date_Time__c=System.Now(),Backend_Last_Updated_DateTime__c=System.now());
       insert checkListRec;
       Checklist_Remarks__c checkRemarks = new Checklist_Remarks__c(Checklist_Item__c=checkListRec.Id,Last_Updated_From__c='SF',Last_Update_Date_Time__c=System.Now(),Backend_Last_Updated_DateTime__c=System.now());
       insert checkRemarks;
                     
       createAWSCreDataDefault();
       AWSIntegration_PullHOTOProcess pullHOTO = new AWSIntegration_PullHOTOProcess();
       pullHOTO.execute(null);
        
       AWSIntegration_DailyChecklistPullProcess pullDailyC = new AWSIntegration_DailyChecklistPullProcess();
       pullDailyC.execute(null);
        
       AWSIntegration_PullRequestProcess pullReq = new AWSIntegration_PullRequestProcess();
       pullReq.execute(null);
       
       AWSIntegration_PullToiletFdbkProcess pullToiletFdk = new AWSIntegration_PullToiletFdbkProcess();
       pullToiletFdk.execute(null);

    }
    
    public static testMethod void test_TransactionPUSHPULL(){
                     
       createAWSCreData();
       createTransactionData();
        
       AWSIntegrationVFController vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Push Transaction';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
       
       vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Pull HOTO';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
        
       vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Pull Daily Checklist';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
    }
    
    public static testMethod void test_ToiletFeedback()
    {
       createAWSCreData();
       createToiletFeedbackData();
     
       AWSIntegrationVFController vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Pull Toilet Feedback';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
    }
    
    public static testMethod void test_RequestTaskIntegration()
    {
	   createAWSCreData();
       createRequestTaskData();
        
       Count_Index__c settingsRec = new Count_Index__c();
       settingsRec.Count__c = 0;
       settingsRec.Name = 'Request_ST_Index';
       insert settingsRec;
        
       Property__c propRec = new Property__c(Name = 'awsTestProperty');
       insert propRec;

       //Push Request
       Utility.lastUpdatedFromAwsIntegration = 'iOPS';
       Request__c testRequestRec = new Request__c(Name ='Test Sample', Last_Update_Date_Time__c = System.Now(), Backend_Last_Updated_DateTime__c = System.Now(), Location__c = null, Date_Time_Opened__c = System.today(), Action_Remarks__c='src=TestingAWSPushRequest></img>', Person_In_Charge__c = label.WG_Admin_ID, Property__c = propRec.Id);
       insert testRequestRec;
       
       AWSIntegrationVFController vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Push Request';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();
        
       vfControllerRec = new AWSIntegrationVFController(); 
       vfControllerRec.actionType = 'Pull Request';
       vfControllerRec.assignDateTime();
       vfControllerRec.invokeAction();

    }
    
    public static testMethod void test_LeasePOSIntegration()
    {
       createAWSCreData();
       createPOSData();
       
       //Push POS
       Property__c prop = new Property__c(Name = 'testPOSProperty', Short_Code__c='TEST');
       insert prop;
       Account acct = new Account(Name = 'testPOSAcct', Account_Type__c='Tenant', Trade_Category__c='Food Court');
       insert acct;
       Level__c lvl = new Level__c(Name = 'TestLevel', Property__c = prop.Id);
       insert lvl;
       Units__c unt = new Units__c(Property__c = prop.Id, Level__c = lvl.Id, Name = 'TestUnit', NLA_SQF__c = 200, Active__c = true, Start_Date__c = system.today(), End_Date__c = system.today().addYears(5));
       insert unt;       
       Lease__c lease = new Lease__c(Tenant__c = acct.Id, Property__c=prop.Id, Lease_Start_Date__c = system.today().adddays(10), Lease_Tenure_Mths__c = 12);
       insert lease;
       Lease_Unit__c leaseUnt = new Lease_Unit__c(Lease_Agreement_No__c = lease.Id, Unit__c = unt.Id);
       insert leaseUnt;
       Lease_POS__c testLeasePos = new Lease_POS__c(Name='--system generated--', Status__c = 'Active', Lease_Unit__c =leaseUnt.Id);
       insert testLeasePos;
        
       testLeasePos.Contact_Email_1__c = 'test@emai.com';
       update testLeasePos;
       
    }
    
    /*public static testMethod void test_Method10()
    {
       isTestRunning=True;
       createTestData();
       
       //Push Electric Meter Information
       Property__c prop = new Property__c(Name = 'testPOSProperty', Short_Code__c='TEST');
       insert prop;
       
       Level__c lvl = new Level__c(Name = 'TestLevel', Property__c = prop.Id);
       insert lvl;
       Units__c unt = new Units__c(Property__c = prop.Id, Level__c = lvl.Id, Name = 'TestUnit', NLA_SQF__c = 200, Active__c = true, Start_Date__c = system.today(), End_Date__c = system.today().addYears(5));
       insert unt;       
       Electric_Meter__c electricMeter = new Electric_Meter__c(Unit__c = unt.Id, Meter_No__c='TESTGSM-0001', Meter_Type__c='Generator');
       insert electricMeter;

       electricMeter.Meter_Type__c = 'Sub Meter';
       update electricMeter;
       
    }*/

    
    public static void createAWSCreData(){
        isTestRunning=true;
        AWS_Credentials__c awsRec = new AWS_Credentials__c();
        awsRec.Name='AWS';
        awsRec.clientid__c='f3d259ddd3ed8ff3843839b';
        awsRec.clientsecret__c='4c7f6f8fa93d59c45502c0ae8c4a95b';
        awsRec.EndPoint__c='http://52.77.211.113/api/oauth/access_token';
        awsRec.POSEndPoint__c = 'http://54.255.175.164/jc/api/oauth/access_token';
        awsRec.username__c='ismail@idesolusiasia.com';
        awsRec.grant_type__c='password';
        awsRec.Last_Pull_Datetime__c=system.now().adddays(-10);
        awsRec.Last_Synch_Datetime__c=system.now().adddays(-10);
        awsRec.password__c='isa2016go';
		awsRec.PULL_TOHOTransaction_StartDateTime__c = System.now();
        awsRec.Last_Daily_Checklist_Pull_Start_Datetime__c = System.now();
        awsRec.PULL_ReqTask_StartDateTime__c = System.now();
        awsRec.PULL_Toilet_Feedback_Start_Datetime__c = System.now();
        insert awsRec;
    }
    
    public static void createAWSCreDataDefault(){
        isTestRunning=true;
        AWS_Credentials__c awsRec = new AWS_Credentials__c();
        awsRec.Name='AWS';
        awsRec.clientid__c='f3d259ddd3ed8ff3843839b';
        awsRec.clientsecret__c='4c7f6f8fa93d59c45502c0ae8c4a95b';
        awsRec.EndPoint__c='http://52.77.211.113/api/oauth/access_token';
        awsRec.POSEndPoint__c = 'http://54.255.175.164/jc/api/oauth/access_token';
        awsRec.username__c='ismail@idesolusiasia.com';
        awsRec.grant_type__c='password';
        awsRec.Last_Pull_Datetime__c=system.now().adddays(-10);
        awsRec.Last_Synch_Datetime__c=system.now().adddays(-10);
        awsRec.password__c='isa2016go';
        insert awsRec;
    }
    
    public static void createSetupData(){
        
        Mobile_Module__c mm = new Mobile_Module__c(Name = 'Test Mobile Module', Icon_Url__c ='src=</img>base64,style=&amp;');
        insert mm;
        
        List<AWS_PUSH_Setup_Mapping__c> awsPushRecList = new List<AWS_PUSH_Setup_Mapping__c>();
        AWS_PUSH_Setup_Mapping__c awsPushRec = new AWS_PUSH_Setup_Mapping__c();
        awsPushRec.Name='01';
        awsPushRec.AWS_Field_Label__c='id';
        awsPushRec.AWS_Object_Label__c='mobile_module';
        awsPushRec.Is_Image__c=false;
        awsPushRec.Object_Sort_Required__c=true;
        awsPushRec.Salesforce_Field__c='ID';
        awsPushRec.Salesforce_Object_Name__c='Mobile_Module__c';
        awsPushRecList.add(awsPushRec);

        awsPushRec = new AWS_PUSH_Setup_Mapping__c();
        awsPushRec.Name='02';
        awsPushRec.AWS_Field_Label__c='icon_img';
        awsPushRec.AWS_Object_Label__c='mobile_module';
        awsPushRec.Is_Image__c=false;
        awsPushRec.Object_Sort_Required__c=false;
        awsPushRec.Salesforce_Field__c='Icon_Url__c';
        awsPushRec.Salesforce_Object_Name__c='Mobile_Module__c';
        awsPushRecList.add(awsPushRec);
      
        insert awsPushRecList;
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
        
    }
    
    public static void createTransactionData(){
        
        Checklist_Master__c cm = new Checklist_Master__c();
        cm.Type__c ='Fire Safety';
        insert cm;
        
        Daily_Checklist__c dc = new Daily_Checklist__c();
        dc.Checklist_Master__c = cm.Id;
        dc.AWS_ID__c ='00001';
        insert dc;
        
        Checklist__c ck = new Checklist__c();
        ck.Checklist_Master__c = cm.Id;
        insert ck;
     
        List<Daily_Checklist_Object_Mapping__c> awsDailyChecklistRecList = new List<Daily_Checklist_Object_Mapping__c>();
        Daily_Checklist_Object_Mapping__c awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='01';
        awsDailyChecklistRec.AWS_Field_Label__c='aws_id';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='AWS_Id__c';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        
        awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='02';
        awsDailyChecklistRec.AWS_Field_Label__c='percentage_completed';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='Percentage_Completed__c';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        
        awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='04';
        awsDailyChecklistRec.AWS_Field_Label__c='target_date';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='Target_Date__c';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        
        awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='05';
        awsDailyChecklistRec.AWS_Field_Label__c='checklist_master_id';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='Checklist_Master__c';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        
        awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='06';
        awsDailyChecklistRec.AWS_Field_Label__c='description';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='Description__c';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        
        awsDailyChecklistRec = new Daily_Checklist_Object_Mapping__c();
        awsDailyChecklistRec.Name='07';
        awsDailyChecklistRec.AWS_Field_Label__c='id';
        awsDailyChecklistRec.AWS_Object_Label__c='daily_checklist';
        awsDailyChecklistRec.Is_Image__c=false;
        awsDailyChecklistRec.Salesforce_Field__c='ID';
        awsDailyChecklistRec.Salesforce_Object_Name__c='Daily_Checklist__c';
        awsDailyChecklistRecList.add(awsDailyChecklistRec);
        insert awsDailyChecklistRecList;

        List<PULL_TOHOTransaction__c> awsHOTORecList = new List<PULL_TOHOTransaction__c>();
        PULL_TOHOTransaction__c awsHOTORec = new PULL_TOHOTransaction__c();
        awsHOTORec.Name='01';
        awsHOTORec.AWS_Field_Label__c='target_date';
        awsHOTORec.AWS_Object_Label__c='checklist';
        awsHOTORec.Is_Image__c=false;
        awsHOTORec.Object_Sort_Required__c=true;
        awsHOTORec.Salesforce_Field__c='Target_Date__c';
        awsHOTORec.Salesforce_Object_Name__c='Checklist__c';
        awsHOTORecList.add(awsHOTORec);
        
        awsHOTORec = new PULL_TOHOTransaction__c();
        awsHOTORec.Name='02';
        awsHOTORec.AWS_Field_Label__c='percentage_completed';
        awsHOTORec.AWS_Object_Label__c='checklist';
        awsHOTORec.Is_Image__c=false;
        awsHOTORec.Object_Sort_Required__c=false;
        awsHOTORec.Salesforce_Field__c='Percentage_Completed__c';
        awsHOTORec.Salesforce_Object_Name__c='Checklist__c';
        awsHOTORecList.add(awsHOTORec);
        
        awsHOTORec = new PULL_TOHOTransaction__c();
        awsHOTORec.Name='04';
        awsHOTORec.AWS_Field_Label__c='last_updated_datetime';
        awsHOTORec.AWS_Object_Label__c='checklist';
        awsHOTORec.Is_Image__c=false;
        awsHOTORec.Object_Sort_Required__c=false;
        awsHOTORec.Salesforce_Field__c='Backend_Last_Updated_DateTime__c';
        awsHOTORec.Salesforce_Object_Name__c='Checklist__c';
        awsHOTORecList.add(awsHOTORec);
        
        awsHOTORec = new PULL_TOHOTransaction__c();
        awsHOTORec.Name='03';
        awsHOTORec.AWS_Field_Label__c='checklist_master_id';
        awsHOTORec.AWS_Object_Label__c='checklist';
        awsHOTORec.Is_Image__c=false;
        awsHOTORec.Object_Sort_Required__c=false;
        awsHOTORec.Salesforce_Field__c='Checklist_Master__c';
        awsHOTORec.Salesforce_Object_Name__c='Checklist__c';
        awsHOTORecList.add(awsHOTORec);
        insert awsHOTORecList;
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
        
    }
    
    public static void createPOSData(){
        
        List<AWS_PUSH_POSInfo_Mapping__c> pushPOSList = new List <AWS_PUSH_POSInfo_Mapping__c>();
        AWS_PUSH_POSInfo_Mapping__c pushPOS = new AWS_PUSH_POSInfo_Mapping__c();
        pushPOS.Name='1';
        pushPOS.AWS_Field_Label__c='pos_id';
        pushPOS.AWS_Object_Label__c='pos_id_map';
        pushPOS.Is_Image__c=false;
        pushPOS.Object_Sort_Required__c=true;
        pushPOS.Salesforce_Field__c='Name';
        pushPOS.Salesforce_Object_Name__c='Lease_POS__c';
        pushPOSList.add(pushPOS);
        
        pushPOS = new AWS_PUSH_POSInfo_Mapping__c();
        pushPOS.Name='2';
        pushPOS.AWS_Field_Label__c='mall_code';
        pushPOS.AWS_Object_Label__c='pos_id_map';
        pushPOS.Is_Image__c=false;
        pushPOS.Object_Sort_Required__c=true;
        pushPOS.Salesforce_Field__c='Property_Short_Code__c';
        pushPOS.Salesforce_Object_Name__c='Lease_POS__c';
        pushPOSList.add(pushPOS);
        
        pushPOS = new AWS_PUSH_POSInfo_Mapping__c();
        pushPOS.Name='3';
        pushPOS.AWS_Field_Label__c='status';
        pushPOS.AWS_Object_Label__c='pos_id_map';
        pushPOS.Is_Image__c=false;
        pushPOS.Object_Sort_Required__c=true;
        pushPOS.Salesforce_Field__c='Status__c';
        pushPOS.Salesforce_Object_Name__c='Lease_POS__c';
        pushPOSList.add(pushPOS);
        insert pushPOSList;
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
        
    }
    
    public static void createRequestTaskData(){
        
        List<AWS_PUSH_ReqTask_Mapping__c> pushReqTaskList = new List<AWS_PUSH_ReqTask_Mapping__c>();
        AWS_PUSH_ReqTask_Mapping__c pushReqTask = new AWS_PUSH_ReqTask_Mapping__c();
        pushReqTask.Name='2';
        pushReqTask.AWS_Field_Label__c='aws_id';
        pushReqTask.AWS_Object_Label__c='request';
        pushReqTask.Is_Image__c=false;
        pushReqTask.Object_Sort_Required__c=true;
        pushReqTask.Salesforce_Field__c='AWS_Id__c';
        pushReqTask.Salesforce_Object_Name__c='Request__c';
        pushReqTaskList.add(pushReqTask);
        
        pushReqTask = new AWS_PUSH_ReqTask_Mapping__c();
        pushReqTask.Name='1';
        pushReqTask.AWS_Field_Label__c='id';
        pushReqTask.AWS_Object_Label__c='request';
        pushReqTask.Is_Image__c=false;
        pushReqTask.Object_Sort_Required__c=false;
        pushReqTask.Salesforce_Field__c='ID';
        pushReqTask.Salesforce_Object_Name__c='Request__c';
        pushReqTaskList.add(pushReqTask);
        
        pushReqTask = new AWS_PUSH_ReqTask_Mapping__c();
        pushReqTask.Name='22';
        pushReqTask.AWS_Field_Label__c='request_id';
        pushReqTask.AWS_Object_Label__c='request';
        pushReqTask.Is_Image__c=false;
        pushReqTask.Object_Sort_Required__c=false;
        pushReqTask.Salesforce_Field__c='Name';
        pushReqTask.Salesforce_Object_Name__c='Request__c';
        pushReqTaskList.add(pushReqTask);

        pushReqTask = new AWS_PUSH_ReqTask_Mapping__c();
        pushReqTask.Name='93';
        pushReqTask.AWS_Field_Label__c='requested_completion_date';
        pushReqTask.AWS_Object_Label__c='request';
        pushReqTask.Is_Image__c=false;
        pushReqTask.Object_Sort_Required__c=false;
        pushReqTask.Salesforce_Field__c='Requested_Completion_Date__c';
        pushReqTask.Salesforce_Object_Name__c='Request__c';
        pushReqTaskList.add(pushReqTask);
        
        pushReqTask = new AWS_PUSH_ReqTask_Mapping__c();
        pushReqTask.Name='9';
        pushReqTask.AWS_Field_Label__c='last_update_datetime';
        pushReqTask.AWS_Object_Label__c='request';
        pushReqTask.Is_Image__c=false;
        pushReqTask.Object_Sort_Required__c=false;
        pushReqTask.Salesforce_Field__c='Last_Update_Date_Time__c';
        pushReqTask.Salesforce_Object_Name__c='Request__c';
        pushReqTaskList.add(pushReqTask);           
        insert pushReqTaskList;  
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
        
    }
    
    public static void createToiletFeedbackData(){
        
        Feedback__c fb = new Feedback__c();
        fb.Status__c = 'New';
        insert fb;
        
        List<PULL_Toilet_Feedback__c> awsToiletFbList = new List<PULL_Toilet_Feedback__c>();
        PULL_Toilet_Feedback__c awsToiletFb = new PULL_Toilet_Feedback__c();
        awsToiletFb.Name='01';
        awsToiletFb.AWS_Field_Label__c='aws_id';
        awsToiletFb.AWS_Object_Label__c='feedback';
        awsToiletFb.Is_Image__c=false;
        awsToiletFb.Object_Sort_Required__c=true;
        awsToiletFb.Salesforce_Field__c='AWS_Id__c';
        awsToiletFb.Salesforce_Object_Name__c='Feedback__c';
        awsToiletFbList.add(awsToiletFb);
        
        awsToiletFb = new PULL_Toilet_Feedback__c();
        awsToiletFb.Name='02';
        awsToiletFb.AWS_Field_Label__c='resolved_datetime';
        awsToiletFb.AWS_Object_Label__c='feedback';
        awsToiletFb.Is_Image__c=false;
        awsToiletFb.Object_Sort_Required__c=true;
        awsToiletFb.Salesforce_Field__c='Resolved_Date_Time__c';
        awsToiletFb.Salesforce_Object_Name__c='Feedback__c';
        awsToiletFbList.add(awsToiletFb);
        
        awsToiletFb = new PULL_Toilet_Feedback__c();
        awsToiletFb.Name='03';
        awsToiletFb.AWS_Field_Label__c='id';
        awsToiletFb.AWS_Object_Label__c='feedback';
        awsToiletFb.Is_Image__c=false;
        awsToiletFb.Object_Sort_Required__c=true;
        awsToiletFb.Salesforce_Field__c='ID';
        awsToiletFb.Salesforce_Object_Name__c='Feedback__c';
        awsToiletFbList.add(awsToiletFb);
        insert awsToiletFbList;
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
        
    }
    
    
    public static void createElectricMeterData()
    {
        List<AWS_PUSH_ElectricMeter_Mapping__c> pushElectricMeterList = new List <AWS_PUSH_ElectricMeter_Mapping__c>();
        AWS_PUSH_ElectricMeter_Mapping__c pushElectricMeter = new AWS_PUSH_ElectricMeter_Mapping__c();
        pushElectricMeter.Name='1';
        pushElectricMeter.AWS_Field_Label__c='mall_code';
        pushElectricMeter.AWS_Object_Label__c='';
        pushElectricMeter.Is_Image__c=false;
        pushElectricMeter.Object_Sort_Required__c=true;
        pushElectricMeter.Salesforce_Field__c='Mall_Code__c';
        pushElectricMeter.Salesforce_Object_Name__c='Electric_Meter__c';
        pushElectricMeterList.add(pushElectricMeter);
        
        pushElectricMeter = new AWS_PUSH_ElectricMeter_Mapping__c();
        pushElectricMeter.Name='2';
        pushElectricMeter.AWS_Field_Label__c='meter_no';
        pushElectricMeter.AWS_Object_Label__c='';
        pushElectricMeter.Is_Image__c=false;
        pushElectricMeter.Object_Sort_Required__c=true;
        pushElectricMeter.Salesforce_Field__c='Meter_No__c';
        pushElectricMeter.Salesforce_Object_Name__c='Electric_Meter__c';
        pushElectricMeterList.add(pushElectricMeter);
        
        pushElectricMeter = new AWS_PUSH_ElectricMeter_Mapping__c();
        pushElectricMeter.Name='3';
        pushElectricMeter.AWS_Field_Label__c='unit_id';
        pushElectricMeter.AWS_Object_Label__c='';
        pushElectricMeter.Is_Image__c=false;
        pushElectricMeter.Object_Sort_Required__c=true;
        pushElectricMeter.Salesforce_Field__c='Unit__c';
        pushElectricMeter.Salesforce_Object_Name__c='Electric_Meter__c';
        pushElectricMeterList.add(pushElectricMeter);
       
        insert pushElectricMeterList;
        
        Integration_AWS_Log__c awsLogRec = new Integration_AWS_Log__c();
        insert awsLogRec;
    }

}