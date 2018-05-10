trigger MainRequestTrigger on Request__c (before insert, after insert, before update, after update) {
	/*if(checkRecursive.runOnce()){
		//Notify_Schedule_Request_Creation__c nt = Notify_Schedule_Request_Creation__c.getValues('Scheduled');
		MainRequestTrigger_Helper.notifyScheduled =  Notify_Schedule_Request_Creation__c.getValues('Scheduled');
	    if(Trigger.isBefore && Trigger.isInsert){
	    	System.debug('beforeInsert-->'+Trigger.new);
	    	Set<Id> propIds=new Set<Id>();
		    for(Request__c dp: Trigger.new){
	    		propIds.add(dp.Property__c);
	    	}
	    	if(propIds.size() > 0){
		    	MainRequestTrigger_Helper.generateReqName(propIds,Trigger.new);
		    }
		}
		if(Trigger.isAfter && Trigger.isInsert ){
			System.debug('AfterInsert-->'+Trigger.newMap);
		    MainRequestTrigger_Helper.assignPersonInCharge(Trigger.newMap,Trigger.new);
		}
		if(Trigger.isBefore && Trigger.isUpdate ){
			MainRequestTrigger_Helper.validateCompleteTasks(Trigger.newmap);
		}
		if(Trigger.isAfter && Trigger.isUpdate ){
			Map<Id,Request__c> reqNewMap11 = new Map<Id,Request__c> ();
			Map<Id,Request__c> reqOldMap11 = new Map<Id,Request__c> ();
			Map<Id,Request__c> reqNewMap = new Map<Id,Request__c> ();
			Map<Id,Request__c> reqOldMap = new Map<Id,Request__c> ();
			for(Request__c req: Trigger.new){
				if(Trigger.oldmap.get(req.Id).Person_In_Charge__c != req.Person_In_Charge__c){
					reqNewMap11.put(req.Id, req); 
					reqOldMap11.put(req.Id, Trigger.oldmap.get(req.Id));
				}
			}
			MainRequestTrigger_Helper.sendNotificationOnStatusPICChange(Trigger.newmap,Trigger.oldmap);
			MainRequestTrigger_Helper.sendNotificationOnPICChange(reqNewMap11,reqOldMap11);
		}
	}*/
	MainRequestTrigger_Helper.notifyScheduled =  Notify_Schedule_Request_Creation__c.getValues('Scheduled');
	if(Trigger.isBefore){
	 	if(Trigger.isInsert){
		    	MainRequestTrigger_Helper.generateReqName(Trigger.new);
	    }  
	    if(Trigger.isUpdate){
   	 		MainRequestTrigger_Helper.validateCompleteTasks(Trigger.newmap);
   	 	}
	}
	if(Trigger.IsAfter && checkRecursive.runOnce()){
		if(Trigger.isInsert){
	        System.debug('AfterInsert-->'+Trigger.newMap);
		    MainRequestTrigger_Helper.assignPersonInCharge(Trigger.newMap,Trigger.new);
		}
	    if(Trigger.isUpdate){
			Map<Id,Request__c> reqNewMap11 = new Map<Id,Request__c> ();
			Map<Id,Request__c> reqOldMap11 = new Map<Id,Request__c> ();
			Set<Id> reqSet = new Set<Id>();
			for(Request__c req: Trigger.new){
				if(Trigger.oldmap.get(req.Id).Person_In_Charge__c != req.Person_In_Charge__c){
					reqNewMap11.put(req.Id, req); 
					reqOldMap11.put(req.Id, Trigger.oldmap.get(req.Id));
					reqSet.add(req.Id);
				}
			}
			MainRequestTrigger_Helper.sendNotificationOnStatusPICChange(Trigger.newmap,Trigger.oldmap);
			if(reqSet.size() > 0)
				MainRequestTrigger_Helper.sendNotificationOnPICChange(reqNewMap11,reqOldMap11);
		}
	}
}