public with sharing class RollupAmountCashDetails_Helper {
    /*public static void rollupAmount(Set<Id> invIds,Set<Id> depIds){
        System.debug('invIds-->'+invIds);
        System.debug('depIds-->'+depIds);
        
        List<AggregateResult> invResults     = [SELECT  Invoice__c, SUM(Amount_Paid__c) sum FROM Cash_Detail__c where Invoice__c=: invIds and Void__c = false  group by Invoice__c];
        List<AggregateResult> depResults     = [SELECT  Deposit__c, SUM(Amount_Paid__c) sum FROM Cash_Detail__c where Deposit__c=: depIds and Void__c = false  group by Deposit__c];
        System.debug('invResults--> '+ invResults);
        System.debug('depResults--> '+ depResults);
        
        Map<Id,Invoice__c > invRollMap = new Map<Id,Invoice__c>([select Id,Amount_Paid__c from Invoice__c where id =: invIds]);
        Map<Id,Deposit__c > depRollMap = new Map<Id,Deposit__c>([select Id,Amount_Paid__c from Deposit__c where id =: depIds]);
        Id crRollIds;
        System.debug('invRollMap--> '+ invRollMap);
        System.debug('depRollMap--> '+ depRollMap);
        for (AggregateResult ar : invResults){
            crRollIds =String.valueof(ar.get('Invoice__c'));
            if(crRollIds != null){
                if(invRollMap.containsKey(crRollIds)){
                    invRollMap.get(crRollIds).Amount_Paid__c = (decimal)ar.get('sum');
                }else{
                    invRollMap.get(crRollIds).Amount_Paid__c = 0;
                }
            }
        }
        if(invResults.size() == 0 && invRollMap != null){
            for(Invoice__c cr: invRollMap.values()){
                invRollMap.get(cr.Id).Amount_Paid__c = 0;
            }
        }
        for (AggregateResult ar : depResults){
            crRollIds =String.valueof(ar.get('Deposit__c'));
            if(crRollIds != null){
                if(depRollMap.containsKey(crRollIds)){
                    depRollMap.get(crRollIds).Amount_Paid__c = (decimal)ar.get('sum');
                }else{
                    depRollMap.get(crRollIds).Amount_Paid__c = 0;
                }
            }
        }
        if(depResults.size() == 0 && depRollMap != null){
            for(Deposit__c cr: depRollMap.values()){
                    depRollMap.get(cr.Id).Amount_Paid__c = 0;
            }
        }
    
        try{
            update invRollMap.values();
            update depRollMap.values();
            System.debug('invRollMap--> '+ invRollMap);
            System.debug('depRollMap--> '+ depRollMap);
        }catch(Exception e){
            System.debug('Exception in rollupAmount:'+e.getMessage());
        }
    }*/
    
    public static void rollupAmount(Set<Id> invIds,Set<Id> depIds,Set<Id> pvIds){
        List<Cash_Detail__c> cashDetList = [Select id,Currency_Code__c,Amount_Paid__c,Invoice__c,Deposit__c,Payment_Voucher__c from Cash_Detail__c where Void__c=false and (Invoice__c in:invIds or Deposit__c in:depIds or Payment_Voucher__c in:pvIds)];
        if(cashDetList.size()>0){
            Map<Id,Invoice__c> invRollMap = new Map<Id,Invoice__c>([select Id,Amount_Paid__c,Currency_Code__c,Exchange_Rate__c from Invoice__c where id in: invIds]);
            Map<Id,Deposit__c> depRollMap = new Map<Id,Deposit__c>([select Id,Amount_Paid__c,Currency_Code__c,Exchange_Rate__c from Deposit__c where id in: depIds]);
            Map<Id,Payment_Voucher__c> pvRollMap = new Map<Id,Payment_Voucher__c>([Select id,Currency_Code__c,Exchange_Rate__c,Refunded_Amount__c from Payment_Voucher__c where id in:pvIds]);
            
            for(Invoice__c inv:invRollMap.values()){
                inv.Amount_Paid__c = 0;                
            }
            
            for(Deposit__c dp:depRollMap.values()){
                dp.Amount_Paid__c = 0;                
            }
            
            for(Payment_Voucher__c pv:pvRollMap.values()){
                pv.Refunded_Amount__c = 0;
            }
            
            for(Cash_Detail__c cd:cashDetList){
                if(cd.Invoice__c!=null && invRollMap.containsKey(cd.Invoice__c)){
                    Invoice__c inv = invRollMap.get(cd.Invoice__c);
                    if(inv.Currency_Code__c!=label.Default_Currency && cd.Currency_Code__c==label.Default_Currency && inv.Exchange_Rate__c>0){
                        inv.Amount_Paid__c += (cd.Amount_Paid__c/inv.Exchange_Rate__c);
                    }else{
                        inv.Amount_Paid__c += cd.Amount_Paid__c;
                    }
                    invRollMap.put(cd.Invoice__c,inv);
                }else if(cd.Deposit__c!=null && depRollMap.containsKey(cd.Deposit__c)){
                    Deposit__c dep = depRollMap.get(cd.Deposit__c);
                    if(dep.Currency_Code__c!=label.Default_Currency && cd.Currency_Code__c==label.Default_Currency && dep.Exchange_Rate__c>0){
                        dep.Amount_Paid__c += (cd.Amount_Paid__c/dep.Exchange_Rate__c);
                    }else{
                        dep.Amount_Paid__c += cd.Amount_Paid__c;
                    }
                    depRollMap.put(cd.Deposit__c,dep);
                }else if(cd.Payment_Voucher__c!=null && pvRollMap.containsKey(cd.payment_Voucher__c)){
                    Payment_Voucher__c pv = pvRollMap.get(cd.payment_Voucher__c);
                    if(pv.Currency_Code__c!=label.Default_Currency && cd.Currency_Code__c==label.Default_Currency && pv.Exchange_Rate__c>0){
                        pv.Refunded_Amount__c += (cd.Amount_Paid__c/pv.Exchange_Rate__c);
                    }else{
                        pv.Refunded_Amount__c += cd.Amount_Paid__c;
                    }
                    pvRollMap.put(cd.payment_Voucher__c,pv);
                }
            }
            
            if(invRollMap.size()>0){
                update invRollMap.values();
            }
            if(depRollMap.size()>0){
                update depRollMap.values();
            }
            
            if(pvRollMap.size()>0){
                update pvRollMap.values();
            }
        }
    }
}