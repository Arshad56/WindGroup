trigger CreateCashReceiptPDF on Cash_Receipt__c (after insert,after update){
    Set<Id> cashRepIds = new Set<Id>();
    for(Cash_Receipt__c cr:Trigger.New){
        if(cr.Cash_Receipt_Generated__c && (Trigger.IsInsert || cr.Cash_Receipt_Generated__c!=Trigger.OldMap.get(cr.Id).Cash_Receipt_Generated__c)){
            cashRepIds.add(cr.Id);
        }
    }
    
    if(cashRepIds.size()>0){
        DownloadInvoice.generateReceiptAsAttachment(cashRepIds);
    }
}