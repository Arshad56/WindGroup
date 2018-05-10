trigger UpdateRSFromPOS on POS_Transaction__c (after insert, after update) {
    Set<Id> rsIds = new Set<Id>();
    for(POS_Transaction__c pos : Trigger.new){ 
    	rsIds.add(pos.Rent_Schedule__c);
    }
    CalPercentage_ByLease_Helper.updateRS(rsIds);
}