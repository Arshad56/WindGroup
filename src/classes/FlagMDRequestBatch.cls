global class FlagMDRequestBatch implements database.Batchable<sobject>{
	global List<Request__c> requestToUpdate;
	global string query;

	global database.querylocator start(database.BatchableContext bc){
		Date dt = system.today() - ((Test.isRunningTest())?(-1):( 7 * Integer.valueof(label.Mobile_Display_Weeks) ));
		//Date_Time_Closed__c
		query = 'select Id,CreatedDate,Mobile_Display__c,Date_Time_Closed__c,Status__c from Request__c Where Date_Time_Closed__c <: dt And Status__c =\'Closed\' and Mobile_Display__c = true ';
		return database.getQueryLocator(query);  
	}
	global void execute(database.BatchableContext bc,list<Request__c > scope){
		requestToUpdate = new List<Request__c>();
		Request__c tempReq = new Request__c();
		For(Request__c req:scope){
		    tempReq = new Request__c();
		    tempReq.Id = req.Id;
			tempReq.Mobile_Display__c = false;
			if(req.Date_Time_Closed__c == null){
				tempReq.Date_Time_Closed__c = System.now();	
			}
			requestToUpdate.add(tempReq);
			System.debug('req-->'+req);
		}
		if(requestToUpdate.size()>0){
			update requestToUpdate;
			System.debug('requestToUpdate.size()-->'+requestToUpdate.size());
		}
	}
	global void finish(database.BatchableContext bc){
			 
	}
}