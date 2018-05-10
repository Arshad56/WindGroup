trigger DupUnitLeasePeriod on Lease_Unit__c (before insert,before update) {
    Set<Id> untIds = new Set<Id>();
    Set<Id> leaseIds = new Set<Id>();
    for(Lease_Unit__c lu:Trigger.New){
		if(lu.Unit__c!=null && (Trigger.isInsert || lu.Unit__c!=Trigger.OldMap.get(lu.Id).Unit__c || lu.Fit_Out_Date__c!=Trigger.OldMap.get(lu.Id).Fit_Out_Date__c || lu.Lease_Start_Date__c!=Trigger.OldMap.get(lu.Id).Lease_Start_Date__c || lu.Lease_End_Date__c!=Trigger.OldMap.get(lu.Id).Lease_End_Date__c)){
            untIds.add(lu.Unit__c);
            leaseIds.add(lu.Lease_Agreement_No__c);
    	}
    }
    if(untIds.size()>0){
        Map<Id,Lease__c> leaseMap = new Map<Id,Lease__c>([Select id,Lease_Start_Date__c,Lease_End_Date__c from Lease__c where id in:leaseIds]);
        Map<Id,Units__c> unitMap = new Map<Id,Units__c>([Select id,name,Start_Date__c,End_Date__c,(Select id,name,Start_Date__c,End_Date__c from Units__r) from Units__c where id in:untIds]);
        System.debug('unitMap-->'+unitMap);
        List<Lease_Unit__c> lsUntList = [Select id,Name,Unit__c,Fit_Out_Date__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where Unit__c in:untIds and Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled'];
        Map<Id,List<Lease_Unit__c>> unitToLeaseUntMap = new Map<Id,List<Lease_Unit__c>>();
        if(lsUntList.size()>0){
            for(Lease_Unit__c lu:lsUntList){
                List<Lease_Unit__c> tempList = new List<Lease_Unit__c>();
                if(unitToLeaseUntMap.containsKey(lu.Unit__c)){
                    tempList.addAll(unitToLeaseUntMap.get(lu.Unit__c));
                }
                tempList.add(lu);
                unitToLeaseUntMap.put(lu.Unit__c,tempList);
            }
            
            for(Lease_Unit__c lu:Trigger.New){
            	String tempUniterror='';
            	String tempLeaseerror='';
            	String tempSplitUniterror = '';
                if(lu.Lease_Start_Date__c==null){
                    lu.Lease_Start_Date__c = leaseMap.get(lu.Lease_Agreement_No__c).Lease_Start_Date__c;
                }
                if(lu.Lease_End_Date__c==null){
                    lu.Lease_End_Date__c = leaseMap.get(lu.Lease_Agreement_No__c).Lease_End_Date__c;
                }
                
                if(lu.Unit__c!=null && lu.Lease_Start_Date__c!=null && lu.Lease_End_Date__c!=null && (Trigger.isInsert || lu.Unit__c!=Trigger.OldMap.get(lu.Id).Unit__c || lu.Lease_Start_Date__c!=Trigger.OldMap.get(lu.Id).Lease_Start_Date__c || lu.Lease_End_Date__c!=Trigger.OldMap.get(lu.Id).Lease_End_Date__c)){
                    System.debug('unitMap.containsKey(lu.Unit__c)-->'+unitMap.containsKey(lu.Unit__c));
                    if(unitMap.containsKey(lu.Unit__c)){
                        units__c unit = unitMap.get(lu.Unit__c);
                        Date stDate = (lu.Fit_Out_Date__c != null)?lu.Fit_Out_Date__c:lu.Lease_Start_Date__c;
                        if((stDate < unit.Start_Date__c || stDate > unit.End_Date__c || lu.Lease_End_Date__c < unit.Start_Date__c || lu.Lease_End_Date__c > unit.End_Date__c) ){
                            tempUniterror = 'Lease Unit Start and End Date should be within Unit Start and End Date.<br/>';
                        }
                        for(Units__c splitUn:unitMap.get(lu.Unit__c).Units__r){
                        	if((stDate <= splitUn.End_Date__c && splitUn.Start_Date__c <= lu.Lease_End_Date__c) ){
                        		if(tempSplitUniterror =='')
	                                	tempSplitUniterror = 'This unit is split in this duration';
			                	tempSplitUniterror += '<br/><b><a target="_blank" href="/'+splitUn.Id+'">'+splitUn.Name+'</a> </b> ';
							}
                        }
                    }
                    if(lu.Lease_Unit_Status__c != 'Vacant' && lu.Lease_Unit_Status__c !='Cancelled')
	                    if(unitToLeaseUntMap.containsKey(lu.Unit__c)){
	                    	Date luStrtDate = (lu.Fit_Out_Date__c != null)?lu.Fit_Out_Date__c:lu.Lease_Start_Date__c;
	                        for(Lease_Unit__c prevLeaseUnit:unitToLeaseUntMap.get(lu.Unit__c)){
	                        	Date prevStrtDate = (prevLeaseUnit.Fit_Out_Date__c != null)?prevLeaseUnit.Fit_Out_Date__c:prevLeaseUnit.Lease_Start_Date__c;
	                            if(lu.Id!=prevLeaseUnit.Id && (luStrtDate <= prevLeaseUnit.Lease_End_Date__c && prevStrtDate <= lu.Lease_End_Date__c)){
	                                if(tempLeaseerror =='')
	                                	tempLeaseerror = 'Lease Unit for this duration already exist.';
	                                tempLeaseerror += '<br/> <a target="_blank" href="/'+prevLeaseUnit.Id+'">'+prevLeaseUnit.Name+'</a>';
	                            }
	                        }
                   		}
				    if(tempSplitUniterror != '' || tempUniterror != '' || tempLeaseerror != '' ){
                    	lu.addError(tempUniterror + tempSplitUniterror +tempLeaseerror,false);
                    }
                }
            }
        }
    }
}