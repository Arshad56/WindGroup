trigger CalcMultiCurrencyValues on Lease_Charges__c (before insert,before update) {

    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    for(Lease_Charges__c lc:Trigger.New){
        if(Trigger.isInsert || lc.Exchange_Rate__c!=Trigger.OldMap.get(lc.Id).Exchange_Rate__c || lc.Base_Value__c!=Trigger.OldMap.get(lc.Id).Base_Value__c || lc.Base_Rent_Calculation__c!=Trigger.OldMap.get(lc.Id).Base_Rent_Calculation__c){
            if(lc.Exchange_Rate__c==null && lc.Currency_Code__c!=null){
                currencyCodes.add(lc.Currency_Code__c);
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
    for(Lease_Charges__c lc:Trigger.New){
        if(Trigger.isInsert || lc.Exchange_Rate__c!=Trigger.OldMap.get(lc.Id).Exchange_Rate__c || lc.Base_Value__c!=Trigger.OldMap.get(lc.Id).Base_Value__c || lc.Base_Rent_Calculation__c!=Trigger.OldMap.get(lc.Id).Base_Rent_Calculation__c){
            if(lc.Exchange_Rate__c==null && lc.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==lc.Currency_Code__c){
                        lc.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
        }
    }
    
    for(Lease_Charges__c lc:Trigger.New){
        if(Trigger.isInsert || lc.Exchange_Rate__c!=Trigger.OldMap.get(lc.Id).Exchange_Rate__c || lc.Base_Value__c!=Trigger.OldMap.get(lc.Id).Base_Value__c || lc.Base_Rent_Calculation__c!=Trigger.OldMap.get(lc.Id).Base_Rent_Calculation__c){
            if(lc.Exchange_Rate__c!=null){
                if(lc.Exchange_Rate__c==1){
                    if(lc.Base_Value__c!=null){
                        lc.Base_Value_Local__c = lc.Base_Value__c;
                        
                        if(baseForeignCurrencyRate>0){
                            lc.Base_Value_Foreign__c = lc.Base_Value_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(lc.Base_Rent_Calculation__c!=null){
                        lc.Base_Rent_Calculation_Local__c = lc.Base_Rent_Calculation__c;
                        
                        if(baseForeignCurrencyRate>0){
                            lc.Base_Rent_Calculation_Foreign__c = lc.Base_Rent_Calculation_Local__c/baseForeignCurrencyRate;
                        }
                    }
                }else{
                    if(lc.Base_Value__c!=null){
                        lc.Base_Value_Foreign__c = lc.Base_Value__c;
                        
                        system.debug('lc.Base_Value_Foreign__c====='+lc.Base_Value_Foreign__c);
                        system.debug('lc.Exchange_Rate__c====='+lc.Exchange_Rate__c);
                        
                        lc.Base_Value_Local__c = lc.Base_Value_Foreign__c*lc.Exchange_Rate__c;
                    }
                    if(lc.Base_Rent_Calculation__c!=null){
                        lc.Base_Rent_Calculation_Foreign__c = lc.Base_Rent_Calculation__c;
                        
                        lc.Base_Rent_Calculation_Local__c = lc.Base_Rent_Calculation_Foreign__c*lc.Exchange_Rate__c;
                    }
                }
            }
        }
    }
}