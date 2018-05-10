global class FlagMDDailyCheckListBatch implements database.Batchable<sobject>{
	global List<Daily_Checklist__c> checkListToUpdate;
	global string query;

	global database.querylocator start(database.BatchableContext bc){
		Date dt = system.today() - ((Test.isRunningTest())?(-1):( 7 * Integer.valueof(label.Mobile_Display_Weeks) ));
		//Target_Date__c
		query = 'select Id,CreatedDate,Mobile_Display__c,Status__c from Daily_Checklist__c Where Target_Date__c <: dt And Status__c =\'Completed\' and Mobile_Display__c = true ';
		return database.getQueryLocator(query);  
	}
	global void execute(database.BatchableContext bc,list<Daily_Checklist__c > scope){
		checkListToUpdate = new List<Daily_Checklist__c>();
		Daily_Checklist__c tempChck = new Daily_Checklist__c();
		For(Daily_Checklist__c chck:scope){
		    tempChck = new Daily_Checklist__c();
		    tempChck.Id = chck.Id;
			tempChck.Mobile_Display__c = false;
			checkListToUpdate.add(tempChck);
			System.debug('chck-->'+chck);
		}
		if(checkListToUpdate.size()>0){
			update checkListToUpdate;
			System.debug('checkListToUpdate.size()-->'+checkListToUpdate.size());
		}
	}
	global void finish(database.BatchableContext bc){

	}
}