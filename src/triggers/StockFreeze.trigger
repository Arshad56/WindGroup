trigger StockFreeze on Stock__c (after update) {
    List<Stock_Freeze__c> stockFreezeList = new List<Stock_Freeze__c>();
    Set<Id> stockIds = new Set<Id>();
    for(Stock__c stk:Trigger.New){
        if(stk.Stock_Freeze__c!=Trigger.oldMap.get(stk.Id).Stock_Freeze__c){
            if(stk.Stock_Freeze__c){
                Stock_Freeze__c sf = new Stock_Freeze__c();
                sf.Stock__c = stk.Id;
                sf.Start_Date__c = system.now();
                stockFreezeList.add(sf);
            }else{
                stockIds.add(stk.Id);
            }
        }
    }
    
    if(stockIds.size()>0){
        for(Stock__c st:[Select id,(Select id,Start_Date__c,End_Date__c from Stock_Freeze__r order by CreatedDate desc limit 1) from Stock__c where id in:stockIds]){
            if(st.Stock_Freeze__r.size()>0){
                st.Stock_Freeze__r[0].End_Date__c = system.Now();
                stockFreezeList.add(st.Stock_Freeze__r[0]);
            }
        }        
    }
    
    upsert stockFreezeList;
}