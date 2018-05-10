/*
 *      Name            :       poPaymentArrangementTrigger
 *      Author          :       Mohd Anas
 *      Date            :       7th July 2017
 *      Description     :       1. Prevents the deletion of PO Payment Arrangement if Purchase Orde Status is not Draft or Rejected
 *                              2. Trigger on before insert to check the Payment Term should not exceed 100%
*/
trigger poPaymentArrangementTrigger on PO_Payment_Arrangement__c (before delete,before Insert,before Update) {
    
    if(Trigger.isDelete){
        Set<id> poIdSet = new Set<id>();
        for(PO_Payment_Arrangement__c poPa: trigger.old)
            poIdSet.add(poPa.purchase_order__c);
        
        
        Map<id,String> poStatusMap = new Map<id,String>();
        List<Purchase_order__c> poList = new List<Purchase_order__c>();
        
        if(poIdSet.size()>0)
            poList = [SELECT id,Status__c from purchase_order__c where id in :poIdSet AND Status__c not in ('Draft','Rejected')];
        
       for(purchase_order__c po : poList)
           poIdSet.remove(po.id);
       
        for(PO_Payment_Arrangement__c poPa: trigger.old){
            if(!poIdSet.contains(poPa.Purchase_Order__c))
                poPa.addError('You can only delete this record when PO status is either Draft or Rejected');
        }
        
    }
    /*
     *      Edited          :       14th July 2017
     *      Description     :       Trigger on before insert to check the Payment Term should not exceed 100%
    */
    if(Trigger.isBefore && !Trigger.isDelete){
        Set<id> poIdSet = new Set<id>();
            for(PO_Payment_Arrangement__c poPa: trigger.New)
                poIdSet.add(poPa.purchase_order__c);
            
        
        if(Trigger.isInsert || Trigger.isUpdate){
            Map<Id,Decimal> sumOfPayTermOnvendor = new Map<Id,Decimal>();            
            if(Trigger.isInsert){
                for(AggregateResult ar : [SELECT Purchase_order__c,sum(payment_term__c) total FROM PO_Payment_Arrangement__c WHERE Purchase_order__c in :poIdSet GROUP BY Purchase_order__c])
                    sumOfPayTermOnvendor.put((Id)ar.get('Purchase_order__c'),(Decimal)ar.get('total'));
            }else{
                for(AggregateResult ar : [SELECT Purchase_order__c,sum(payment_term__c) total FROM PO_Payment_Arrangement__c WHERE Purchase_order__c in :poIdSet AND id not in :trigger.New GROUP BY Purchase_order__c])
                sumOfPayTermOnvendor.put((Id)ar.get('Purchase_order__c'),(Decimal)ar.get('total'));
            }
            
            if(sumOfPayTermOnvendor.size()>0)
                for(Po_Payment_Arrangement__c pa: trigger.new){
                    if(((pa.Payment_Term__c!=null?pa.Payment_Term__c:0)+(sumOfPayTermOnvendor.get(pa.Purchase_order__c)!=null?sumOfPayTermOnvendor.get(pa.Purchase_order__c):0))>100)
                        pa.addError('Sum of Payment Term must not exceed 100%');
                }
        }
        
        /*if(Trigger.isInsert){            
            
            for(AggregateResult ar : [SELECT Purchase_order__c,sum(payment_term__c) total FROM PO_Payment_Arrangement__c WHERE Purchase_order__c in :poIdSet GROUP BY Purchase_order__c])
                sumOfPayTermOnvendor.put((Id)ar.get('Purchase_order__c'),(Decimal)ar.get('total'));
            
            if(sumOfPayTermOnvendor.size()>0)
                for(Po_Payment_Arrangement__c pa: trigger.new){
                    if(((pa.Payment_Term__c!=null?pa.Payment_Term__c:0)+(sumOfPayTermOnvendor.get(pa.Purchase_order__c)!=null?sumOfPayTermOnvendor.get(pa.Purchase_order__c):0))>100)
                        pa.addError('Sum of Payment Term must not exceed 100%');
                }
        }
        else if(Trigger.isUpdate){
            
            for(AggregateResult ar : [SELECT Purchase_order__c,sum(payment_term__c) total FROM PO_Payment_Arrangement__c WHERE Purchase_order__c in :poIdSet AND id not in :trigger.New GROUP BY Purchase_order__c])
                sumOfPayTermOnvendor.put((Id)ar.get('Purchase_order__c'),(Decimal)ar.get('total'));
            
            if(sumOfPayTermOnvendor.size()>0)
                for(Po_Payment_Arrangement__c pa: trigger.new){
                    if(((pa.Payment_Term__c!=null?pa.Payment_Term__c:0)+(sumOfPayTermOnvendor.get(pa.Purchase_order__c)!=null?sumOfPayTermOnvendor.get(pa.Purchase_order__c):0))>100)
                        pa.addError('Sum of Payment Term is exceeding 100%');
                }
        }*/
    }
        
}