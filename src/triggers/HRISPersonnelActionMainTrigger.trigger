trigger HRISPersonnelActionMainTrigger on Personnel_Action__c (after update, before update, before insert) {
    
    if(Trigger.isAfter && Trigger.isUpdate){        
        HRISPersonnelActionController.updateContact(Trigger.New, Trigger.Old);
      if(checkRecursive.runOnce())
        HRISPersonnelActionController.createEmployeeChecklist(Trigger.New, Trigger.Old);    
    }
     
    if(Trigger.isBefore && Trigger.isInsert)
        HRISPersonnelActionController.insertContact(Trigger.New);

}