Global class CreateDailyCheckListBatch implements Database.batchable<sobject>,Schedulable{

    global void execute(SchedulableContext sc){
        
    }
                        
    global Database.QueryLocator start(Database.BatchableContext BC){
                return Database.getQueryLocator([Select id,Name,Type__c,Description__c from Checklist_Master__c where Type__c='Daily']);
    }
    
    global void execute(Database.BatchableContext BC, List<Checklist_Master__c> scope){
        
    }
    
    global void finish(Database.BatchableContext BC){}
}