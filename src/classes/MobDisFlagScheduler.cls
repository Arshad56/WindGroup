public class MobDisFlagScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
    	System.debug('Batch 1 ---> for Checklist');
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
 		System.debug('--------------------------');
    }
}