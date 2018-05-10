/*
*	Name 		:  threeQuoteUpdateOnPurchaseOrder
* 	Author		:	Mohd Anas
*	Date		:	30th June 2017
*	Description	:	This trigger updates the 3 quotes on Purchase order  
*					when there are three quote in the related object 
*					and each object has atleast 1 Attachment
*/

trigger threeQuoteUpdateOnPurchaseOrder on Attachment (after insert) {
    Set<id> attParentIds = new Set<Id>();
    Map<id,Integer> poToQuoteAttchCount=  new Map<id,Integer>();
    
    for(Attachment att : trigger.new)
        attParentIds.add(att.ParentId);
    
    if(attParentIds.size()>0){
        for(Quote__c q : [SELECT PO_No__c FROM Quote__c WHERE id in :attParentIds])
            poToQuoteAttchCount.put(q.PO_No__c,0);
        
        for(Quote__c q : [SELECT PO_No__c,(SELECT id FROM Attachments limit 1) FROM Quote__c WHERE PO_No__c in :poToQuoteAttchCount.keySet()]){
            if(q.Attachments.size()>0){
                if(poToQuoteAttchCount.containsKey(q.PO_No__c))
                    poToQuoteAttchCount.put(q.PO_No__c,(poToQuoteAttchCount.get(q.PO_No__c)+1));
                else
                    poToQuoteAttchCount.put(q.PO_No__c,1);
            }
        }
    }
    
    List<Purchase_order__c> poList = new List<Purchase_order__c>();
    if(poToQuoteAttchCount.keySet().size()>0){
        for(Purchase_Order__c po : [SELECT id,X3_Quotes__c
                                    FROM Purchase_Order__c 
                                    WHERE id in :poToQuoteAttchCount.keySet()]){
        	if(poToQuoteAttchCount.containsKey(po.id))
                if(poToQuoteAttchCount.get(po.id)>=3 && !po.X3_Quotes__c){
                    po.X3_Quotes__c = TRUE;
                    poList.add(po);
                }           
        }
    }
    if(poList.size()>0)
        update poList;
}