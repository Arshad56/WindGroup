trigger FMSvcMainTrigger on FM_Service_Contract__c (before insert,before update) {
    
    if(trigger.isBefore){
        if(trigger.isUpdate){
            FMSvcMainTriggerHelper.validateServiceContractNumber(trigger.new, trigger.old);
        } else if (trigger.isInsert){
            FMSvcMainTriggerHelper.setSeviceContractNumber(trigger.new);
        }
    }

}