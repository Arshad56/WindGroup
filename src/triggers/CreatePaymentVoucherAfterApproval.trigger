trigger CreatePaymentVoucherAfterApproval on Deposit__c (after update) {
    List<Payment_Voucher__c> pvList = new List<Payment_Voucher__c>();
    Map<string,Exchange_Rate__c> exgRateMap = new Map<string,Exchange_Rate__c>();
    for(Exchange_Rate__c exgRate:[Select id,Conversion_Rate__c,Start_Date_Time__c,Currency_Code__c from Exchange_Rate__c where Applicable_Function__c = 'Operations' and Start_Date_Time__c<=:system.now() order By Start_Date_Time__c desc]){
        if(!exgRateMap.containsKey(exgRate.Currency_Code__c)){
            exgRateMap.put(exgRate.Currency_Code__c,exgRate);
        }
    }
    for(Deposit__c dp:Trigger.new){
        if(dp.Requested_Amount__c!=null && dp.Refund_Mode__c!=null && dp.Refund_Status__c=='Approved' && dp.Refund_Status__c!=Trigger.oldMap.get(dp.Id).Refund_Status__c){
            Payment_Voucher__c pv = new Payment_Voucher__c();
            pv.Deposit__c = dp.Id;
            pv.Refund_Mode__c = dp.Refund_Mode__c;
            pv.Payment_Mode__c = dp.Refund_Mode__c;
            pv.Status__c = 'New';
            pv.Currency_Code__c = dp.pv_currency_code__c;
            pv.Amount__c = -dp.Requested_Amount__c;
            pv.Lease__c = dp.Lease__c;
            if(dp.Currency_Code__c != dp.PV_Currency_Code__c)
                pv.Default_Amount_Foreign__c = -dp.Requested_Amount__c / dp.Exchange_Rate__c;            
            if(exgRateMap.containsKey('USD')){
                pv.Exchange_Rate__c = exgRateMap.get('USD').Conversion_Rate__c;
            }

            pv.Transaction_Type__c = 'Deposit';
            
            pv.Property__c = dp.Property__c;
            pv.Charge_Method__c = dp.Charge_Method__c;
            pvList.add(pv);            
        }        
    }
    insert pvList;
  
}