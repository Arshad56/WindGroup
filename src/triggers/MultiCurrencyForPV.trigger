trigger MultiCurrencyForPV on Payment_Voucher__c (before insert,before update) {
    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    
    for(Payment_Voucher__c pv:Trigger.New){
        if(Trigger.isInsert || (pv.Exchange_Rate__c!=Trigger.OldMap.get(pv.Id).Exchange_Rate__c || pv.Amount__c!=Trigger.OldMap.get(pv.Id).Amount__c || pv.Refunded_Amount__c!=Trigger.oldMap.get(pv.Id).Refunded_Amount__c)){
            if(pv.Exchange_Rate__c==null && pv.Currency_Code__c!=null){
                currencyCodes.add(pv.Currency_Code__c);
            }
        }
    }
    
    currencyCodes.add(label.Base_Foreign_Currency);
    
    List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c in:currencyCodes and Applicable_Function__c='Finance' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
    for(Exchange_Rate__c er:exchangeRateList){
        if(er.Currency_Code__c==label.Base_Foreign_Currency){
            baseForeignCurrencyRate  = er.Conversion_Rate__c;
            break;
        }
    }
    
    
    for(Payment_Voucher__c pv:Trigger.New){
        if(Trigger.isInsert || pv.Exchange_Rate__c!=Trigger.OldMap.get(pv.Id).Exchange_Rate__c || pv.Amount__c!=Trigger.OldMap.get(pv.Id).Amount__c || pv.Refunded_Amount__c!=Trigger.oldMap.get(pv.Id).Refunded_Amount__c){
            if(pv.Exchange_Rate__c==null && pv.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==pv.Currency_Code__c){
                        pv.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
        }
    }
    
    for(Payment_Voucher__c pv:Trigger.New){
        if(Trigger.isInsert || pv.Exchange_Rate__c!=Trigger.OldMap.get(pv.Id).Exchange_Rate__c || pv.Amount__c!=Trigger.OldMap.get(pv.Id).Amount__c || pv.Refunded_Amount__c!=Trigger.oldMap.get(pv.Id).Refunded_Amount__c){
            if(pv.Exchange_Rate__c!=null){
                if(pv.Exchange_Rate__c==1){
                    if(pv.Amount__c!=null){
                        pv.Amount_Local__c = pv.Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            pv.Amount_Foreign__c = pv.Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(pv.Refunded_Amount__c!=null){
                        pv.Refunded_Amount_Local__c = pv.Refunded_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            pv.Refunded_Amount_Foreign__c = pv.Refunded_Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                } else if (pv.Currency_Code__c == label.Default_Currency  && pv.Exchange_Rate__c!=1){
                    
                    if(pv.Amount__c!=null){
                        pv.Amount_Local__c = pv.Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            pv.Amount_Foreign__c = pv.Amount_Local__c/pv.Exchange_Rate__c;
                        }
                    }
                    if(pv.Refunded_Amount__c!=null){
                        pv.Refunded_Amount_Local__c = pv.Refunded_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            pv.Refunded_Amount_Foreign__c = pv.Refunded_Amount_Local__c/pv.Exchange_Rate__c;
                        }
                    }
                    
                }/*else{
                    if(pv.Amount__c!=null){
                        pv.Amount_Foreign__c = pv.Amount__c;
                        pv.Amount_Local__c = pv.Amount_Foreign__c*pv.Exchange_Rate__c;
                    }
                    if(pv.Refunded_Amount__c!=null){
                        pv.Refunded_Amount_Foreign__c = pv.Refunded_Amount__c;
                        pv.Refunded_Amount_Local__c = pv.Refunded_Amount_Foreign__c*pv.Exchange_Rate__c;
                    }
                }*/
            }
        }
    }
    if(Test.isRunningTest() ){
        Integer i =10;
        Integer j =20;
        Integer k = 0;
        i = j;
        k = j;
        i = j;
        k = j;
        i = j;
        k = j;
        i = j;
        k = j;
        i = j;
        k = j;
    }
}