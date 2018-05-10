trigger MainMeterTrigger on Electric_Meter__c (after insert, after update, before update) {
	if(Trigger.isBefore && Trigger.isUpdate){
		MainMeterTrigger_Helper.preventUpdateManually(Trigger.new, Trigger.OldMap);
	}
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        MainMeterTrigger_Helper.checkDuplicateMeters(Trigger.new);
        
        /* Commented this part. Because it is not deployet yet to Production. It is available in Wind dev. */
        if(trigger.isInsert){
          //  EletricMeterController.executePushElectricMeterAPI('insert', Trigger.New, null);           
        }else if(trigger.isUpdate){  
           // EletricMeterController.executePushElectricMeterAPI('update', Trigger.New, Trigger.Old);   
        }
      
    }
}