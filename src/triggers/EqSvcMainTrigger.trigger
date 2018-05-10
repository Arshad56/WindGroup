trigger EqSvcMainTrigger on Equipment_Service_Contract__c (before insert, before update) {
    
     if(trigger.isBefore){
        if(trigger.isUpdate){
            EqSvcMainTriggerHelper.validateEqServiceContractNumber(trigger.new, trigger.old);
            EqSvcMainTriggerHelper.createRequest(trigger.new, trigger.old);
            EqSvcMainTriggerHelper.eqscChangeDate(trigger.new, trigger.old);
        } else if (trigger.isInsert){
            EqSvcMainTriggerHelper.setEqSeviceContractNumber(trigger.new);
            EqSvcMainTriggerHelper.createEquipmentServiceContract(trigger.new);
        }
    }

}