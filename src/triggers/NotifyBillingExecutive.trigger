trigger NotifyBillingExecutive on Rent_Roll__c(after update, after insert){
    if(Utility.NfyBillExeRun){
        Set<Id> rentRolls = new Set<Id>();
        for(Rent_Roll__c rr: Trigger.new) {
        	System.debug(rr);
        	if(Trigger.isInsert)
	        	if(!rr.Notified_Billing__c && rr.Approved__c)
	        		rentRolls.add(rr.Id);
    		if(Trigger.isUpdate)
	            if(!rr.Notified_Billing__c && rr.Approved__c && !Trigger.oldmap.get(rr.Id).Approved__c) 
	                rentRolls.add(rr.Id);
	        System.debug(rr.Id);
        }
        System.debug('rentRolls-->'+rentRolls);
        //NotifyEmailHelper.NotifyTheseRec('Billing',rentRolls);
        NotifyBilling_Helper.NotifyBillingUsers(rentRolls);
        Utility.NfyBillExeRun = false;
    }
}