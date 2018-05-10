trigger SetRentRollIndex on Rent_Roll__c (before Insert) {
        Set<Id> propIds = new Set<Id>();
        for(Rent_Roll__c rr:Trigger.New){
            if(rr.Property__c!=null){
                propIds.add(rr.Property__c);
            }
        }
        
        if(propIds.size()>0){
            Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Rent_Roll_Index__c from Property__c where id in:propIds]);
            
            List<Property__c> propertyList = new List<Property__c>();
            Set<Id> dupCheck = new Set<Id>();
            for(Rent_Roll__c rr:Trigger.New){
                if(rr.Property__c!=null && propMap.containsKey(rr.Property__c)){
                    property__c prop = propMap.get(rr.Property__c);                    
                    Integer IntIndex = 1;
                    if(prop.Rent_Roll_Index__c!=null){
                        intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
                    }
                    
                    Integer indexSize = string.valueOf(intIndex).length();
                    
                    string index = '';
                    for(integer i =1;i<=6-indexSize;i++){
                        index += '0';
                    }
                    index += string.valueOf(intIndex);
                    rr.Rent_Roll_Index__c = index;
                    prop.Rent_Roll_Index__c = intIndex + 1;
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