/*
*    Name             :     triggerOnCoaFyBalanceBeforeDelete 
*    Author           :     Mohd Anas
*    Date             :     29th June 2017
*    Description      :     Trigger to check that if COA FY Balance is referenced by any PO line Item or not; if it is then COA FY Balance cannot be deleted 
*/
trigger triggerOnCoaFyBalanceBeforeDelete on COA_FY_Balance__c (before delete) {
    Set<Id> coaBalIdSet = new Set<Id>();
    for(COA_FY_Balance__c coa :trigger.old)
           coaBalIdSet.add(coa.id);
    system.debug('coa IDS'+coaBalIdSet);
    Set<Id> coaBalMapedId = new Set<Id>();
    if(coaBalIdSet.size()>0){
       List<PO_Line_Item__c> poLineItem = new List<PO_Line_Item__c>();
       poLineItem = [Select COA_FY_Balance__c from PO_Line_Item__c where COA_FY_Balance__c in :coaBalIdSet];
       
        system.debug('poLineItem'+poLineItem);
        if(poLineItem.size()>0){
            for (PO_Line_Item__c poItem : poLineItem)
                coaBalMapedId.add(poItem.COA_FY_Balance__c);
        }
    }
    
    system.debug('coaBalMapedId'+coaBalMapedId);
    for(COA_FY_Balance__c coa :trigger.old)
        if(coaBalMapedId.contains(coa.id))
            coa.addError('Cannot delete because it is being referenced by PO Line Item');
}