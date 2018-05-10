trigger setLeaseUnitStatus on Lease_Unit__c (after insert) {
    Set<Id> leaseIds = new Set<Id>();
    Set<Id> unitIds = new Set<Id>();
    Map<Id,Id> childToParentLeaseMap = new Map<Id,Id>();
    Set<Id> precedentLeaseIds = new Set<Id>();
    Map<Id,List<Lease_Unit__c>> precLeaseUnitMap = new Map<Id,List<Lease_Unit__c>>();
    for(Lease_Unit__c lu:trigger.New){
        leaseIds.add(lu.Lease_Agreement_No__c);
    }
    
    List<Lease__c> leaseList = [Select id,Precedent_Lease__c from Lease__c where id in:leaseIds and Precedent_Lease__c!=null];
    for(Lease__c ls:leaseList){
        childToParentLeaseMap.put(ls.Id,ls.Precedent_Lease__c);
        precedentLeaseIds.add(ls.Precedent_Lease__c);
    }
    
    if(precedentLeaseIds.size()>0){
        for(Lease_Unit__c lu:[Select id,Lease_Agreement_No__c,Lease_Unit_Status__c,Unit__c from Lease_Unit__c where Lease_Agreement_No__c in:precedentLeaseIds]){
            List<Lease_Unit__c> tempList = new List<Lease_Unit__c>();
            if(precLeaseUnitMap.containsKey(lu.Lease_Agreement_No__c)){
                tempList.addAll(precLeaseUnitMap.get(lu.Lease_Agreement_No__c));
            }
            tempList.add(lu);
            precLeaseUnitMap.put(lu.Lease_Agreement_No__c,tempList);
        }
    }
    
    Map<Id,Lease_Unit__c> updateLeaseUnitMap = new Map<Id,Lease_Unit__c>();
    for(Lease_Unit__c lu:trigger.New){
        if(childToParentLeaseMap.containsKey(lu.Lease_Agreement_No__c)){
            if(precLeaseUnitMap.containsKey(childToParentLeaseMap.get(lu.Lease_Agreement_No__c))){
                for(Lease_Unit__c oldLu:precLeaseUnitMap.get(childToParentLeaseMap.get(lu.Lease_Agreement_No__c))){
                    if(lu.Unit__c==oldLu.Unit__c && (oldLu.Lease_Unit_Status__c=='New' || oldLu.Lease_Unit_Status__c=='Vacant')){
                        oldLu.Lease_Unit_Status__c = 'Renewed';
                        updateLeaseUnitMap.put(oldLu.Id,oldLu);
                    }else{
                        if(oldLu.Lease_Unit_Status__c!='Renewed' && oldLu.Lease_Unit_Status__c!='Replaced'){
                            oldLu.Lease_Unit_Status__c = 'Vacant';
                            updateLeaseUnitMap.put(oldLu.Id,oldLu);
                        }
                    }
                }
            }
        }else{
            if(lu.Unit__c!=null){
                unitIds.add(lu.Unit__c);
            }
        }
    }
    Map<Id,List<Lease_Unit__c>> unitToLuMap = new Map<Id,List<Lease_Unit__c>>();
    if(unitIds.size()>0){
        for(Lease_Unit__c lu:[Select id,Unit__c,Lease_Unit_Status__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where Unit__c in:unitIds]){
            List<Lease_Unit__c> tempList = new List<Lease_Unit__c>();
            if(unitToLuMap.containsKey(lu.Unit__c)){
                tempList.addAll(unitToLuMap.get(lu.Unit__c));
            }
            tempList.add(lu);
            unitToLuMap.put(lu.Unit__c,tempList);
        }
        
        for(Lease_Unit__c lu:trigger.New){
            if(unitToLuMap.containsKey(lu.Unit__c) && !childToParentLeaseMap.containsKey(lu.Lease_Agreement_No__c)){
                Integer selLuDaysDiff = 0;
                Lease_Unit__c selectedLu = new Lease_Unit__c();
                for(Lease_Unit__c oldLu:unitToLuMap.get(lu.Unit__c)){
                    if(lu.Id!=oldLu.Id && lu.Lease_Start_Date__c!=null){
                        Integer daysDiff = oldLu.Lease_End_Date__c.daysBetween(lu.Lease_Start_Date__c);
                        if(daysDiff>0){
                            if(selLuDaysDiff>0){
                                if(daysDiff<selLuDaysDiff){
                                    selLuDaysDiff = daysDiff;
                                    selectedLu = oldLu;
                                }
                            }else{
                                selLuDaysDiff = daysDiff;
                                selectedLu = oldLu;
                            }
                        }
                    }
                }
                
                if(selectedLu.Id!=null){
                    selectedLu.Lease_Unit_Status__c = 'Replaced';
                    updateLeaseUnitMap.put(selectedLu.Id,selectedLu);
                }
            }
        }
    }
    
    if(updateLeaseUnitMap.size()>0){
        update updateLeaseUnitMap.values();
    }
}