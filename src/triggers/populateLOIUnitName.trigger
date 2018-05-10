trigger populateLOIUnitName on LOI_Unit__c (before insert) {
    Set<Id> propIds = new Set<Id>();
        for(LOI_Unit__c loi: trigger.new){
            if(loi.LOI_Agreement_No__c != null && !propIds.contains(loi.LOI_Agreement_No__c))
                propIds.add(loi.LOI_Agreement_No__c);
        }
        Map<Id,LOI__c> loiMap = new Map<Id,LOI__c>();
        for(LOI__c loi: [select id, Property__c,Property__r.Short_Code__c from LOI__c where id =: propIds]){
            loiMap.put(loi.Id, loi);
            if(loi.Property__c != null && !propIds.contains(loi.Property__c))
                propIds.add(loi.Property__c);
        }
        Map<Id, Property__c> listProperties= new Map<Id, Property__c>([select Id,Short_Code__c, LOI_Unit_Index__c from Property__c where id =:propIds]);
        Map<Id, Property__c> mapProperties = new Map<Id, Property__c>();
        Map<Id, Integer> mapCount = new Map<Id, Integer>();
        String code;
        
        for(LOI_Unit__c loi: trigger.new){
            if(loi.LOI_Agreement_No__c != null && loiMap.containsKey(loi.LOI_Agreement_No__c) && loiMap.get(loi.LOI_Agreement_No__c).Property__c != null){
                code  =  listProperties.get(loiMap.get(loi.LOI_Agreement_No__c).Property__c).Short_Code__c;
                code += '-LOI-';
                code += System.today().Year();
                code += (System.today().Month()<10?'0'+System.today().Month():''+System.today().Month());
                
                code += '-';
                Integer temp;
                if(mapProperties.containsKey(loiMap.get(loi.LOI_Agreement_No__c).Property__c)){
                    temp = Integer.valueOf(mapProperties.get(loiMap.get(loi.LOI_Agreement_No__c).Property__c).LOI_Unit_Index__c);
                }else{
                    temp =  Integer.valueof(listProperties.get(loiMap.get(loi.LOI_Agreement_No__c).Property__c).LOI_Unit_Index__c);
                }
                String tempNo;
                if(temp == 0 || temp == null){
                    temp   = 1;
                    tempNo = ''+temp;
                }else{
                    tempNo = ''+temp;
                }
                for(integer i =1;i<=6-tempNo.length();i++){
                    code += '0';
                }
                code += tempNo;
                loi.Name = code;
                 temp += 1;
                if(listProperties.get(loiMap.get(loi.LOI_Agreement_No__c).Property__c).Id != null){
                    Property__c pr = new Property__c();
                    pr.Id = listProperties.get(loiMap.get(loi.LOI_Agreement_No__c).Property__c).Id;
                    if(mapProperties.containsKey(pr.Id)){
                        //pr.LOI_Unit_Index__c = temp;
                        mapProperties.get(pr.Id).LOI_Unit_Index__c += 1;
                    }else{
                        pr.LOI_Unit_Index__c = temp;
                        mapProperties.put(pr.Id, pr);
                    }
                    
                }
            }
        }
        update mapProperties.values();
        
}