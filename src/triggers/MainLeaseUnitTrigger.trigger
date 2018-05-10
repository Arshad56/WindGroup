trigger MainLeaseUnitTrigger on Lease_Unit__c (after update) { 
    if(Trigger.isAfter){
        Map<Id, Lease_Unit__c> oldLU= new Map<Id, Lease_Unit__c>();
        Map<Id, Lease_Unit__c> newLU= new Map<Id, Lease_Unit__c>();
        Set<Id> unitIdDtChange = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        Set<Id> leaseUnitIds = new Set<Id>();
        for(Lease_Unit__c lu: Trigger.new){
            if(Trigger.isUpdate && !Trigger.oldMap.get(lu.Id).Update_Lease_Plans__c  && lu.Update_Lease_Plans__c){
                leaseUnitIds.add(lu.Id); 
                unitIds.add(lu.Unit__c);
            }else if(Trigger.isUpdate && lu.Update_Lease_Plans__c && Trigger.oldMap.get(lu.Id).Update_Lease_Plans__c){
                if(lu.Lease_End_Date__c != Trigger.oldMap.get(lu.Id).Lease_End_Date__c){
                    oldLU.put(lu.Id, Trigger.oldMap.get(lu.Id));
                    newLU.put(lu.Id, lu);
                    unitIdDtChange.add(lu.Unit__c);
                }
            }
        }
        if(leaseUnitIds.size() > 0){
            MainLeaseUnitTrigger_Helper.updateLeasePlans(leaseUnitIds,unitIds);
        }
        System.debug('unitIdDtChange-->'+unitIdDtChange);
        if(unitIdDtChange.size() > 0)
            MainLeaseUnitTrigger_Helper.updateLeasePlans(newLU, oldLU, unitIdDtChange);
    }
}