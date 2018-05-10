trigger ChangeLeaseStartDate on Lease__c (before update)  {    
    ChangeLeaseStartDateController clsc = new ChangeLeaseStartDateController();
    clsc.executeBeforeUpdate(Trigger.Old, Trigger.New);  
}