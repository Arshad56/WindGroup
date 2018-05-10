trigger MainInventoryTrigger on Inventory__c (after update) {
    if(checkRecursive.runOnce()){
        if(Trigger.isAfter && Trigger.isUpdate){
            Set<Id> inventoryIds = new Set<Id>();
            for(Inventory__c inv: Trigger.new){
                if(inv.Status__c != null && !inv.Status__c.equals('') && inv.Status__c.equals('Write-off Approved'))
                {
                    inventoryIds.add(inv.Id);
                }
            }
    
            if(inventoryIds.size() > 0){ 
                WriteOffController wrc = new WriteOffController(null,inventoryIds);
                wrc.writeOff(); 
            }   
        }
    }

}