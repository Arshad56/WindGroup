trigger MainDepositTrigger on Deposit__c (before insert,before update,after update) {
	System.debug('--Deposit Trigger--');
    if(checkRecursive.runDepositAlready()){
        Set<Id> leaseUnitIds = new Set<Id>();
        Map<Id,Deposit__c> approvedDps  = new Map<Id,Deposit__c>(); 
        for(Deposit__c dp: Trigger.new){
            if(Trigger.isBefore && Trigger.isInsert){ 
                leaseUnitIds.add(dp.Lease_Unit__c);
                leaseUnitIds.add(dp.LOI_Unit__c);
            }
        }
        System.debug('--leaseUnitIds11--'+leaseUnitIds);
        if(leaseUnitIds.size() > 0){
        	System.debug('--leaseUnitIds22--'+leaseUnitIds);
            if(checkRecursive.runOnce()){
            	System.debug('--leaseUnitIds33--'+leaseUnitIds);
                MainDepositTrigger_Helper.generateDPName(leaseUnitIds,Trigger.new);
            }
        }   
    }
}