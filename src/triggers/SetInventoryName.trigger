trigger SetInventoryName on Inventory__c (before Insert) {
    Set<Id> propIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    for(Inventory__c inv:Trigger.New){
        if(inv.Property__c!=null){
            propIds.add(inv.Property__c);
        }
        if(inv.Product_Name__c!=null){
            productIds.add(inv.Product_Name__c);
        }
    }
    
    if(propIds.size()>0 && productIds.size()>0){
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Inventory_Index__c,Short_Code__c from Property__c where id in:propIds]);
        
        Map<Id,Item_Catalogue__c> prodCatMap = new Map<Id,Item_Catalogue__c>([select id,Product_Type__c from Item_Catalogue__c where id in:productIds]);
        
        List<Property__c> propertyList = new List<Property__c>();
        Set<Id> dupCheck = new Set<Id>();
        for(Inventory__c inv:Trigger.New){
            if(inv.Property__c!=null && propMap.containsKey(inv.Property__c) && prodCatMap.containsKey(inv.Product_Name__c)){
                property__c prop = propMap.get(inv.Property__c);                    
                Integer IntIndex = 1;
                if(prop.Inventory_Index__c!=null && prop.Inventory_Index__c>0){
                    intIndex = Integer.valueOf(prop.Inventory_Index__c);
                }
                
                Integer indexSize = string.valueOf(intIndex).length();
                
                string index = '';
                for(integer i =1;i<=6-indexSize;i++){
                    index += '0';
                }
                index += string.valueOf(intIndex);
                if(prodCatMap.get(inv.Product_Name__c).Product_Type__c=='Consumable'){
                    inv.Name = prop.Short_Code__c+'-CS-IV-'+index;
                }else if(prodCatMap.get(inv.Product_Name__c).Product_Type__c=='Equipment'){
                    inv.Name = prop.Short_Code__c+'-EQ-IV-'+index;
                }
                prop.Inventory_Index__c = intIndex + 1;
                if(!dupCheck.contains(prop.Id)){
                    propertyList.add(prop);
                    dupCheck.add(prop.Id);
                }
            }
        }
        
        if(propertyList.size()>0){
            update propertyList;
        }
    }
}