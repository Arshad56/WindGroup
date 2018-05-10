public with sharing class MainTriggerRentRollDetails_Helper {
    public static void rollupAmount(Set<Id> rentRollDetIdList){
	    List<AggregateResult> results     = [SELECT  Rent_Roll__c, SUM(Comm_Tax_Amount__c) commSum, SUM(Amount__c) sum FROM Rent_Roll_Detail__c where Rent_Roll__c=: rentRollDetIdList and Status__c != 'Rejected' and Voided__c != true  group by Rent_Roll__c];
		Map<Id,Rent_Roll__c > rentRollMap = new Map<Id,Rent_Roll__c>([select Id,Total_Amount__c,Total_Comm_Tax__c from Rent_Roll__c where id =: rentRollDetIdList]);
		Id rentRollIds;
		System.debug('results-->'+results);
		System.debug('rentRollMap-->'+rentRollMap);
		Set<String> tempIds = new Set<String>();
		for (AggregateResult ar : results){
			rentRollIds =String.valueof(ar.get('Rent_Roll__c'));
			tempIds.add(rentRollIds);
			if(rentRollMap.containsKey(rentRollIds)){
				rentRollMap.get(rentRollIds).Total_Amount__c = (decimal)ar.get('sum');
				rentRollMap.get(rentRollIds).Total_Comm_Tax__c = (decimal)ar.get('commSum');
			}
		}
		for (Id ids : rentRollMap.keySet()){
			if(!tempIds.contains(ids)){
				rentRollMap.get(ids).Total_Amount__c = 0;
				rentRollMap.get(ids).Total_Comm_Tax__c = 0;
			}
		}
		System.debug('rentRollMap-->'+rentRollMap);
		try{
			update rentRollMap.values();
			Utility.NfyBillExeRun = true;
	    }catch(Exception e){
	        System.debug('Exception in rollupAmount:'+e.getMessage());
	    }
    }
    
    public static void makeRentScheduleBlank(Set<Id> voidedIds){
    	
    	List<Rent_Schedules__c> listRentSchedules = [select Id, Rent_Roll_Detail__c from Rent_Schedules__c where Rent_Roll_Detail__c =: voidedIds];
    	
    	for(Rent_Schedules__c rs : listRentSchedules){
    		rs.Rent_Roll_Detail__c = null;
    		rs.Rent_Roll__c = null;
    		rs.Approved__c = false;
    	}
    	
    	try{
    		update listRentSchedules;
    	}catch(Exception e){
    		System.debug('Exception in makeRentScheduleBlank:'+e.getMessage());
    	}
    }
}