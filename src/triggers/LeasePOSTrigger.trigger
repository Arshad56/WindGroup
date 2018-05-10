trigger LeasePOSTrigger on Lease_POS__c (after insert, after update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            LeasePOSController.executePushPOSAPI('insert', Trigger.New, null);           
        }else if(trigger.isUpdate){
            LeasePOSController.executePushPOSAPI('update', Trigger.New, Trigger.Old);     
        }
    }
}