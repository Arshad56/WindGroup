public class AccountStatementPDFCntrl{
    public Property__c pro{get;set;}
    public Account tenant{get;set;}
    public Decimal outstandingAmount{get;set;}
    
    string prtyId;
    string tenAcId;
    public AccountStatementPDFCntrl(){
        pro = new Property__c();
        tenant = new Account();
        outstandingAmount = 0;
        prtyId = Apexpages.currentPage().getParameters().get('pId');
        tenAcId = Apexpages.currentPage().getParameters().get('tId');
        
        if(prtyId != null && tenAcId != null){
            list<Property__c> proLst = [SELECT Id,Logo__c FROM Property__c WHERE Id =: prtyId];
            if(proLst.size() > 0)
                pro = proLst.get(0);
                
            list<Account> acList = [SELECT Id,Name,BillingStreet,Phone,BillingCity,BillingState,BillingCountry,Customer_Code__c FROM Account WHERE Id =:tenAcId];
            if(acList.size() > 0)
                tenant = acList.get(0);
        }
    }
    
    public list<DisplayWrapper> getDepoInvList(){
   
        list<DisplayWrapper> disWrapLst = new list<DisplayWrapper>();
        try{
            list<Deposit__c> depList = [SELECT Id,Name,Outstanding_Amount__c,Amount_Paid__c,Tenant__c,Property__c,Deposit_Amount__c,Deposit_Date__c,
                                                Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Deposit_Type__c,Currency_Code__c,Exchange_Rate__c,
                                                Deposit_Amount_Local__c,Deposit_Amount_Foreign__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Description__c 
                                         FROM Deposit__c 
                                         WHERE Status__c!='Cancelled' and Status__c!='Rejected' and Property__c =:prtyId and Tenant__c =: tenAcId 
                                         ORDER BY CreatedDate ASC];
                                         
                                              
            list<Invoice__c> invList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,
                                               Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,
                                               Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,
                                               (Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c from Invoice_Line_Items__r WHERE Start_Date__c != null AND End_Date__c != null) 
                                        FROM Invoice__c 
                                        WHERE Status__c!='Cancelled' and Voided__c=false and Property__c =:prtyId and Tenant__c =: tenAcId  
                                        ORDER BY CreatedDate ASC];
                                  
            
            map<Id,list<Cash_Detail__c>> inCaseDetilMap = new map<Id,list<Cash_Detail__c>>();
            
            List<Cash_Detail__c> csDetLst = [SELECt Id,Name,Cash_Receipt__r.Name,Cash_Receipt__r.Payment_Date__c,Invoice__c,Invoice__r.Name,Deposit__c,Deposit__r.Name,Amount_Paid__c,Currency_Code__c,Amount_Paid_Local__c
                                       FROM Cash_Detail__c 
                                       WHERE Cash_Receipt__r.Property__c =:prtyId and Cash_Receipt__r.Tenant__c =:tenAcId and Void__c = false];
           system.debug('@@@@@'+csDetLst );
            for(Cash_Detail__c csDe : csDetLst){
                  
                list<Cash_Detail__c> caseDetLst = new list<Cash_Detail__c>();
                if(csDe.Invoice__c != null && inCaseDetilMap.containsKey(csDe.Invoice__c))
                    caseDetLst = inCaseDetilMap.get(csDe.Invoice__c);
                else if(csDe.Deposit__c != null && inCaseDetilMap.containsKey(csDe.Deposit__c))
                    caseDetLst = inCaseDetilMap.get(csDe.Deposit__c);    
                
                caseDetLst.add(csDe);
                
                if(csDe.Invoice__c != null)
                    inCaseDetilMap.put(csDe.Invoice__c,caseDetLst);
                else if(csDe.Deposit__c != null)    
                    inCaseDetilMap.put(csDe.Deposit__c,caseDetLst);
            }
                                  
            for(Deposit__c dep: depList){
                DisplayWrapper disObj = new DisplayWrapper();
                disObj.invDepNo = dep.Name;
                disObj.amount = dep.Deposit_Amount__c;
                disObj.billingType = dep.Deposit_Type__c;            
                disObj.invDepDate = dep.Deposit_Date__c;
                disObj.remarks = dep.Description__c;
                disObj.currencyType = dep.Currency_Code__c;
                
                if(dep.Currency_Code__c != Label.Default_Currency){
                    disObj.amount = dep.Deposit_Amount_Local__c;
                    disObj.locCurren = dep.Deposit_Amount__c;
                }
                disWrapLst.add(disObj);
                
                if(disObj.amount != null)
                    outstandingAmount += disObj.amount;
                
                if(inCaseDetilMap.containsKey(dep.Id)){
                    for(Cash_Detail__c casDet : inCaseDetilMap.get(dep.Id)){
                        DisplayWrapper disObjCaseRec = new DisplayWrapper();
                        disObjCaseRec.caseRecNo = casDet.Cash_Receipt__r.Name;
                        disObjCaseRec.invDepNo = casDet.Deposit__r.Name;
                        disObjCaseRec.billingType = 'Cash Receipt';
                        disObjCaseRec.amount = -casDet.Amount_Paid__c;
                        disObjCaseRec.invDepDate = casDet.Cash_Receipt__r.Payment_Date__c;
                        
                        disObjCaseRec.currencyType = casDet .Currency_Code__c;
                        if(casDet.Currency_Code__c != Label.Default_Currency){
                            disObjCaseRec.amount = -casDet.Amount_Paid_Local__c;
                            disObjCaseRec.locCurren = -casDet.Amount_Paid__c;
                        }
                        disWrapLst.add(disObjCaseRec);
                        
                        if(disObjCaseRec.amount != null)
                            outstandingAmount += disObjCaseRec.amount;
                    }
                } 
            }
             
             //----------------------------- Start Filling map for Remarks------------------
            Map<Id,Map<string,date>> invRentStartDtMap = new Map<Id,Map<string,date>>();
            Map<Id,Map<string,date>> invRentEndDtMap = new Map<Id,Map<string,date>>();
            Map<Id,Date> invMonthlyDateMap = new Map<Id,Date>();
            
            for(Invoice__c inv: invList){
                for(Invoice_Line_Item__c ili:inv.Invoice_Line_Items__r){
                    if(inv.billing_Type__c=='Rent' && ili.charge_Name__c!=null){
                        Map<string,date> tempStartMap = new Map<string,date>();
                        Map<string,date> tempEndMap = new Map<string,date>();
                        
                        if(invRentStartDtMap.containsKey(inv.Id)){
                            tempStartMap = invRentStartDtMap.get(inv.Id);
                        }
                        
                        if(invRentEndDtMap.containsKey(inv.Id)){
                            tempEndMap = invRentEndDtMap.get(inv.Id);
                        }
                        
                        Date tempStDate = null;
                        if(tempStartMap.containsKey(ili.Charge_Name__c)){
                            tempStDate = tempStartMap.get(ili.Charge_Name__c);
                        }
                        
                        if(tempStDate==null || tempStDate>ili.Start_Date__c){
                            tempStartMap.put(ili.Charge_Name__c,ili.Start_Date__c);
                        }
                        invRentStartDtMap.put(inv.Id,tempStartMap);
                        
                        Date tempEndDate = null;
                        if(tempEndMap.containsKey(ili.Charge_Name__c)){
                            tempEndDate = tempEndMap.get(ili.Charge_Name__c);
                        }
                        
                        if(tempEndDate==null || tempEndDate<ili.End_Date__c){
                            tempEndMap.put(ili.Charge_Name__c,ili.End_Date__c);
                        }
                        invRentEndDtMap.put(inv.Id,tempEndMap);
                        
                    }else if(inv.Billing_Type__c=='Monthly'){
                        Date tempDt = null;
                        if(invMonthlyDateMap.containsKey(inv.Id)){
                            tempDt = invMonthlyDateMap.get(inv.Id);
                        }
                        if(tempDt==null || tempDt<ili.End_Date__c){
                            invMonthlyDateMap.put(inv.Id,ili.End_Date__c);
                        }
                    }
                }
            }
            //----------------------------- End Filling map for Remarks------------------  
              system.debug('@@@@@'+inCaseDetilMap);      
            for(Invoice__c inv : invList){
                   
                DisplayWrapper disObj = new DisplayWrapper();
                disObj.invDepNo = inv.Name;
                disObj.billingType = inv.Billing_Type__c;
                disObj.amount = inv.Total_Amount__c;
                disObj.invDepDate = inv.Invoice_Date__c;
                disObj.currencyType = inv.Currency_Code__c;
                
                if(inv.Currency_Code__c != Label.Default_Currency){
                    disObj.amount = inv.Total_Amount_Local__c;
                    disObj.locCurren = inv.Total_Amount__c;
                }
                
                if(inv.billing_Type__c=='Rent'){
                    if(invRentStartDtMap.containsKey(inv.Id) && invRentEndDtMap.containsKey(inv.Id)){
                        Map<string,Date> tempStartMap = invRentStartDtMap.get(inv.Id);
                        Map<string,Date> tempEndMap = invRentEndDtMap.get(inv.Id);
                        
                        disObj.Remarks = '';
                        for(string chgName:tempStartMap.keyset()){
                            if(tempEndMap.containsKey(chgName)){
                                Datetime startDt = Datetime.NewInstance(tempStartMap.get(chgName).year(),tempStartMap.get(chgName).month(),tempStartMap.get(chgName).day());
                                Datetime EndDt = Datetime.NewInstance(tempEndMap.get(chgName).year(),tempEndMap.get(chgName).month(),tempEndMap.get(chgName).day());
                                disObj.Remarks = disObj.Remarks + 'Rental Bill for '+ startDt.format('dd MMMM YYYY') + ' ~ '+ endDt.format('dd MMMM YYYY')+'\n';
                            }
                        }
                        if(disObj.remarks!=null && disObj.remarks.trim().length()>0){
                            if(disObj.remarks.endsWith('\n')){
                                disObj.Remarks = disObj.remarks.substring(0,disObj.remarks.length()-1);
                            }
                        }
                    }
                }else if(inv.Billing_Type__c=='Monthly'){
                    if(invMonthlyDateMap.containsKey(inv.Id)){
                        Datetime dtm = Datetime.NewInstance(invMonthlyDateMap.get(inv.Id).year(),invMonthlyDateMap.get(inv.Id).month(),invMonthlyDateMap.get(inv.Id).day());
                        disObj.Remarks = 'Monthly Bill for '+dtm.format('MMMM YYYY');
                    }
                }else if(inv.Billing_Type__c=='Debit Note'){
                    if(inv.invoice_Line_Items__r.size()>0 && inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c!=null){
                        Datetime dtm = Datetime.NewInstance(inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.year(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.month(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.day());
                        disObj.Remarks = 'Debit Note for '+dtm.format('MMMM YYYY');
                    }
                }else if(inv.Billing_Type__c=='Credit Note'){
                    if(inv.invoice_Line_Items__r.size()>0  && inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c!=null){
                        Datetime dtm = Datetime.NewInstance(inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.year(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.month(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.day());
                        disObj.Remarks = 'Credit Note for '+dtm.format('MMMM YYYY');
                    }
                }else if(inv.Billing_Type__c=='Ad-Hoc Invoice'){
                    if(inv.Invoice_Date__c!=null){
                        Datetime dtm = Datetime.NewInstance(inv.Invoice_Date__c.year(),inv.Invoice_Date__c.month(),inv.Invoice_Date__c.day());
                        disObj.Remarks = 'Miscellaneous Invoice for '+dtm.format('MMMM YYYY');
                    }
                }else if(inv.Billing_Type__c=='Late Charge'){
                    if(inv.Invoice_Date__c!=null && inv.invoice_Line_Items__r.size()>0 && inv.invoice_Line_Items__r[0].Due_Days__c!=null){
                        Date oldDate = inv.Invoice_Date__c.addDays(-Integer.valueOf(inv.invoice_Line_Items__r[0].Due_Days__c));
                        Datetime dtm1 = Datetime.NewInstance(inv.Invoice_Date__c.year(),inv.Invoice_Date__c.month(),inv.Invoice_Date__c.day());                                            
                        if(oldDate.month()==inv.Invoice_Date__c.month()){
                            disObj.Remarks = 'Late Charge for '+dtm1.format('MMMM YYYY');
                        }else{
                            Datetime dtm2 = Datetime.NewInstance(oldDate.year(),oldDate.month(),oldDate.day());                                            
                            disObj.Remarks = 'Late Charge for '+dtm2.format('MMMM YYYY') +' ~ '+dtm1.format('MMMM YYYY');
                        }
                    }
                }
                
                disWrapLst.add(disObj);
                
                if(disObj.amount != null)
                    outstandingAmount += disObj.amount;
                
                
                //Fill Case receipt related with Invoices
                if(inCaseDetilMap.containsKey(inv.Id)){
                    for(Cash_Detail__c casDet : inCaseDetilMap.get(inv.Id)){
                        DisplayWrapper disObjCaseRec = new DisplayWrapper();
                        disObjCaseRec.caseRecNo = casDet.Cash_Receipt__c != null ? casDet.Cash_Receipt__r.Name : '';
                        disObjCaseRec.invDepNo = casDet.Invoice__c != null ? casDet.Invoice__r.Name : '';
                        disObjCaseRec.billingType = 'Cash Receipt';
                        disObjCaseRec.amount = -casDet.Amount_Paid__c;
                        disObjCaseRec.invDepDate = casDet.Cash_Receipt__r.Payment_Date__c;
                        
                        disObjCaseRec.currencyType = casDet.Currency_Code__c;
                        if(casDet.Currency_Code__c != Label.Default_Currency){
                            disObjCaseRec.amount = -casDet.Amount_Paid_Local__c;
                            disObjCaseRec.locCurren = -casDet.Amount_Paid__c;
                        }
                        disWrapLst.add(disObjCaseRec);
                        
                        if(disObjCaseRec.amount != null)
                            outstandingAmount += disObjCaseRec.amount;
                    }
                } 
                
            }
        }catch(Exception e){
            system.debug('@@@@@'+e.getmessage());
        }
        
        return disWrapLst;
        
     }
    
    
    
    public class DisplayWrapper{
        public string caseRecNo{get;set;}
        public string invDepNo{get;set;}
        public string billingType{get;set;}
        public decimal amount{get;set;}
        public date invDepDate{get;set;}
        public string remarks{get;set;}
        public string currencyType{get;set;}
        public decimal locCurren{get;set;}
         
        public DisplayWrapper(){
        }
    }
    
}