trigger MainEquipmentTrigger on Equipment__c (before Insert) {
    if(checkRecursive.runOnce()){
		Set<Id> propertyIds = new Set<Id>();
	    for(Equipment__c eq: Trigger.new){
	    	if(Trigger.isBefore && Trigger.isInsert){ 
	    		if(eq.Property__c != null){
	    			propertyIds.add(eq.Property__c);
	    		}
	    	}
	    }
	    if(propertyIds.size() > 0){ 
	    	MainEquipment_Helper.generateEQName(propertyIds,Trigger.new); 
	    }	
	}
}