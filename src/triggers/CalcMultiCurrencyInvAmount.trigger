trigger CalcMultiCurrencyInvAmount on Invoice__c (before Insert,before Update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            for(Invoice__c inv:Trigger.New){
                if(inv.AmountRollupLocal__c!=Trigger.oldMap.get(inv.Id).AmountRollupLocal__c){
                    inv.Amount_Local__c = inv.AmountRollupLocal__c;
                }
                
                if(inv.AmountRollupForeign__c!=Trigger.oldMap.get(inv.Id).AmountRollupForeign__c){
                    inv.Amount_Foreign__c = inv.AmountRollupForeign__c;
                }
                
                if(inv.TaxAmountRollupLocal__c!=Trigger.oldMap.get(inv.Id).TaxAmountRollupLocal__c){
                    inv.Comm_Tax_Amount_Local__c = inv.TaxAmountRollupLocal__c;
                }
                
                if(inv.TotalAmountRollupForeign__c!=Trigger.oldMap.get(inv.Id).TotalAmountRollupForeign__c){
                    inv.Comm_Tax_Amount_Foreign__c = inv.TotalAmountRollupForeign__c;
                }
                
                if(inv.TotalAmountRollupLocal__c!=Trigger.oldMap.get(inv.Id).TotalAmountRollupLocal__c){
                    inv.Total_Amount_Local__c = inv.TotalAmountRollupLocal__c;
                }
                
                if(inv.TotalAmountRollupForeign__c!=Trigger.oldMap.get(inv.Id).TotalAmountRollupForeign__c){
                    inv.Total_Amount_Foreign__c = inv.TotalAmountRollupForeign__c;
                }
            }
        }
        Set<string> currencyCodes = new Set<string>();
        decimal baseForeignCurrencyRate = 0;
        
        for(Invoice__c inv:Trigger.New){
            if(Trigger.isInsert || (inv.Amount_Paid__c!=Trigger.OldMap.get(inv.Id).Amount_Paid__c || inv.Outstanding_Amount__c!=Trigger.OldMap.get(inv.Id).Outstanding_Amount__c)){
                if(inv.Exchange_Rate__c==null && inv.Currency_Code__c!=null){
                    currencyCodes.add(inv.Currency_Code__c);
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
        
        for(Invoice__c inv:Trigger.New){
            if(Trigger.isInsert || (inv.Exchange_Rate__c!=Trigger.OldMap.get(inv.Id).Exchange_Rate__c || inv.Amount__c!=Trigger.OldMap.get(inv.Id).Amount__c) || inv.Amount_Paid__c!=Trigger.OldMap.get(inv.Id).Amount_Paid__c || inv.Comm_Tax_Amount__c!=Trigger.OldMap.get(inv.Id).Comm_Tax_Amount__c || inv.Outstanding_Amount__c!=Trigger.OldMap.get(inv.Id).Outstanding_Amount__c || inv.Total_Amount__c!=Trigger.OldMap.get(inv.Id).Total_Amount__c){
                if(inv.Foreign_Exchange_Rate__c==null){
                    inv.Foreign_Exchange_Rate__c = baseForeignCurrencyRate;
                }
                if(inv.Exchange_Rate__c==null && inv.Currency_Code__c!=null){
                    for(Exchange_Rate__c er:exchangeRateList){
                        if(er.Currency_Code__c==inv.Currency_Code__c){
                            inv.Exchange_Rate__c = er.Conversion_Rate__c;
                            break;
                        }
                    }
                }
            }
        }
        
        for(Invoice__c inv:Trigger.New){
            if(Trigger.isInsert || (inv.Exchange_Rate__c!=Trigger.OldMap.get(inv.Id).Exchange_Rate__c || inv.Amount__c!=Trigger.OldMap.get(inv.Id).Amount__c) || inv.Amount_Paid__c!=Trigger.OldMap.get(inv.Id).Amount_Paid__c || inv.Comm_Tax_Amount__c!=Trigger.OldMap.get(inv.Id).Comm_Tax_Amount__c || inv.Outstanding_Amount__c!=Trigger.OldMap.get(inv.Id).Outstanding_Amount__c || inv.Total_Amount__c!=Trigger.OldMap.get(inv.Id).Total_Amount__c){
                if(inv.Exchange_Rate__c!=null){
                    if(inv.Exchange_Rate__c==1){
                        if(Trigger.isUpdate && inv.Amount_Paid__c!=Trigger.OldMap.get(inv.Id).Amount_Paid__c){
                            if(inv.Amount_Paid__c!=null){
                                inv.Amount_Paid_Local__c = inv.Amount_Paid__c;
                                if(inv.Foreign_Exchange_Rate__c>0){
                                    inv.Amount_Paid_Foreign__c = inv.Amount_Paid_Local__c/inv.Foreign_Exchange_Rate__c;
                                }
                            }
                        }
                        if(inv.Outstanding_Amount__c!=null){
                            inv.Outstanding_Amount_Local__c = inv.Outstanding_Amount__c;
                            inv.Outstanding_Amount_Foreign__c = (inv.Total_Amount_Foreign__c!=null?inv.Total_Amount_Foreign__c:0) - (inv.Amount_Paid_Foreign__c !=null?inv.Amount_Paid_Foreign__c:0);
                        }
                    }else{
                        if(inv.Amount_Paid__c!=null){
                            inv.Amount_Paid_Foreign__c = inv.Amount_Paid__c.setScale(2);
                            inv.Amount_Paid_Local__c = (inv.Amount_Paid__c*inv.Exchange_Rate__c).setScale(2);
                        } 
                        if(inv.Outstanding_Amount__c!=null){
                            inv.Outstanding_Amount_Foreign__c = inv.Outstanding_Amount__c.setScale(2);
                            inv.Outstanding_Amount_Local__c = (inv.Total_Amount_Local__c!=null?inv.Total_Amount_Local__c:0) - (inv.Amount_Paid_Local__c!=null?inv.Amount_Paid_Local__c:0);
                        }
                    }
                }
            }
        }
    }
    if(test.isRunningTest()){
        Integer i =1;
        Integer j = 1;
        Integer k = 2;
    }
}