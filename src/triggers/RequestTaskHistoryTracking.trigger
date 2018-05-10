trigger RequestTaskHistoryTracking on Task (before insert,after update) {
	if(Trigger.isBefore && Trigger.isInsert){
    	System.debug('beforeInsert-->'+Trigger.new);
    	Set<Id> reqIds=new Set<Id>();
	    for(Task dp: Trigger.new){
	    	If(dp.WhatId !=  null && dp.WhatId.getSObjectType().getDescribe().getName() ==  'Request__c')
    		reqIds.add(dp.whatId);
    	}
    	if(reqIds.size() > 0){
	    	RequestTaskHistoryTracking_Helper.generateTSKName(reqIds,Trigger.new);
	    }
	}
    if(Trigger.isAfter && Trigger.isUpdate){
    	List<Task_Activity_History__c> taskHistoryRec=  new List<Task_Activity_History__c>();
    	for(Task tsk: Trigger.new){
    		System.debug(Trigger.oldMap.get(tsk.id).Description+' 1111-->'+!String.isBlank(Trigger.oldMap.get(tsk.id).Description));
    		System.debug(' 2222-->'+Trigger.oldMap.get(tsk.id).Estimated_Completion__c);
    		System.debug(' 3333-->'+Trigger.oldMap.get(tsk.id).Estimated_Cost__c);
    		System.debug(' 4444-->'+Trigger.oldMap.get(tsk.id).Estimated_Effort__c);
    		System.debug('5555-->'+( !String.isBlank(Trigger.oldMap.get(tsk.id).Description) ||Trigger.oldMap.get(tsk.id).Estimated_Completion__c != null || Trigger.oldMap.get(tsk.id).Estimated_Cost__c  != null || Trigger.oldMap.get(tsk.id).Estimated_Effort__c  != null));
    		if( !String.isBlank(Trigger.oldMap.get(tsk.id).Description) ||Trigger.oldMap.get(tsk.id).Estimated_Completion__c != null || Trigger.oldMap.get(tsk.id).Estimated_Cost__c  != null || Trigger.oldMap.get(tsk.id).Estimated_Effort__c  != null){
	    		if(tsk.WhatId !=  null && tsk.WhatId.getSObjectType().getDescribe().getName() ==  'Request__c' ){
	            	if(tsk.Description !=  Trigger.oldMap.get(tsk.id).Description || tsk.Estimated_Completion__c !=  Trigger.oldMap.get(tsk.id).Estimated_Completion__c || tsk.Estimated_Cost__c !=  Trigger.oldMap.get(tsk.id).Estimated_Cost__c || tsk.Estimated_Effort__c !=  Trigger.oldMap.get(tsk.id).Estimated_Effort__c ){
	            		Task_Activity_History__c tskHis=  new Task_Activity_History__c();
		            	//tskHis.Name=  '--System Generated--';
						tskHis.Comment__c = Trigger.oldMap.get(tsk.id).Description;
						tskHis.Date_Time__c = Trigger.oldMap.get(tsk.id).LastModifiedDate;
						tskHis.Estimated_Completion__c = Trigger.oldMap.get(tsk.id).Estimated_Completion__c;
						tskHis.Estimated_Cost__c = Trigger.oldMap.get(tsk.id).Estimated_Cost__c;
						tskHis.Estimated_Work_Days__c = Trigger.oldMap.get(tsk.id).Estimated_Effort__c;
						//tskHis.Location__c = Trigger.oldMap.get(tsk.id).Location__c;
						//tskHis.Property__c = Trigger.oldMap.get(tsk.id).Property__c;
						//tskHis.Equipment__c = Trigger.oldMap.get(tsk.id).Equipment__c;
						tskHis.Request_ID__c = Trigger.oldMap.get(tsk.id).WhatId;
						tskHis.Task_ID__c = Trigger.oldMap.get(tsk.id).Task_ID__c;
						tskHis.Task_Record_ID__c = Trigger.oldMap.get(tsk.id).Id;
						tskHis.User_Name__c = Trigger.oldMap.get(tsk.id).LastModifiedById;
		            	
		            	taskHistoryRec.add(tskHis);
	            	}
	       		}
    		}
    	}
    	
    	try{
    		insert taskHistoryRec;
    		System.debug('taskHistoryRec--> '+taskHistoryRec);
    	}catch(Exception e){
    		System.debug('Exception Occured--> '+e);
    	}
    }
}