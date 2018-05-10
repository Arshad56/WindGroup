trigger PosIdSetupTrigger on Lease_POS__c (before insert) {
    Set<Id> leaseUnitIds = new Set<Id>();
    Set<string> PosIds = new Set<string>();
    Set<Id> luIds = new Set<Id>();
    for(Lease_POS__c lp:Trigger.New){
        if(lp.Generate_POS_ID__c=='Yes'){
            if(lp.Lease_Unit__c!=null){
                if(lp.Name!='--system generated--'){
                    lp.Name.addError('Do not enter POS ID If you want system to generate it.');
                }else{
                    leaseUnitIds.add(lp.Lease_Unit__c);
                }
            }
        }else if(lp.Generate_POS_ID__c=='No'){
            PosIds.add(lp.Name);
            if(lp.Lease_Unit__c!=null){
                luIds.add(lp.Lease_Unit__c);
            }
        }        
    }
    
    if(leaseUnitIds.size()>0){
        Set<Id> propIds = new Set<Id>();
        Map<Id,Id> propToLuMap = new Map<Id,Id>();
        for(Lease_Unit__c lu:[Select id,Lease_Agreement_No__r.Property__c from Lease_Unit__c where id in:leaseUnitIds]){
            propIds.add(lu.Lease_Agreement_No__r.Property__c);
            propToLuMap.put(lu.Id,lu.Lease_Agreement_No__r.Property__c);
        }
        
        Map<Id,Property__c> PropertyMap = new Map<Id,Property__c>([Select id,Short_Code__c,POS_Id_Index__c from Property__c where id in:propIds]);
        
        for(Lease_POS__c lp:Trigger.New){
            if(lp.Generate_POS_ID__c=='Yes'){
                if(lp.Lease_Unit__c!=null){
                    if(lp.Name=='--system generated--'){
                        if(propToLuMap.containsKey(lp.Lease_Unit__c)){
                            if(PropertyMap.containsKey(propToLuMap.get(lp.Lease_Unit__c))){
                                property__c prop = PropertyMap.get(propToLuMap.get(lp.Lease_Unit__c));
                                Integer IntIndex = 1;
                                if(prop.POS_Id_Index__c!=null && prop.POS_Id_Index__c>0){
                                    intIndex = Integer.valueOf(prop.POS_Id_Index__c);
                                }
                                
                                Integer indexSize = string.valueOf(intIndex).length();
                                
                                string index = '';
                                for(integer i =1;i<=6-indexSize;i++){
                                    index += '0';
                                }
                                index += string.valueOf(intIndex);
                                                
                                prop.POS_Id_Index__c = intIndex + 1;
                                lp.Name = prop.Short_Code__c + '-POS-'+index;
                            }
                        }
                    }
                }
            }
        }
        update PropertyMap.values();
    }
    
    if(posIds.size()>0){
        Map<Id,Lease_Unit__c> luMap = new Map<Id,Lease_Unit__c>([Select id,Lease_Agreement_No__r.Tenant__c from Lease_Unit__c where id in:luIds]);
        Map<string,List<Lease_POS__c>> lsPOSMap = new Map<string,List<Lease_POS__c>>();
        for(Lease_POS__c lp:[Select id,Name,Start_Date__c,End_Date__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant__c from Lease_POS__c where name in:posIds]){
            List<Lease_POS__c> tempList =new List<Lease_POS__c>();
            if(lsPOSMap.containsKey(lp.Name)){
                tempList.addAll(lsPOSMap.get(lp.Name));
            }
            tempList.add(lp);
            lsPOSMap.put(lp.Name,tempList);
        }
        for(Lease_POS__c lp:Trigger.New){
            if(lp.Generate_POS_ID__c=='No'){
                if(lp.Name!=null && lsPOSMap.containsKey(lp.Name)){
                    for(Lease_POS__c existingLP:lsPOSMap.get(lp.Name)){
                        if(luMap.containsKey(lp.Lease_Unit__c)){
                            if(luMap.get(lp.Lease_Unit__c).Lease_Agreement_No__r.Tenant__c!=existingLP.Lease_Unit__r.Lease_Agreement_No__r.Tenant__c){
                                lp.addError('Same POS ID for different tenant is already present.Please enter different POS ID.',false);
                                break;
                            }
                        }
                        if(lp.Start_Date__c!=null && lp.End_Date__c!=null){
                            if((lp.start_Date__c>=existingLP.Start_Date__c && lp.Start_Date__c<=existingLP.End_Date__c) || (lp.start_Date__c<existingLP.Start_Date__c && lp.End_Date__c>=existingLP.Start_Date__c)){
                                lp.addError('Lease POS for this duration already exist.<br/>Please click on <a target="_blank" href="/'+existingLP.Id+'">'+existingLP.Name+'</a> to view details.',false);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}