trigger CreateInvoicePDF on Rent_Roll__c (after update) {
    Set<Id> rentRollIds = new Set<Id>();
    for(Rent_Roll__c rr:Trigger.New){
        if(rr.Invoices_Generated__c && rr.Invoices_Generated__c!=Trigger.oldMap.get(rr.Id).Invoices_Generated__c){
            rentRollIds.add(rr.Id);
        }
    }
    if(rentRollIds.size()>0){
        DownloadInvoice.generatePDFAsAttachment(rentRollIds);
    }
}