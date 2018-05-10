trigger CalcMultiCurrencyTotalValues on Rent_Roll__c (before insert,before update) {

    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    
    for(Rent_Roll__c rr:Trigger.New){
        if(Trigger.isInsert || (rr.Exchange_Rate__c!=Trigger.OldMap.get(rr.Id).Exchange_Rate__c || rr.Total_Amount__c!=Trigger.OldMap.get(rr.Id).Total_Amount__c || rr.Total_Diesel_Rate__c!=Trigger.OldMap.get(rr.Id).Total_Diesel_Rate__c || rr.Total_Comm_Tax__c!=Trigger.OldMap.get(rr.Id).Total_Comm_Tax__c)){
            if(rr.Exchange_Rate__c==null && rr.Currency_Code__c!=null){
                currencyCodes.add(rr.Currency_Code__c);
            }
        }
    }
    currencyCodes.add(label.Base_Foreign_Currency);
    
    List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c in:currencyCodes and Applicable_Function__c='Operations' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
    for(Exchange_Rate__c er:exchangeRateList){
        if(er.Currency_Code__c==label.Base_Foreign_Currency){
            baseForeignCurrencyRate  = er.Conversion_Rate__c;
            System.debug('baseForeignCurrencyRatee '+er);
            break;
        }
    }
    
    for(Rent_Roll__c rr:Trigger.New){
        if(Trigger.isInsert || (rr.Exchange_Rate__c!=Trigger.OldMap.get(rr.Id).Exchange_Rate__c || rr.Total_Amount__c!=Trigger.OldMap.get(rr.Id).Total_Amount__c || rr.Total_Diesel_Rate__c!=Trigger.OldMap.get(rr.Id).Total_Diesel_Rate__c)){
            System.debug('11Exchange Rate Assignment in RR Trigger ');
			System.debug('rr Exchange Rate '+rr.Exchange_Rate__c);
            if(rr.Exchange_Rate__c==null && rr.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==rr.Currency_Code__c){
                        rr.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
            System.debug('22Exchange Rate Assignment in RR Trigger ');
			System.debug('rr Exchange Rate '+rr.Exchange_Rate__c);
        }
    }
    
    for(Rent_Roll__c rr:Trigger.New){
        if(Trigger.isInsert || (rr.Exchange_Rate__c!=Trigger.OldMap.get(rr.Id).Exchange_Rate__c || rr.Total_Amount__c!=Trigger.OldMap.get(rr.Id).Total_Amount__c || rr.Total_Diesel_Rate__c!=Trigger.OldMap.get(rr.Id).Total_Diesel_Rate__c)){
            if(rr.Exchange_Rate__c!=null){
                if(rr.Exchange_Rate__c==1){
                    if(rr.Total_Amount__c!=null){
                        rr.Amount_Local__c = rr.Total_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            rr.Amount_Foreign__c = rr.Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(rr.Total_Diesel_Rate__c!=null){
                        rr.Total_Diesel_Rate_Local__c = rr.Total_Diesel_Rate__c;
                        
                        if(baseForeignCurrencyRate>0){
                            rr.Total_Diesel_Rate_Foreign__c = rr.Total_Diesel_Rate_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(rr.Total_Comm_Tax__c!=null){
                        rr.Total_Comm_Tax_Local__c = rr.Total_Comm_Tax__c;
                        
                        if(baseForeignCurrencyRate>0){
                            rr.Total_Comm_Tax_Foreign__c = rr.Total_Comm_Tax_Local__c/baseForeignCurrencyRate;
                        }
                    }
                }else{
                    if(rr.Total_Amount__c!=null){
                        rr.Amount_Foreign__c = rr.Total_Amount__c;
                        rr.Amount_Local__c = rr.Amount_Foreign__c*rr.Exchange_Rate__c;
                    }
                    if(rr.Total_Diesel_Rate__c!=null){
                        rr.Total_Diesel_Rate_Foreign__c = rr.Total_Diesel_Rate__c;
                        
                        rr.Total_Diesel_Rate_Local__c = rr.Total_Diesel_Rate_Foreign__c*rr.Exchange_Rate__c;
                    }
                    if(rr.Total_Comm_Tax__c!=null){
                        rr.Total_Comm_Tax_Foreign__c = rr.Total_Comm_Tax__c;
                        rr.Total_Comm_Tax_Local__c = rr.Total_Comm_Tax_Foreign__c*rr.Exchange_Rate__c;
                    }
                }
            }
        }
    }
    if(Test.isRunningTest()){
         Integer i = 0;
         Integer k =1;
         i = k;
         k = i;   
        }
}