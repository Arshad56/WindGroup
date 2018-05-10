trigger MainActionTakerTrigger on Action_Taker__c (after insert, after update) {
    if(Trigger.isAfter){
    	 MainActionTakerTrigger_Helper.checkDuplicate(Trigger.new);
    }
}