trigger DupLOIUnitPeriod on LOI_Unit__c (before insert,before update) {
    Set<Id> untIds = new Set<Id>();
    Set<Id> loiIds = new Set<Id>();
    for(LOI_Unit__c lu:Trigger.New){
        if(lu.Unit__c!=null && (Trigger.isInsert || lu.Unit__c!=Trigger.OldMap.get(lu.Id).Unit__c || lu.LOI_Start_Date__c!=Trigger.OldMap.get(lu.Id).LOI_Start_Date__c || lu.LOI_End_Date__c!=Trigger.OldMap.get(lu.Id).LOI_End_Date__c)){
            untIds.add(lu.Unit__c);
            System.debug('lu.Unit__c----@@'+lu.Unit__c);
            loiIds.add(lu.LOI_Agreement_No__c);
        }
    }
    
    if(untIds.size()>0){
        Map<Id,LOI__c> loiMap = new Map<Id,LOI__c>([Select id,LOI_Start_Date__c,LOI_End_Date__c from LOI__c where id in:loiIds]);
        Map<Id,Units__c> unitMap = new Map<Id,Units__c>([Select id,Start_Date__c,End_Date__c from Units__c where id in:untIds]);
        
        List<LOI_Unit__c> loiUntList = [Select id,Name,Unit__c,LOI_Start_Date__c,LOI_End_Date__c from LOI_Unit__c where Unit__c in:untIds];
        Map<Id,List<LOI_Unit__c>> unitToLOIUntMap = new Map<Id,List<LOI_Unit__c>>();
        
        if(loiUntList.size()>0){
            for(LOI_Unit__c lu:loiUntList){
                List<LOI_Unit__c> tempList = new List<LOI_Unit__c>();
                if(unitToLoiUntMap.containsKey(lu.Unit__c)){
                    tempList.addAll(unitToLoiUntMap.get(lu.Unit__c));
                }
                tempList.add(lu);
                unitToLoiUntMap.put(lu.Unit__c,tempList);
            }
            
            for(LOI_Unit__c lu:Trigger.New){
                if(lu.LOI_Start_Date__c==null){
                    lu.LOI_Start_Date__c = loiMap.get(lu.LOI_Agreement_No__c).LOI_Start_Date__c;
                }
                if(lu.LOI_End_Date__c==null){
                    lu.LOI_End_Date__c = loiMap.get(lu.LOI_Agreement_No__c).LOI_End_Date__c;
                }
                if(lu.Unit__c!=null && lu.LOI_Start_Date__c!=null && lu.LOI_End_Date__c!=null && (Trigger.isInsert || lu.Unit__c!=Trigger.OldMap.get(lu.Id).Unit__c || lu.LOI_Start_Date__c!=Trigger.OldMap.get(lu.Id).LOI_Start_Date__c || lu.LOI_End_Date__c!=Trigger.OldMap.get(lu.Id).LOI_End_Date__c)){
                    if(unitMap.containsKey(lu.Unit__c)){
                        units__c unit = unitMap.get(lu.Unit__c);
                        if(lu.LOI_Start_Date__c<unit.Start_Date__c || lu.LOI_Start_Date__c>unit.End_Date__c || lu.LOI_End_Date__c<unit.Start_Date__c || lu.LOI_End_Date__c>unit.End_Date__c){
                            lu.addError('LOI Unit Start and End Date should be within Unit Start and End Date.');
                        }
                    }
                    if(unitToLoiUntMap.containsKey(lu.Unit__c)){
                        for(LOI_Unit__c prevLoiUnit:unitToLoiUntMap.get(lu.Unit__c)){
                            if(lu.Id!=prevLoiUnit.Id && ((lu.LOI_Start_Date__c<=prevLoiUnit.LOI_Start_Date__c && lu.LOI_End_Date__c<=prevLoiUnit.LOI_End_Date__c && lu.LOI_End_Date__c>=prevLoiUnit.LOI_Start_Date__c) || (lu.LOI_Start_Date__c>=prevLoiUnit.LOI_Start_Date__c && lu.LOI_Start_Date__c<=prevLoiUnit.LOI_End_Date__c && lu.LOI_End_Date__c>=prevLOIUnit.LOI_End_Date__c) || (lu.LOI_Start_Date__c<prevLoiUnit.LOI_Start_Date__c && lu.LOI_End_Date__c>prevLoiUnit.LOI_End_Date__c) || (lu.LOI_Start_Date__c>=prevLoiUnit.LOI_Start_Date__c && lu.LOI_End_Date__c<=prevLoiUnit.LOI_End_Date__c))){
                                lu.addError('LOI Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+prevLoiUnit.Id+'">'+prevLoiUnit.Name+'</a> to view details.',false);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}