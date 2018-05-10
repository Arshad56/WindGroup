trigger syncWithCondition on Checklist_Item__c (after update) {
	
    Set<Id> conditionIds = new Set<Id>();
    for(CheckList_Item__c cli:Trigger.New){
        if(cli.Handover_Condition__c!=null){
            conditionIds.add(cli.Handover_Condition__c);
        }
    }
    
    if(conditionIds.size()>0){        
        Map<Id,Conditions__c> conditionMap = new Map<Id,Conditions__c>([Select id,Unit__c,S_N__c,Condition__c,Description__c,Number__c from Conditions__c where id in:conditionIds]);
        List<Conditions__c> condtionList = new List<Conditions__c>();
        for(CheckList_Item__c cli:Trigger.New){
            if(conditionMap.containsKey(cli.Handover_Condition__c)){
                Conditions__c cd = conditionMap.get(cli.Handover_Condition__c);                        
                cd.Condition__c = cli.Condition__c;
                cd.Description__c = cli.Description__c;
                cd.Issue_Types__c = cli.Issue_Types__c;
                cd.Item_Type__c = cli.Item_Type__c;
                cd.Number__c = cli.Number__c;
                if(cli.SN__c!=null){
                    cd.S_N__c = Integer.valueOf(cli.SN__c);
                }
                condtionList.add(cd);
            }
        }                 
        if(condtionList.size()>0){
            update condtionList;
        }
    }
}