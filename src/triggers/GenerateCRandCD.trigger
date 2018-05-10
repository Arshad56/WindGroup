trigger GenerateCRandCD on Quick_Pay_Info__c (after insert) {
    Map<String, Invoice__c> invoiceMap = new Map<String, Invoice__c>();
    Map<String, Property__c> propertyMap = new Map<String, Property__c>();
    Set<Id> qpIds = new Set<Id>();
     
    Map<String, List<Bank_Information__c>> bankInfoMap = new Map<String, List<Bank_Information__c>>();
    for(Quick_Pay_Info__c qp: Trigger.new){
        invoiceMap.put(qp.Reference03__c, new Invoice__c());
        qpIds.add(qp.Id);
        propertyMap.put(qp.Reference02__c, new Property__c());
        bankInfoMap.put(qp.Account_No__c,new List<Bank_Information__c>());
    }
    System.debug('bankInfoMap-->'+bankInfoMap);
    System.debug('propertyMap-->'+propertyMap);
    System.debug('invoiceMap-->'+invoiceMap); 
    list<Invoice__c> InvoiceList;
    if(Test.isRunningTest()){
        InvoiceList      = [select Id, Name,Outstanding_Amount__c,Invoice_Code_without__c,Tenant__c from Invoice__c ];
    }else{
        InvoiceList      = [select Id, Name,Outstanding_Amount__c,Invoice_Code_without__c,Tenant__c from Invoice__c where Invoice_Code_without__c In: invoiceMap.KeySet()];
    }
    
    list<Property__c> propertyList      = [select Id, Short_Code__c, Cash_Receipt_Index__c, Name from Property__c where Short_Code__c In: propertyMap.KeySet()];
    list<Bank_Information__c> bankInfoList      = [select Id, Account_No__c,Currency_Code__c,Property__c from Bank_Information__c where Account_No__c In: bankInfoMap.KeySet()];
    
    list<Quick_Pay_Info__c> qpList    = [select Id,Account_No__c, Name,TxnReference__c,Success__c,Generated_Cash_Receipt__c,Error__c,Error_Reason__c,CreditAmount__c,ValueDate__c,Reference01__c,Reference02__c,Reference03__c,Reference04__c from Quick_Pay_Info__c where Id In: qpIds];
    System.debug('InvoiceList-->'+InvoiceList);
    System.debug('propertyList-->'+propertyList);
    System.debug('bankInfoList-->'+bankInfoList);
    Map<String,Cash_Receipt__c> crMap = new Map<String,Cash_Receipt__c>();
    Map<String,Cash_Detail__c> cdMap  = new Map<String,Cash_Detail__c>();
    
    bankInfoMap = new Map<String, List<Bank_Information__c>>();
    System.debug('bankInfoList-->'+bankInfoList);
    for(Bank_Information__c bnk :bankInfoList){
        System.debug('bnk.Account_No__c-->'+bnk.Account_No__c);
        if(bankInfoMap.containsKey(bnk.Account_No__c)){
            list<Bank_Information__c> tempBank = new list<Bank_Information__c>();
            tempBank = bankInfoMap.get(bnk.Account_No__c);
            tempBank.add(bnk);
            bankInfoMap.put(bnk.Account_No__c,tempBank);
        }else{
            bankInfoMap.put(bnk.Account_No__c,new list<Bank_Information__c>{bnk});
        }
        System.debug('bankInfoMap-->'+bankInfoMap);
    }
    
    propertyMap = new Map<String, Property__c>(); 
    for(Property__c pr:propertyList){
        propertyMap.put(pr.Short_Code__c,pr);
    }
    System.debug('propertyMap-->'+propertyMap);
    invoiceMap = new Map<String, Invoice__c>();
    for(Invoice__c iv:InvoiceList){
         System.debug('iv.Invoice_Code_without__c-->'+iv.Invoice_Code_without__c);
        invoiceMap.put(iv.Invoice_Code_without__c,iv);
    }
    System.debug('invoiceMap-->'+invoiceMap);
    for(Quick_Pay_Info__c qp:qpList){
       
        qp.Error_Reason__c = '';
        System.debug('bankInfoMap.containsKey(qp.Account_No__c)--'+bankInfoMap.containsKey(qp.Account_No__c));
        System.debug('qp.Reference01__c!=null--'+(qp.Reference01__c!=null));
        System.debug('qp.Reference02__c!=null--'+(qp.Reference02__c!=null));
        System.debug('propertyMap.ContainsKey(qp.Reference02__c)=--'+propertyMap.ContainsKey(qp.Reference02__c));
        System.debug('qp.Reference03__c != null --'+(qp.Reference03__c != null) );
        System.debug('invoiceMap.ContainsKey(qp.Reference03__c)--'+invoiceMap.ContainsKey(qp.Reference03__c));
        if( (bankInfoMap.containsKey(qp.Account_No__c) && qp.Reference01__c!=null  && qp.Reference02__c!=null && propertyMap.ContainsKey(qp.Reference02__c) && qp.Reference03__c != null && invoiceMap.ContainsKey(qp.Reference03__c))){
            Cash_Receipt__c cr = new Cash_Receipt__c();
            //----------------- CR Account No Check
            for(Bank_Information__c bnk: bankInfoMap.get(qp.Account_No__c)){
                if(propertyMap.get(qp.Reference02__c).Id == bnk.Property__c){
                    cr.Payment_Currency__c = bnk.Currency_Code__c;
                    qp.Currency_Code__c = bnk.Currency_Code__c;
                    qp.Error_Reason__c = '';
                    break;
                }else{
                    qp.Error__c = true;
                    qp.Error_Reason__c = 'Account Number doesnot exist for selected Property.\n';
                }
            }
            //-----------------
            if(qp.CreditAmount__c <= invoiceMap.get(qp.Reference03__c).Outstanding_Amount__c){
                //----------------- CR Name Index
                    Integer IntIndex = 1;            
                    Property__c prop = propertyMap.get(qp.Reference02__c);
                    cr.Property__c = prop.Id;
                    if(prop.Cash_Receipt_Index__c!=null && prop.Cash_Receipt_Index__c>0){
                        intIndex = Integer.valueOf(prop.Cash_Receipt_Index__c);
                    }
                    Integer indexSize = string.valueOf(intIndex).length();
                    string index = '';
                    for(integer i =1;i<=6-indexSize;i++){
                        index += '0';
                    }
                    index += string.valueOf(intIndex);
                    cr.Name = prop.Short_Code__c+'-RR-'+system.today().Year()+((system.today().month() <10)?'0':'')+system.today().month()+'-'+index;
                    propertyMap.get(qp.Reference02__c).Cash_Receipt_Index__c = intIndex+1;
                //-----------------
                if(qp.ValueDate__c.length() == 8 ){
                     date myDate = date.newInstance(Integer.valueof(qp.ValueDate__c.substring(0,4)), Integer.valueof(qp.ValueDate__c.substring(4,6)), Integer.valueof(qp.ValueDate__c.substring(6,8)));
                     cr.Payment_Date__c = myDate;
                }else{
                    qp.Error__c = true;
                    qp.Error_Reason__c += 'Please Check Date is of Correct format.\n';
                }
                cr.Remarks__c = qp.Reference04__c;
                cr.Tenant__c = invoiceMap.get(qp.Reference03__c).Tenant__c;
                //cr.Property__c = propertyMap.get(qp.Reference02__c).Id;
                cr.Payment_Mode__c = 'Quick Pay';
                cr.Cash_Receipt_Generated__c = true;
                cr.Payment_Reference__c = qp.TxnReference__c;
                if(!qp.Error__c){
                    crMap.put(qp.Reference03__c, cr);
                }
            }else{
                qp.Error__c = true;
                qp.Error_Reason__c = 'Credit amount exceeds Invoice outstanding amount.\n';
            }
        }else{
            qp.Error__c = true;
            
            if(qp.Reference03__c == null || qp.Reference03__c == ''){
                qp.Error_Reason__c += 'Invoice Number is blank.\n';
            }else if(!invoiceMap.ContainsKey(qp.Reference03__c)){   
                qp.Error_Reason__c += 'Invoice Number not found in the system.\n';
            }
            if(qp.Reference02__c == null || qp.Reference02__c == ''){
                qp.Error_Reason__c += 'Propert Short code is blank.\n';
            }else if(!propertyMap.ContainsKey(qp.Reference02__c)){
                qp.Error_Reason__c += 'Propert Short code not found in the system.\n';
            }
            
            if(qp.Account_No__c == '' || qp.Account_No__c == null){
                qp.Error_Reason__c += 'Account Number is blank.\n';
            }else{
                qp.Error_Reason__c += 'Account Number not found in the system.\n';
            }
        }
        
        
    }    
    update propertyMap.values();
    insert crMap.values();
    System.debug('crMap.values()-->'+crMap.values());
    
    for(Quick_Pay_Info__c qp:qpList){
        if(!qp.Error__c){
            Cash_Detail__c cd = new Cash_Detail__c(); 
            cd.Amount_Paid__c = qp.CreditAmount__c;
            cd.Invoice__c  = invoiceMap.get(qp.Reference03__c).Id;
            cd.Cash_Receipt__c = crMap.get(qp.Reference03__c).Id;
            System.debug('invoiceMap.get(qp.Reference03__c).Id-->'+invoiceMap.get(qp.Reference03__c).Id);
            System.debug('crMap.get(qp.Reference03__c).Id-->'+crMap.get(qp.Reference03__c).Id);
            cd.Remarks__c = qp.Reference04__c;
            cd.Currency_Code__c = qp.Currency_Code__c;
            qp.Success__c = true;
            cd.Payment_Mode__c = 'Quick Pay';
            qp.Generated_Cash_Receipt__c = crMap.get(qp.Reference03__c).Id;
            
            cdMap.put(qp.Reference03__c, cd);
        }
    }    
    
    insert cdMap.values();
    update qpList;
}