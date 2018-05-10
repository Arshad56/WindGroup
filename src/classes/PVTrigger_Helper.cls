public class PVTrigger_Helper {
    public static void rollupDepositAndInvoice(List<Payment_Voucher__c> pvList, Map<Id,Payment_Voucher__c> oldpv){
        Set<Id> depIds = new Set<Id>();
        Set<Id> invIds = new Set<Id>();
        
        List<Payment_Voucher__c> newPVList = new List<Payment_Voucher__c>();
        
        if(pvList != null ){
            newPVList = pvList;
        }else{
            newPVList = oldpv.values();
        }
        
        if(newPVList != null && pvList != null)
        for(Payment_Voucher__c pv:pvList){
           // Comment code for Credit Note Refund
           if(pv.Invoice__c != null )
                invIds.add(pv.Invoice__c);
            if(oldpv.containskey(pv.Id) && oldpv.get(pv.Id).Invoice__c != pv.Invoice__c)
                invIds.add(pv.Invoice__c);
            
            if(pv.Deposit__c != null)
                depIds.add(pv.Deposit__c);
            if(oldpv.containskey(pv.Id) && oldpv.get(pv.Id).Deposit__c != pv.Deposit__c)
                depIds.add(pv.Deposit__c);
        }
        Map<Id,Invoice__c> invRollMap = new Map<Id,Invoice__c>([select Id,Total_Refunded_Amount__c,Currency_Code__c,Exchange_Rate__c, (Select Id,Payment_Voucher__c,Status__c,Amount__c,Refunded_Amount__c, Currency_Code__c,Exchange_Rate__c,Void__c from Payment_Vouchers__r where Void__c = false ) from Invoice__c where id in: invIds]);
        Map<Id,Deposit__c> depRollMap = new Map<Id,Deposit__c>([select Id,Total_Refunded_Amount__c,Currency_Code__c,(Select Id,Status__c,Amount__c,Payment_Voucher__c, Refunded_Amount__c, Currency_Code__c,Exchange_Rate__c,Void__c from Payment_Vouchers__r  where Void__c = false ) from Deposit__c where id in: depIds]);
        
        for(Deposit__c dp:depRollMap.values()){
            dp.Total_Refunded_Amount__c = 0;
            for(Payment_Voucher__c pv:dp.Payment_Vouchers__r){
                if(pv.Payment_Voucher__c == null){//Child PV refund amount should not be roll up to deposit.
                        dp.Total_Refunded_Amount__c += (pv.Amount__c != null)?pv.Amount__c:0;  
                }
            }
        }
        //Comment code for Credit Note Refund
          for(Invoice__c inv:invRollMap.values()){
            inv.Total_Refunded_Amount__c = 0;
            for(Payment_Voucher__c pv:inv.Payment_Vouchers__r){
                if(pv.Payment_Voucher__c == null)
                    inv.Total_Refunded_Amount__c += (pv.Amount__c != null)?pv.Amount__c:0;
            }
        }
        update depRollMap.values();
        update invRollMap.values();
    }
}