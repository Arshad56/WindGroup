trigger CalcMultiCurrencyforLineItem on Invoice_Line_Item__c (before Insert,before Update) {

    Set<string> currencyCodes = new Set<string>();
    decimal baseForeignCurrencyRate = 0;
    Set<Id> invoiceIds = new Set<Id>();
    for(Invoice_Line_Item__c lineItem:Trigger.New){
        if(Trigger.isInsert || (lineItem.Exchange_Rate__c!=Trigger.OldMap.get(lineItem.Id).Exchange_Rate__c || lineItem.Amount__c!=Trigger.OldMap.get(lineItem.Id).Amount__c) || lineItem.Comm_Tax_Amount__c!=Trigger.OldMap.get(lineItem.Id).Comm_Tax_Amount__c){
            if(lineItem.Exchange_Rate__c==null && lineItem.Currency_Code__c!=null){
                currencyCodes.add(lineItem.Currency_Code__c);
            }
            invoiceIds.add(lineItem.Invoice__c);
        }
    }
    currencyCodes.add(label.Base_Foreign_Currency);
    
    Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([Select id,Currency_Code__c,Exchange_Rate__c from Invoice__c where id in:invoiceIds]);
    
    List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c in:currencyCodes and Applicable_Function__c='Operations' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
    for(Exchange_Rate__c er:exchangeRateList){
        if(er.Currency_Code__c==label.Base_Foreign_Currency){
            baseForeignCurrencyRate  = er.Conversion_Rate__c;
            break;
        }
    }
    
    for(Invoice_Line_Item__c lineItem:Trigger.New){
        if(Trigger.isInsert || (lineItem.Exchange_Rate__c!=Trigger.OldMap.get(lineItem.Id).Exchange_Rate__c || lineItem.Amount__c!=Trigger.OldMap.get(lineItem.Id).Amount__c) || lineItem.Comm_Tax_Amount__c!=Trigger.OldMap.get(lineItem.Id).Comm_Tax_Amount__c){
            if(invoiceMap.containsKey(lineItem.Invoice__c)){
                lineItem.Exchange_Rate__c = invoiceMap.get(lineItem.Invoice__c).Exchange_Rate__c;
            }
            if(lineItem.Exchange_Rate__c==null && lineItem.Currency_Code__c!=null){
                for(Exchange_Rate__c er:exchangeRateList){
                    if(er.Currency_Code__c==lineItem.Currency_Code__c){
                        lineItem.Exchange_Rate__c = er.Conversion_Rate__c;
                        break;
                    }
                }
            }
        }
    }
    
    for(Invoice_Line_Item__c lineItem:Trigger.New){
        if(Trigger.isInsert || (lineItem.Exchange_Rate__c!=Trigger.OldMap.get(lineItem.Id).Exchange_Rate__c || lineItem.Amount__c!=Trigger.OldMap.get(lineItem.Id).Amount__c) || lineItem.Comm_Tax_Amount__c!=Trigger.OldMap.get(lineItem.Id).Comm_Tax_Amount__c){
            if(lineItem.Exchange_Rate__c!=null){
                if(lineItem.Exchange_Rate__c==1){
                    if(lineItem.Amount__c!=null){
                        lineItem.Amount_Local__c = lineItem.Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            lineItem.Amount_Foreign__c = lineItem.Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }
                    if(lineItem.Comm_Tax_Amount__c!=null){
                        lineItem.Comm_Tax_Amount_Local__c = lineItem.Comm_Tax_Amount__c;
                        
                        if(baseForeignCurrencyRate>0){
                            lineItem.Comm_Tax_Amount_Foreign__c = lineItem.Comm_Tax_Amount_Local__c/baseForeignCurrencyRate;
                        }
                    }                                        
                    
                }else{
                    if(lineItem.Amount__c!=null){
                        lineItem.Amount_Foreign__c = lineItem.Amount__c;
                        lineItem.Amount_Local__c = lineItem.Amount_Foreign__c*lineItem.Exchange_Rate__c;
                    }
                    if(lineItem.Comm_Tax_Amount__c!=null){
                        lineItem.Comm_Tax_Amount_Foreign__c = lineItem.Comm_Tax_Amount__c;
                        lineItem.Comm_Tax_Amount_Local__c = lineItem.Comm_Tax_Amount_Foreign__c*lineItem.Exchange_Rate__c;
                    }
                }
            }
        }
    }
    
}