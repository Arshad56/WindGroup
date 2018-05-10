trigger SetLeaseIndex on Lease__c (before Insert) {
        Set<Id> propIds = new Set<Id>();
        for(Lease__c ls:Trigger.New){
            if(ls.Property__c!=null){
                propIds.add(ls.Property__c);
            }
        }
        
        if(propIds.size()>0){
            Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Lease_Agreement_Index__c from Property__c where id in:propIds]);
            
            List<Property__c> propertyList = new List<Property__c>();
            Set<Id> dupCheck = new Set<Id>();
            for(Lease__c ls:Trigger.New){
                if(ls.Property__c!=null && propMap.containsKey(ls.Property__c)){
                    property__c prop = propMap.get(ls.Property__c);                    
                    Integer IntIndex = 1;
                    if(prop.Lease_Agreement_Index__c!=null){
                        intIndex = Integer.valueOf(prop.Lease_Agreement_Index__c);
                    }
                    
                    Integer indexSize = string.valueOf(intIndex).length();
                    
                    string index = '';
                    for(integer i =1;i<=6-indexSize;i++){
                        index += '0';
                    }
                    index += string.valueOf(intIndex);
                    ls.Lease_Index__c = index;
                    prop.Lease_Agreement_Index__c = intIndex + 1;
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