/*Author - Rajesh Sahu
Created Date - 22-3-2017   
Description- this trigger is used to rollup amount based on picklist value in Journal_Entry__c object if picklist value is posted
                 then Posted Dr,Posted cr field updated and in case of unposted picklist field value Unposted Dr, Unposted cr field update.
*/

trigger JournalEntryTrigger on Journal_Entry__c (after insert, after update, after delete, after undelete) {
    set<id> coaBalIdSet = new set<id>();
    
    list<Journal_Entry__c> jourEntryLst = trigger.isdelete ? trigger.old : trigger.new;
    for(Journal_Entry__c je: jourEntryLst){        
        if(trigger.isUpdate && je.COA_Balance__c != Trigger.oldMap.get(je.Id).COA_Balance__c && Trigger.oldMap.get(je.Id).COA_Balance__c != null)
            coaBalIdSet.add(Trigger.oldMap.get(je.Id).COA_Balance__c); 
        
        if(je.COA_Balance__c != null)
            coaBalIdSet.add(je.COA_Balance__c);
        
    }
    
    if(coaBalIdSet.size() > 0){
        map<Id,COA_Balance__c> updCoaBalanceMap = new map<Id,COA_Balance__c>();
        for(Id coaID : coaBalIdSet){
            COA_Balance__c coaBalObj = new COA_Balance__c(Id=coaID);
            coaBalObj.Posted_Dr__c = 0;
            coaBalObj.Posted_Cr__c = 0;
            coaBalObj.Unposted_Cr__c = 0;
            coaBalObj.Unposted_Dr__c = 0;
            updCoaBalanceMap.put(coaID ,coaBalObj);
        }
        
        for(AggregateResult agRes : [select COA_Balance__c,Posting_Status__c,sum(Dr_Amount__c) drTot,sum(Cr_Amount__c) crSum
                                     from Journal_Entry__c 
                                     where COA_Balance__c IN :coaBalIdSet and (Posting_Status__c ='Posted' OR Posting_Status__c ='Unposted') 
                                     group by COA_Balance__c,Posting_Status__c]){
            
            Id coaBalId = (Id)agRes.get('COA_Balance__c');   
            String jouEntryStatus = (String)agRes.get('Posting_Status__c');
            Double dramount  = (Double)agRes.get('drTot');
            Double cramount  = (Double)agRes.get('crSum');
                                     
            COA_Balance__c coaBalObj = new COA_Balance__c();
            if(updCoaBalanceMap.containsKey(coaBalId))
                coaBalObj = updCoaBalanceMap.get(coaBalId);
                
            coaBalObj.Id = coaBalId;
            if(jouEntryStatus == 'Posted'){
                coaBalObj.Posted_Dr__c = dramount;
                coaBalObj.Posted_Cr__c = cramount;
            }else if(jouEntryStatus == 'Unposted'){
                coaBalObj.Unposted_Cr__c = cramount;
                coaBalObj.Unposted_Dr__c = dramount;
            }
            
            updCoaBalanceMap.put(coaBalId,coaBalObj); 
        }
        
        if(updCoaBalanceMap.size() > 0)
            update updCoaBalanceMap.values();
    }
}