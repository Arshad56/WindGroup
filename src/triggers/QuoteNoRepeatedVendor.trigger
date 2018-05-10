/*
 *  Name         : QuoteNoRepeatedVendor 
 *  Author       : Mohd Anas
 *  Created Date : 10th July 2017 
 *  Description  : This trigger is used to Prevent the insertion of multiple Quotes with same vendor under PO
 *
*/
trigger QuoteNoRepeatedVendor on Quote__c (before insert,before update) {

            Set<id> poIdSet = new Set<id>();
            for(Quote__c q : trigger.new)
                poIdSet.add(q.PO_No__c);
            
            List<Quote__c> quoteList = new List<Quote__c>();
            
            if(trigger.isInsert)
                quoteList = [SELECT vendor_name__c,PO_No__c FROM Quote__c WHERE PO_No__c in :poIdSet];
            else if(trigger.isUpdate)
                quoteList = [SELECT vendor_name__c,PO_No__c FROM Quote__c WHERE PO_No__c in :poIdSet AND id not in:trigger.new]; 
                 
            set<string> poToVendor = new Set<string>();
        
            for(Quote__c qL :quoteList)
                poToVendor.add(qL.PO_No__c+','+qL.Vendor_Name__c);
            
        
            if(poToVendor.size()>0)
                for(Quote__c q : trigger.New)
                    if(poToVendor.contains(q.PO_No__c+','+q.Vendor_Name__c))
                        q.addError('Quote with this Vendor already exist');
         
          
}