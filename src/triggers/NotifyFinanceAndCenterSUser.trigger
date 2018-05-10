trigger NotifyFinanceAndCenterSUser on Rent_Roll__c (after insert) {
    if(Utility.NfyFinanceRun){
    	Set<Id> rentRolls = new Set<Id>();
        //NotifyEmailHelper.NotifyTheseRec('Finance',Trigger.newMap.Keyset());
        for(Rent_Roll__c rr: Trigger.new){
        	if(!rr.Notified_Finance__c){
        		rentRolls.add(rr.Id);
        	}
        }
         NotifyFinance_Helper.NotifyFinanceUsers(rentRolls);
        Utility.NfyFinanceRun = false; 
   }
}