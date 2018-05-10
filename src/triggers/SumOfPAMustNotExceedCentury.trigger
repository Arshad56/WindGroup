/*
 *  Name        :   SumOfPAMustNotExceedCentury
 *  Author      :   Mohd Anas
 *  Date        :   13th July 2017
 *  Description :   Sum Of Payment Arrangement under a vendor must not exceed 100% while inserting or updating
 * 
 */ 
trigger SumOfPAMustNotExceedCentury on Payment_Arrangement__c (before insert,before Update) {
    if(Trigger.isBefore){
        Set<id> vendorAccIdSet = new Set<id>();
        for(Payment_Arrangement__c pa: trigger.new)
            vendorAccIdSet.add(pa.vendor_name__c);
        
        Map<id,Decimal> vendorToSumPA = new Map<id,Decimal>(); 
        
        if(Trigger.isInsert)
            for(AggregateResult ar: [SELECT vendor_name__c,Sum(Payment_Term__c) allPA 
                                     FROM Payment_Arrangement__c  
                                     WHERE vendor_name__c in :vendorAccIdSet 
                                     GROUP BY vendor_name__c])
                vendorToSumPA.put((ID)ar.get('vendor_name__c'),(Decimal)ar.get('allPA'));    
        
        if(Trigger.isUpdate)
            for(AggregateResult ar: [SELECT vendor_name__c,Sum(Payment_Term__c) allPA 
                                     FROM Payment_Arrangement__c  
                                     WHERE vendor_name__c in :vendorAccIdSet AND id not in :trigger.New 
                                     GROUP BY vendor_name__c])
                vendorToSumPA.put((ID)ar.get('vendor_name__c'),(Decimal)ar.get('allPA'));   
        
        if(vendorToSumPA.size()>0)
            for(Payment_Arrangement__c pa: trigger.new){
                if(pa.Payment_Term__c != NULL)
                    if((pa.Payment_Term__c+(vendorToSumPA.get(pa.Vendor_Name__c)!=NULL?vendorToSumPA.get(pa.Vendor_Name__c):0))>100)
                        pa.addError('Sum of Payment Term is exceeding 100%');
            }
    }
}