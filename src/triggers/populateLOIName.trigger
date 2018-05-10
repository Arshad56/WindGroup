trigger populateLOIName on LOI__c (before insert) {
    Set<Id> propIds = new Set<Id>();
        for(LOI__c loi: trigger.new){
            if(loi.Property__c != null && !propIds.contains(loi.Property__c))
                propIds.add(loi.Property__c);
        }
        
        Map<Id, Property__c> listProperties= new Map<Id, Property__c>([select Id,Short_Code__c, LOI_Index__c from Property__c where id =:propIds]);
        Map<Id, Property__c> mapProperties = new Map<Id, Property__c>();
        Map<Id, Integer> mapCount = new Map<Id, Integer>();
        String code;
        
        for(LOI__c loi: trigger.new){
            if(loi.Property__c != null && listProperties.containsKey(loi.Property__c)){
                code  =  listProperties.get(loi.Property__c).Short_Code__c;
                code += '-LOI-';
                code += System.today().Year();
                code += (System.today().Month()<10?'0'+System.today().Month():''+System.today().Month());
                
                code += '-';
                Integer temp;
                if(mapProperties.containsKey(listProperties.get(loi.Property__c).Id)){
                    temp = Integer.valueOf(mapProperties.get(listProperties.get(loi.Property__c).Id).Request_Index__c);
                }else{
                    temp =  Integer.valueof(listProperties.get(loi.Property__c).LOI_Index__c);
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
                if(listProperties.get(loi.Property__c).Id != null){
                    Property__c pr = new Property__c();
                    pr.Id = listProperties.get(loi.Property__c).Id;
                    if(mapProperties.containsKey(pr.Id)){
                        //pr.Request_Index__c = temp;
                        mapProperties.get(pr.Id).LOI_Index__c += 1;
                    }else{
                        pr.LOI_Index__c = temp;
                        mapProperties.put(pr.Id, pr);
                    }
                    
                }
            }
        }
        update mapProperties.values();
        
}