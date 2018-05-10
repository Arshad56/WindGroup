trigger CalcMultiCurrencyAmountForRRD on Rent_Roll_Detail__c (before Insert,before Update){
    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    
    for(Rent_Roll_Detail__c rs:Trigger.New){
        if(Trigger.isInsert || (rs.Exchange_Rate__c!=Trigger.OldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=Trigger.OldMap.get(rs.Id).Amount__c)){
            if(rs.Exchange_Rate__c==null && rs.Currency_Code__c!=null){
                currencyCodes.add(rs.Currency_Code__c);
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
    
    for(Rent_Roll_Detail__c rs:Trigger.New){
        if(Trigger.isInsert || rs.Exchange_Rate__c!=Trigger.OldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=Trigger.OldMap.get(rs.Id).Amount__c){
            if(rs.Exchange_Rate__c==null && rs.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==rs.Currency_Code__c){
                        rs.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
        }
    }
    
    for(Rent_Roll_Detail__c rs:Trigger.New){
        if(Trigger.isInsert || rs.Exchange_Rate__c!=Trigger.OldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=Trigger.OldMap.get(rs.Id).Amount__c){
            if(rs.Exchange_Rate__c!=null){
                if(rs.Exchange_Rate__c==1){
                    if(rs.Amount__c!=null){
                        rs.Amount_Local__c = rs.Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            rs.Amount_Foreign__c = rs.Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(rs.Comm_Tax_Amount__c!=null){
                        rs.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            rs.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                }else{
                    if(rs.Amount__c!=null){
                        rs.Amount_Foreign__c = rs.Amount__c;
                        rs.Amount_Local__c = rs.Amount_Foreign__c*rs.Exchange_Rate__c;
                    }
                    if(rs.Comm_Tax_Amount__c!=null){
                        rs.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount__c;
                        
                        rs.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount_Foreign__c*rs.Exchange_Rate__c;
                    }
                }
            }
        }
    }
}