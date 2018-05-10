trigger CalcMultiCurrencyAmountDeposit on Deposit__c (before Insert,before Update) {

    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    
    for(Deposit__c dp:Trigger.New){
        if(Trigger.isInsert || (dp.Exchange_Rate__c != Trigger.OldMap.get(dp.Id).Exchange_Rate__c || dp.Deposit_Amount__c != Trigger.OldMap.get(dp.Id).Deposit_Amount__c || dp.Amount_Paid__c != Trigger.OldMap.get(dp.Id).Amount_Paid__c || dp.Outstanding_Amount__c != Trigger.OldMap.get(dp.Id).Outstanding_Amount__c)){
            if(dp.Exchange_Rate__c==null && dp.Currency_Code__c!=null){
                currencyCodes.add(dp.Currency_Code__c);
            }
        }
    }
    currencyCodes.add(label.Base_Foreign_Currency);
    
    List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c in:currencyCodes and Applicable_Function__c='Operations' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
    for(Exchange_Rate__c er:exchangeRateList){
        if(er.Currency_Code__c==label.Base_Foreign_Currency){
            baseForeignCurrencyRate  = er.Conversion_Rate__c;
            break;
        }
    }
    
    for(Deposit__c dp:Trigger.New){
        if(Trigger.isInsert || dp.Exchange_Rate__c != Trigger.OldMap.get(dp.Id).Exchange_Rate__c || dp.Deposit_Amount__c != Trigger.OldMap.get(dp.Id).Deposit_Amount__c || dp.Amount_Paid__c != Trigger.OldMap.get(dp.Id).Amount_Paid__c || dp.Outstanding_Amount__c != Trigger.OldMap.get(dp.Id).Outstanding_Amount__c){
            if(dp.Exchange_Rate__c==null && dp.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==dp.Currency_Code__c){
                        dp.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
        }
    }
    
    for(Deposit__c dp:Trigger.New){
        if(Trigger.isInsert || dp.Exchange_Rate__c != Trigger.OldMap.get(dp.Id).Exchange_Rate__c || dp.Deposit_Amount__c != Trigger.OldMap.get(dp.Id).Deposit_Amount__c || dp.Amount_Paid__c != Trigger.OldMap.get(dp.Id).Amount_Paid__c || dp.Outstanding_Amount__c != Trigger.OldMap.get(dp.Id).Outstanding_Amount__c){
            if(dp.Exchange_Rate__c!=null){
                if(dp.Exchange_Rate__c==1){
                    if(dp.Deposit_Amount__c!=null){
                        dp.Deposit_Amount_Local__c = dp.Deposit_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            dp.Deposit_Amount_Foreign__c = dp.Deposit_Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(dp.Amount_Paid__c!=null){
                        dp.Amount_Paid_Local__c = dp.Amount_Paid__c;
                        
                        if(baseForeignCurrencyRate>0){
                            dp.Amount_Paid_Foreign__c = dp.Amount_Paid_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(dp.Outstanding_Amount__c!=null){
                        dp.Outstanding_Amount_Local__c = dp.Outstanding_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            dp.Outstanding_Amount_Foreign__c = dp.Outstanding_Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                }else{
                    if(dp.Deposit_Amount__c!=null){
                        dp.Deposit_Amount_Foreign__c = dp.Deposit_Amount__c;
                        dp.Deposit_Amount_Local__c = dp.Deposit_Amount_Foreign__c*dp.Exchange_Rate__c;
                    }
                    if(dp.Amount_Paid__c!=null){
                        dp.Amount_Paid_Foreign__c = dp.Amount_Paid__c;
                        
                        dp.Amount_Paid_Local__c = dp.Amount_Paid_Foreign__c*dp.Exchange_Rate__c;
                    }
                    if(dp.Outstanding_Amount__c!=null){
                        dp.Outstanding_Amount_Foreign__c = dp.Outstanding_Amount__c;
                        
                        dp.Outstanding_Amount_Local__c = dp.Outstanding_Amount_Foreign__c*dp.Exchange_Rate__c;
                    }
                }
            }
        }
    }
}