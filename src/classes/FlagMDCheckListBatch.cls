global class FlagMDCheckListBatch implements database.Batchable<sobject>{
	global List<Checklist__c> checkListToUpdate;
	global string query;

	global database.querylocator start(database.BatchableContext bc){
		Date dt = system.today() - ((Test.isRunningTest())?(-1):( 7 * Integer.valueof(label.Mobile_Display_Weeks) ));
		//Signed_Off_Date__c
		query = 'select Id,CreatedDate,Mobile_Display__c,Status__c from Checklist__c Where Signed_Off_Date__c <: dt And Status__c =\'Completed\' and Mobile_Display__c = true ';
		return database.getQueryLocator(query);  
	}
	global void execute(database.BatchableContext bc,list<Checklist__c > scope){
		checkListToUpdate = new List<Checklist__c>();
		Checklist__c tempChck = new Checklist__c();
		For(Checklist__c chck:scope){
		    tempChck = new Checklist__c();
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