trigger HRISRequisitionMainTrigger on Requisition__c (before insert, after update, after insert) {
    
    if(Trigger.isAfter)
        if(Trigger.isUpdate)
        HRISRequisitionController.updateHeadCountDeStatus(Trigger.New,Trigger.Old);
    else if(Trigger.isInsert){
        //HRISRequisitionController.submitApproval(Trigger.New);
        HRISRequisitionController.addHeadcountBudgetDetail(Trigger.New);
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            HRISRequisitionController.setRequisitionNumber(Trigger.New);
            HRISRequisitionController.checkHeadcount(Trigger.New);
            HRISRequisitionController.setJobDescriptionInfo(Trigger.New);
        }
    }
     
}