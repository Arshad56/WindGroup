/**
 * Test class for BatchNewTopicsUpdate
 */
@isTest()
public class MDBatch_Test {

    static testMethod void myUnitTest() {
    	
    	Count_Index__c setting = new Count_Index__c();
		setting.Name = 'Request_ST_Index';
		setting.Count__c = null;
		insert setting;
		
    	Checklist_Master__c checkMasterRec = new Checklist_Master__c(Description__c='Sample');
        insert checkMasterRec;
        
    	Checklist__c checkList = new Checklist__c (Checklist_Master__c=checkMasterRec.Id,Status__c ='Completed',Signed_Off_Date__c = System.Today());
    	insert checkList;
    	
    	Daily_Checklist__c dailyCheckList = new Daily_Checklist__c (Checklist_Master__c=checkMasterRec.Id,Status__c ='Completed',Target_Date__c = System.Today());
    	insert dailyCheckList;
    	
    	Request__c req = new Request__c (Name = 'Test Req',Status__c ='Closed', Date_Time_Closed__c = System.Today());
    	insert req;
    	
    	Test.StartTest();
    	
	    	/*System.debug('Batch 1 ---> for Checklist');
	    	FlagMDCheckListBatch chkListBatch=new FlagMDCheckListBatch();
	 		Database.executeBatch(chkListBatch);
	 		System.debug('--------------------------');
	 		
	 		System.debug('Batch 2 ---> for Daily Checklist');
			FlagMDDailyCheckListBatch dailyChkListBatch=new FlagMDDailyCheckListBatch();
	 		Database.executeBatch(dailyChkListBatch);
	 		System.debug('--------------------------');
	 		
	 		System.debug('Batch 3 ---> for Request');
	 		FlagMDRequestBatch requestbatch=new FlagMDRequestBatch();
	 		Database.executeBatch(requestbatch);
	 		System.debug('--------------------------');*/
	 		
            MobDisFlagScheduler sh1 = new MobDisFlagScheduler();
			String sch = '0 0 23 * * ?'; 
			system.schedule('Test Territory Check', sch, sh1); 

	        
    	Test.StopTest();
    	
    }
}