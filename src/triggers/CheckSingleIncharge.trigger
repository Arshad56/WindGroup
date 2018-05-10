trigger CheckSingleIncharge on Team_Member__c (before insert, before update) {
	Set<Id> tmIds= new Set<Id>();
    for(Team_Member__c tm: Trigger.new){
    	if(tm.Team__c != null && tm.In_Charge__c){
    		tmIds.add(tm.Team__c);
    	}
    }
    List<Action_Taker__c> teams= [select Id,(select Id,Name,Team__c,In_Charge__c from Team_Members__r where In_Charge__c = true) from Action_Taker__c where Id =: tmIds];
    Map<Id, Team_Member__c> hasInCharge= new Map<Id, Team_Member__c>();
    for(Action_Taker__c act: teams){
    	for(Team_Member__c tm: act.Team_Members__r){
    		if(tm.In_Charge__c){
    			hasInCharge.put(act.Id, tm);
    		}
    	}
    }
    for(Team_Member__c tm: Trigger.new){
    	if(hasInCharge.containsKey(tm.Team__c) && tm.In_Charge__c){
    		tm.addError(' Incharge is already selected.<br/>Please click on <a target="_blank" href="/'+hasInCharge.get(tm.Team__c).Id+'">'+hasInCharge.get(tm.Team__c).Name+'</a> to view details.',false);
    	}
    }
}