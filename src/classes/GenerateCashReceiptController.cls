public With Sharing class GenerateCashReceiptController {
public string timeStr{get;set;}
    public decimal totalpayment {get;set;}
    public Cash_Receipt__c cr {get;set;}
    public String InvNumber {get;set;}
    public Contact con {get;set;}
    public Rent_Roll__c rroll {get;set;}
    public Boolean showResult {get;set;}
    public List<displayWrapper> displayWrapList{get;set;}
    List<Property__c> propList;    
    List<Account> tenantList;
    public decimal totalOutstandingAmount{get;set;}
    public decimal totalOutstandingAmountLocal{get;set;}
    public decimal totalOutstandingAmountForeign{get;set;}
    public decimal totalPaidAmount{get;set;}
    public decimal totalPaidAmountLocal{get;set;}
    public decimal totalPaidAmountForeign{get;set;}
    public decimal totalPenaltyAmount{get;set;}
    public decimal totalPenaltyAmountLocal{get;set;}
    public decimal totalPenaltyAmountForeign{get;set;}
    public decimal variance{get;set;}
    public decimal unAppliedAmount{get;set;}
    public string paymentCurrency{get;set;}
    public set<string> invNumberSet{get;set;}
    public string currencyCode{get;set;}
    public Boolean success{get;set;}
    public string attachId{get;set;}
    
    public Currency_Offset_Limit__c curOffLimit{get;set;}
    
    public GenerateCashReceiptController(){
        success = false;
        invNumberSet = new Set<string>();
        curOffLimit = new Currency_Offset_Limit__c();
        totalOutstandingAmount = 0;
        totalOutstandingAmountLocal = 0;
        totalOutstandingAmountForeign = 0;
        totalPaidAmount = 0;
        totalPaidAmountLocal = 0;
        totalPaidAmountForeign = 0;
        variance= 0;
        unAppliedAmount = 0;
        tenantList = new List<Account>();
        propList = new List<Property__c>();
        displayWrapList = new List<DisplayWrapper>();
        InvNumber='';
        cr = new Cash_Receipt__c();
        cr.Payment_Currency__c = label.Default_Currency;
        cr.Payment_Mode__c = label.Default_Payment_Mode;
        cr.Payment_Date__c=system.today();
        con = new Contact();
        con.AccountId=ApexPages.currentPage().getParameters().get('tid');//Adding Tenantid for Generate SOA button
        rroll = new Rent_Roll__c();
        showResult=false;
        
    }
    
    public void modPaymentCurrency(){
        showResult=false;
        displayWrapList = new List<DisplayWrapper>();
        if((rroll.Property__c!=null && con.AccountId!=null) || (invNumber!=null && invNumber.trim().length()>0)){
            search();
        }
    }
    
    public pageReference search(){
        showResult=false;
        currencyCode = label.Default_Currency;
        Boolean fromInvoice = false;
        displayWrapList = new List<DisplayWrapper>();
        totalOutstandingAmount = 0;
        totalOutstandingAmountLocal = 0;
        totalOutstandingAmountForeign = 0;
        totalPaidAmount = 0;
        totalPaidAmountLocal = 0;
        totalPaidAmountForeign = 0;
        variance= 0;
        unAppliedAmount = 0;
        try{
                if((rroll.Property__c!=null && con.AccountId!=null) || (invNumber!=null && invNumber.trim().length()>0)){
                    if(cr.Payment_Mode__c!=null){
                        if(cr.Payment_Date__c!=null){
                            list<Invoice__c> invList = new list<Invoice__c>();
                            list<Deposit__c> depList = new list<Deposit__c>();
                            if(InvNumber!=null && InvNumber.trim().length()>0){
                                invNumberSet.add(invNumber);
                                Boolean searchedNumPresent = false;
                                
                                depList = new list<Deposit__c>([SELECT Id,Name,Outstanding_Amount__c,Amount_Paid__c,Tenant__c,Property__c,Deposit_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Deposit_Type__c,Currency_Code__c,Exchange_Rate__c,Deposit_Amount_Local__c,Deposit_Amount_Foreign__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Description__c FROM Deposit__c WHERE name in:invNumberSet and Outstanding_Amount__c!=0 and Status__c!='Cancelled' and Status__c!='Rejected' and voided__c=false ORDER BY CreatedDate ASC]);
                                
                                invList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE Outstanding_Amount__c!=0 and Name in:invNumberSet and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c!='Credit Note' ORDER BY CreatedDate ASC];
                                
                                if(cr.Payment_Mode__c=='Credit Note'){
                                    for(Invoice__c inv:[SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE Remaining_Amount__c!=0 and Name in:invNumberSet and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c='Credit Note' ORDER BY CreatedDate ASC]){
                                        invList.add(inv);
                                    }
                                }
                                
                                Set<Id> propIds = new Set<Id>();
                                Set<Id> tntIds = new Set<Id>();
                                
                                for(Deposit__c dp:depList){ 
                                    if(cr.Payment_Currency__c!=label.Default_Currency && dp.Currency_code__c==label.Default_Currency){
                                        showResult=false;
                                        invNumberSet = new Set<string>();
                                        invNumber = null;
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Scanned Invoice is not defined in selected Payment Currency.'));
                                        return null;
                                    }
                                    propIds.add(dp.Property__c);
                                    tntIds.add(dp.Tenant__c);
                                    if(dp.Name==invNumber){
                                        searchedNumPresent = true;
                                    }
                                }
                                
                                
                                for(Invoice__c inv:invList){ 
                                    if(cr.Payment_Currency__c!=label.Default_Currency && inv.Currency_code__c==label.Default_Currency){
                                        showResult=false;
                                        invNumberSet = new Set<string>();
                                        invNumber = null;
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Scanned Invoice is not defined in selected Payment Currency.'));
                                        return null;
                                    }
                                    propIds.add(inv.Property__c);
                                    propIds.add(inv.Property_Name__c);
                                    tntIds.add(inv.Tenant__c);
                                    tntIds.add(inv.Tenant_Name__c);
                                    if(inv.Name==invNumber){
                                        searchedNumPresent = true;
                                    }
                                }
                                
                                propList = [Select id,Short_Code__c,Cash_Receipt_Index__c,Late_Charge_By__c,Rent_Roll_Index__c from Property__c where id in:propIds];
                                tenantList = [Select id from Account where id in:tntIds];
                                
                                if(propList.size()>1 || tenantList.size()>1){
                                    showResult=false;
                                    invNumberSet = new Set<string>();
                                    invNumber = null;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'All Invoices should be of same Property and Tenant.'));
                                    return null;
                                }
                                
                                invNumber = null;
                                
                                if(!searchedNumPresent && (depList.size()>0 || invList.size()>0)){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No outstanding record found. Please filter your search criteria.'));
                                }
                                
                                fromInvoice = true;
                            }else{
                                propList = [Select id,Short_Code__c,Cash_Receipt_Index__c,Late_Charge_By__c,Rent_Roll_Index__c from Property__c where id=:rRoll.Property__c];
                                                                
                                if(cr.Payment_Currency__c!=label.Default_Currency){
                                    depList = new list<Deposit__c>([SELECT Id,Name,Outstanding_Amount__c,Amount_Paid__c,Tenant__c,Property__c,Deposit_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Deposit_Type__c,Currency_Code__c,Exchange_Rate__c,Deposit_Amount_Local__c,Deposit_Amount_Foreign__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Description__c FROM Deposit__c WHERE Tenant__c=:con.AccountId and Property__c=:rroll.Property__c and Outstanding_Amount__c!=0 and Currency_Code__c=:cr.Payment_Currency__c and Status__c!='Cancelled' and Status__c!='Rejected' and voided__c=false ORDER BY CreatedDate ASC]);
                                }else{
                                    depList = new list<Deposit__c>([SELECT Id,Name,Outstanding_Amount__c,Amount_Paid__c,Tenant__c,Property__c,Deposit_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Deposit_Type__c,Currency_Code__c,Exchange_Rate__c,Deposit_Amount_Local__c,Deposit_Amount_Foreign__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Description__c FROM Deposit__c WHERE Tenant__c=:con.AccountId and Property__c=:rroll.Property__c and Outstanding_Amount__c!=0 and Status__c!='Cancelled' and Status__c!='Rejected' and voided__c=false ORDER BY CreatedDate ASC]);
                                }
                                
                                if(cr.Payment_Currency__c!=label.Default_Currency){
                                    invList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE (Property__c=:rroll.Property__c or Property_Name__c=:rRoll.Property__c) and (Tenant__c=:con.AccountId or Tenant_Name__c=:con.AccountId) and Outstanding_Amount__c!=0 and Currency_Code__c=:cr.Payment_Currency__c and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c!='Credit Note' ORDER BY CreatedDate ASC];
                                }else{
                                    invList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE (Property__c=:rroll.Property__c or Property_Name__c=:rRoll.Property__c) and (Tenant__c=:con.AccountId or Tenant_Name__c=:con.AccountId) and Outstanding_Amount__c!=0 and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c!='Credit Note' ORDER BY CreatedDate ASC];
                                }                                
                                
                                if(cr.Payment_Mode__c=='Credit Note'){
                                    List<Invoice__c> tempList = new List<Invoice__c>();
                                    if(cr.Payment_Currency__c!=label.Default_Currency){
                                        tempList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE Property__c=:rroll.Property__c and Tenant__c=:con.AccountId and Remaining_Amount__c!=0 and Currency_Code__c=:cr.Payment_Currency__c and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c='Credit Note' ORDER BY CreatedDate ASC];
                                    }else{
                                        tempList = [SELECT Id,Invoice_Date__c,Name,Property__c,Tenant__c,Property_Name__c,Tenant_Name__c,Outstanding_Amount__c,Amount_Paid__c,Description__c,Total_Amount__c,Payment_Due_Date__c,Lease__r.Late_Payment_Interest__c,Billing_Type__c,Last_Payment_Date__c,Currency_Code__c,Exchange_Rate__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c,Total_Amount_Local__c,Total_Amount_Foreign__c,Total_Refunded_Amount__c, Requested_Amount__c,Rent_Roll__r.Billing_Type__c,Refund_Status__c,Foreign_Exchange_Rate__c,(Select id,Charge_Name__c,Invoice_old__c,Invoice_old__r.Invoice_Date__c,Start_Date__c,End_Date__c,Due_Days__c,Transaction_Start_Date__c,Transaction_End_Date__c,Charge_Type__c from Invoice_Line_Items__r) FROM Invoice__c WHERE Property__c=:rroll.Property__c and Tenant__c=:con.AccountId and Remaining_Amount__c!=0 and Status__c!='Cancelled' and Voided__c=false and Billing_Type__c='Credit Note' ORDER BY CreatedDate ASC];
                                    }                                
                                    for(Invoice__c inv:tempList){
                                        invList.add(inv);
                                    }
                                }
                            }
                            
                            if(depList.size()>0){
                                decimal baseDays= 30.00;
                                if(propList.size()>0){
                                    if(propList[0].Late_Charge_By__c=='30 Days'){
                                        baseDays = 30.00;
                                    }else if(propList[0].Late_Charge_By__c=='By Month'){
                                        baseDays = Date.DaysInMonth(system.today().year(),system.today().month());
                                    }
                                }
                                for(Deposit__c dp:depList){
                                    DisplayWrapper dw = new DisplayWrapper();
                                    dw.invDepNo = dp.Name;
                                    dw.depositId = dp.Id;
                                    dw.propertyId = dp.Property__c;
                                    dw.tenantId = dp.Tenant__c;
                                    dw.totalAmount = dp.Deposit_Amount__c;
                                    dw.outstandingAmount = dp.Outstanding_Amount__c;
                                    dw.paymentDueDate = dp.Payment_Due_Date__c;
                                    dw.latePaymentInterest = dp.Lease__r.Late_Payment_Interest__c;
                                    if(dw.totalAmount>0 && dp.Payment_Due_Date__c<system.today()){
                                        dw.dueDays = dp.Payment_Due_Date__c.daysBetween(system.today());
                                        if(dp.Lease__r.Late_Payment_Interest__c!=null && dp.Outstanding_Amount__c>0){
                                            dw.penaltyAmount = dp.Outstanding_Amount__c*(dw.dueDays/baseDays)*dp.lease__r.Late_Payment_Interest__c/100;
                                        }
                                    }
                                    
                                    dw.billingType = dp.Deposit_Type__c;
                                    
                                    dw.currencyCode = dp.Currency_Code__c;
                                    if(dw.currencyCode==null){
                                        dw.currencyCode = label.Default_Currency;
                                    }
                                    dw.totalAmountLocal = dp.Deposit_Amount_Local__c;
                                    dw.totalAmountForeign = dp.Deposit_Amount_Foreign__c;
                                    dw.outstandingAmountLocal = dp.Outstanding_Amount_Local__c;
                                    dw.outstandingAmountForeign = dp.Outstanding_Amount_Foreign__c;
                                    
                                    if(fromInvoice){
                                        if(dw.currencyCode!=label.Default_Currency){
                                            if(cr.Payment_Currency__c==label.Default_Currency){
                                                dw.amountPaid = dw.outstandingAmountLocal;
                                            }else{
                                                dw.amountPaid = dw.outstandingAmountForeign;
                                            }
                                        }else{
                                            dw.amountPaid = dw.outstandingAmountLocal;
                                        }
                                        dw.selectRecord = true;
                                    }
                                    
                                    if(dw.penaltyAmount!=null && dw.penaltyAmount>0){
                                        if(dw.currencyCode!=label.Default_Currency){
                                            if(dp.Exchange_Rate__c!=null){
                                                dw.penaltyAmountLocal = dw.penaltyAmount*dp.Exchange_Rate__c;
                                            }
                                            dw.penaltyAmountForeign = dw.penaltyAmount;
                                        }else{
                                            dw.penaltyAmountLocal = dw.penaltyAmount;
                                        }
                                    }
                                    if(dp.Exchange_Rate__c!=null){
                                        dw.exchangeRate = dp.Exchange_Rate__c;
                                    }
                                    
                                    dw.remarks = dp.Description__c;
                                    
                                    displayWrapList.add(dw);
                                    totalOutstandingAmount += (dw.outstandingAmount!=null?dw.outstandingAmount:0);
                                    totalOutstandingAmountLocal += (dw.outstandingAmountLocal!=null?dw.outstandingAmountLocal:0);
                                    totalOutstandingAmountForeign += (dw.outstandingAmountForeign!=null?dw.outstandingAmountForeign:0);
                                    
                                    if(dw.currencyCode!=label.Default_Currency && dw.currencyCode!=label.Base_Foreign_Currency){
                                        showResult=false;
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Invoice should be in '+label.Default_Currency+' or USD.'));
                                        return null;
                                    }
                                    
                                    if(dw.currencyCode==label.Base_Foreign_Currency){
                                        currencyCode = dw.currencyCode;
                                    }
                                    
                                }
                            }
                                
                            if(invList.size()>0){
                                decimal baseDays= 30.00;
                                if(propList.size()>0){
                                    if(propList[0].Late_Charge_By__c=='30 Days'){
                                        baseDays = 30.00;
                                    }else if(propList[0].Late_Charge_By__c=='By Month'){
                                        baseDays = Date.DaysInMonth(system.today().year(),system.today().month());
                                    }
                                }
                                
                                Map<Id,Map<string,date>> invRentStartDtMap = new Map<Id,Map<string,date>>();
                                Map<Id,Map<string,date>> invRentEndDtMap = new Map<Id,Map<string,date>>();
                                
                                Map<Id,Map<string,date>> invGTORentStartDtMap = new Map<Id,Map<string,date>>();
                                Map<Id,Map<string,date>> invGTORentEndDtMap = new Map<Id,Map<string,date>>();
                                
                                Map<Id,Date> invMonthlyDateMap = new Map<Id,Date>();
                                
                                for(Invoice__c inv:invList){
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
                                        }else if(inv.billing_Type__c=='GTO Rent' && ili.charge_Name__c!=null && ili.Transaction_Start_Date__c!=null && ili.Transaction_End_Date__c!=null){
                                            Map<string,date> tempStartMap = new Map<string,date>();
                                            Map<string,date> tempEndMap = new Map<string,date>();
                                            
                                            if(invGTORentStartDtMap.containsKey(inv.Id)){
                                                tempStartMap = invGTORentStartDtMap.get(inv.Id);
                                            }
                                            
                                            if(invGTORentEndDtMap.containsKey(inv.Id)){
                                                tempEndMap = invGTORentEndDtMap.get(inv.Id);
                                            }
                                            
                                            Date tempStDate = null;
                                            if(tempStartMap.containsKey(ili.Charge_Name__c)){
                                                tempStDate = tempStartMap.get(ili.Charge_Name__c);
                                            }
                                            
                                            if(tempStDate==null || tempStDate>ili.Transaction_Start_Date__c){
                                                tempStartMap.put(ili.Charge_Name__c,ili.Transaction_Start_Date__c);
                                            }
                                            invGTORentStartDtMap.put(inv.Id,tempStartMap);
                                            
                                            Date tempEndDate = null;
                                            if(tempEndMap.containsKey(ili.Charge_Name__c)){
                                                tempEndDate = tempEndMap.get(ili.Charge_Name__c);
                                            }
                                            
                                            if(tempEndDate==null || tempEndDate<ili.Transaction_End_Date__c){
                                                tempEndMap.put(ili.Charge_Name__c,ili.Transaction_End_Date__c);
                                            }
                                            invGTORentEndDtMap.put(inv.Id,tempEndMap);
                                            
                                        }
                                    }
                                }
                                
                                for(Invoice__c inv:invList){
                                    DisplayWrapper dw = new DisplayWrapper();
                                    dw.invDepNo = inv.Name;
                                    dw.invoiceId = inv.Id;
                                    dw.propertyId = (inv.Property__c!=null?inv.Property__c:inv.Property_Name__c);
                                    dw.tenantId = (inv.Tenant__c!=null?inv.Tenant__c:inv.Tenant_Name__c);
                                    dw.totalAmount = inv.Total_Amount__c;
                                    dw.outstandingAmount = inv.Outstanding_Amount__c;
                                    
                                    dw.paymentDueDate = inv.Payment_Due_Date__c;
                                    dw.latePaymentInterest = inv.Lease__r.Late_Payment_Interest__c;
                                    
                                    totalOutstandingAmount += (dw.outstandingAmount!=null?dw.outstandingAmount:0);
                                    
                                    
                                    if(dw.totalAmount>0 && ((inv.Last_Payment_Date__c!=null && inv.Last_Payment_Date__c<system.today()) || (inv.Payment_Due_Date__c<system.today()))){
                                        if(inv.Last_Payment_Date__c!=null){
                                            dw.dueDays = inv.Last_Payment_Date__c.daysBetween(system.today());
                                        }else{
                                            dw.dueDays = inv.Payment_Due_Date__c.daysBetween(system.today());
                                        }
                                        
                                        if(dw.dueDays>0 && inv.Lease__r.Late_Payment_Interest__c!=null && inv.Outstanding_Amount__c>0){
                                            dw.penaltyAmount = (inv.Outstanding_Amount__c*(dw.dueDays/baseDays)*(inv.lease__r.Late_Payment_Interest__c/100));
                                        }
                                        
                                        if(dw.dueDays==0){
                                            dw.dueDays=null;
                                        }
                                    }
                                    dw.billingType = inv.Billing_Type__c;
                                    
                                    dw.currencyCode = inv.Currency_Code__c;
                                    if(dw.currencyCode==null){
                                        dw.currencyCode = label.Default_Currency;
                                    }
                                    dw.totalAmountLocal = inv.Total_Amount_Local__c;
                                    dw.totalAmountForeign = inv.Total_Amount_Foreign__c;
                                    
                                    //Total_Refunded_Amount__c  Requested_Amount__c
                                    if(inv.Rent_Roll__r.Billing_Type__c == 'Credit Note'){
                                        inv.Total_Refunded_Amount__c = (inv.Total_Refunded_Amount__c!= null)?inv.Total_Refunded_Amount__c:0;
                                        inv.Requested_Amount__c = (inv.Requested_Amount__c!= null)?inv.Requested_Amount__c:0;
                                        inv.Outstanding_Amount_Local__c = (inv.Outstanding_Amount_Local__c!= null)?inv.Outstanding_Amount_Local__c:0;
                                        inv.Outstanding_Amount_Foreign__c = (inv.Outstanding_Amount_Foreign__c!= null)?inv.Outstanding_Amount_Foreign__c:0;
                                        
                                        Decimal refundedAmt = inv.Total_Refunded_Amount__c - ((inv.Refund_Status__c =='Submitted')?inv.Requested_Amount__c:0);
                                        
                                        Decimal exchRate = (inv.Foreign_Exchange_Rate__c == null )?inv.Exchange_Rate__c:inv.Foreign_Exchange_Rate__c;
                                        //if(inv.Currency_Code__c == label.Default_Currency){
                                        dw.outstandingAmountLocal = inv.Outstanding_Amount_Local__c - refundedAmt;
                                        dw.outstandingAmountForeign = inv.Outstanding_Amount_Foreign__c - (refundedAmt / exchRate);
                                        
                                        dw.outstandingAmountLocal = dw.outstandingAmountLocal.setScale(2);
                                        dw.outstandingAmountForeign = dw.outstandingAmountForeign.setScale(2);
                                    }else{
                                        dw.outstandingAmountLocal = inv.Outstanding_Amount_Local__c;
                                        dw.outstandingAmountForeign = inv.Outstanding_Amount_Foreign__c;
                                    }
                                        
                                    if(fromInvoice){
                                        if(dw.currencyCode!=label.Default_Currency){
                                            if(cr.Payment_Currency__c==label.Default_Currency){
                                                dw.amountPaid = dw.outstandingAmountLocal;
                                            }else{
                                                dw.amountPaid = dw.outstandingAmountForeign;
                                            }
                                        }else{
                                            dw.amountPaid = dw.outstandingAmountLocal;
                                        }
                                        dw.selectRecord = true;
                                    }
                                    
                                    if(dw.penaltyAmount!=null && dw.penaltyAmount>0){
                                        if(dw.currencyCode!=label.Default_Currency){
                                            if(inv.Exchange_Rate__c!=null){
                                                dw.penaltyAmountLocal = dw.penaltyAmount*inv.Exchange_Rate__c;
                                            }
                                            dw.penaltyAmountForeign = dw.penaltyAmount;   
                                        }else{
                                            dw.penaltyAmountLocal = dw.penaltyAmount;
                                        }
                                    }
                                    
                                    if(inv.Exchange_Rate__c!=null){
                                        dw.exchangeRate = inv.Exchange_Rate__c;
                                    }
                                    
                                    totalOutstandingAmountLocal += (dw.outstandingAmountLocal!=null?dw.outstandingAmountLocal:0);
                                    totalOutstandingAmountForeign += (dw.outstandingAmountForeign!=null?dw.outstandingAmountForeign:0);
                                    
                                    if(inv.billing_Type__c=='Rent'){
                                        if(invRentStartDtMap.containsKey(inv.Id) && invRentEndDtMap.containsKey(inv.Id)){
                                            Map<string,Date> tempStartMap = invRentStartDtMap.get(inv.Id);
                                            Map<string,Date> tempEndMap = invRentEndDtMap.get(inv.Id);
                                            
                                            dw.Remarks = '';
                                            for(string chgName:tempStartMap.keyset()){
                                                if(tempEndMap.containsKey(chgName) && tempStartMap.get(chgName)!=null && tempEndMap.get(chgName)!=null){
                                                    Datetime startDt = Datetime.NewInstance(tempStartMap.get(chgName).year(),tempStartMap.get(chgName).month(),tempStartMap.get(chgName).day());
                                                    Datetime EndDt = Datetime.NewInstance(tempEndMap.get(chgName).year(),tempEndMap.get(chgName).month(),tempEndMap.get(chgName).day());                                                    
                                                    dw.Remarks = dw.Remarks + 'Rental Bill for '+ startDt.format('dd MMMM YYYY') + ' ~ '+ EndDt.format('dd MMMM YYYY')+'\n';
                                                }
                                            }
                                            if(dw.remarks!=null && dw.remarks.trim().length()>0){
                                                if(dw.remarks.endsWith('\n')){
                                                    dw.Remarks = dw.remarks.substring(0,dw.remarks.length()-1);
                                                }
                                            }
                                        }
                                    }else if(inv.Billing_Type__c=='Monthly'){
                                        if(invMonthlyDateMap.containsKey(inv.Id)){
                                            Datetime dtm = Datetime.NewInstance(invMonthlyDateMap.get(inv.Id).year(),invMonthlyDateMap.get(inv.Id).month(),invMonthlyDateMap.get(inv.Id).day());
                                            dw.Remarks = 'Monthly Bill for '+dtm.format('MMMM YYYY');
                                        }
                                    }else if(inv.Billing_Type__c=='Debit Note'){
                                        if(inv.invoice_Line_Items__r.size()>0 && inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c!=null){
                                            Datetime dtm = Datetime.NewInstance(inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.year(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.month(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.day());
                                            dw.Remarks = 'Debit Note for '+dtm.format('MMMM YYYY');
                                        }
                                    }else if(inv.Billing_Type__c=='Credit Note'){
                                        if(inv.invoice_Line_Items__r.size()>0  && inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c!=null){
                                            Datetime dtm = Datetime.NewInstance(inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.year(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.month(),inv.invoice_Line_Items__r[0].Invoice_Old__r.Invoice_Date__c.day());
                                            dw.Remarks = 'Credit Note for '+dtm.format('MMMM YYYY');
                                        }
                                    }else if(inv.Billing_Type__c=='Ad-Hoc Invoice'){
                                        if(inv.Invoice_Date__c!=null){
                                            Datetime dtm = Datetime.NewInstance(inv.Invoice_Date__c.year(),inv.Invoice_Date__c.month(),inv.Invoice_Date__c.day());
                                            dw.Remarks = 'Miscellaneous Invoice for '+dtm.format('MMMM YYYY');
                                        }
                                    }else if(inv.Billing_Type__c=='Late Charge'){
                                        if(inv.Invoice_Date__c!=null && inv.invoice_Line_Items__r.size()>0 && inv.invoice_Line_Items__r[0].Due_Days__c!=null){
                                            Date oldDate = inv.Invoice_Date__c.addDays(-Integer.valueOf(inv.invoice_Line_Items__r[0].Due_Days__c));
                                            Datetime dtm1 = Datetime.NewInstance(inv.Invoice_Date__c.year(),inv.Invoice_Date__c.month(),inv.Invoice_Date__c.day());                                            
                                            if(oldDate.month()==inv.Invoice_Date__c.month()){
                                                dw.Remarks = 'Late Charge for '+dtm1.format('MMMM YYYY');
                                            }else{
                                                Datetime dtm2 = Datetime.NewInstance(oldDate.year(),oldDate.month(),oldDate.day());                                            
                                                dw.Remarks = 'Late Charge for '+dtm2.format('MMMM YYYY') +' ~ '+dtm1.format('MMMM YYYY');
                                            }
                                        }
                                    }else if(inv.billing_Type__c=='GTO Rent'){
                                        if(invGTORentStartDtMap.containsKey(inv.Id) && invGTORentEndDtMap.containsKey(inv.Id)){
                                            Map<string,Date> tempStartMap = invGTORentStartDtMap.get(inv.Id);
                                            Map<string,Date> tempEndMap = invGTORentEndDtMap.get(inv.Id);
                                            
                                            dw.Remarks = '';
                                            for(string chgName:tempStartMap.keyset()){
                                                if(tempEndMap.containsKey(chgName)){
                                                    Datetime startDt = Datetime.NewInstance(tempStartMap.get(chgName).year(),tempStartMap.get(chgName).month(),tempStartMap.get(chgName).day());
                                                    Datetime EndDt = Datetime.NewInstance(tempEndMap.get(chgName).year(),tempEndMap.get(chgName).month(),tempEndMap.get(chgName).day());
                                                    dw.Remarks = dw.Remarks + 'GTO Bill for '+ startDt.format('dd MMMM YYYY') + ' ~ '+ endDt.format('dd MMMM YYYY')+'\n';
                                                }
                                            }
                                            if(dw.remarks!=null && dw.remarks.trim().length()>0){
                                                if(dw.remarks.endsWith('\n')){
                                                    dw.Remarks = dw.remarks.substring(0,dw.remarks.length()-1);
                                                }
                                            }
                                        }
                                    }else if(inv.billing_Type__c=='Miscellaneous'){
                                        dw.Remarks = 'Miscellaneous Invoice';
                                    }
                                    
                                    
                                    displayWrapList.add(dw);
                                    
                                    if(dw.currencyCode!=label.Default_Currency && dw.currencyCode!=label.Base_Foreign_Currency){
                                        showResult=false;
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Invoice should be in '+label.Default_Currency+' or USD.'));
                                        return null;
                                    }
                                    
                                    if(dw.currencyCode==label.Base_Foreign_Currency){
                                        currencyCode = dw.currencyCode;
                                    }
                                }
                            }
                            
                            if(cr.Payment_Mode__c=='Payment Voucher'){
                                string tenantId;
                                string propertyId;
                                if(depList.size()>0){
                                    tenantId = depList[0].Tenant__c;
                                    propertyId = depList[0].Property__c;
                                }else if(invList.size()>0){
                                    tenantId = invList[0].Tenant__c;
                                    if(invList[0].Property__c!=null){
                                        propertyId = invList[0].Property__c;
                                    }else{
                                        propertyId = invList[0].Property_Name__c;
                                    }
                                }
                                List<Payment_Voucher__c> pvList = [Select id,Exchange_Rate__c,Name,Lease__r.Property__c,Lease__r.Tenant__c,Amount__c,Outstanding_Amount__c,Amount_Local__c,Amount_Foreign__c,Currency_Code__c,Outstanding_Amount_Local__c,Outstanding_Amount_Foreign__c from Payment_Voucher__c where Outstanding_Amount__c<0 and Refund_Mode__c='Offset Invoice' and Property__c=:propertyId and Lease__r.Tenant__c=:tenantId and Status__c='New'];
                                if(pvList.size()>0){
                                    for(Payment_Voucher__c pv:pvList){
                                        DisplayWrapper dw = new DisplayWrapper();
                                        dw.paymentVoucherId = pv.Id;
                                        dw.invDepNo = pv.Name;
                                        dw.propertyId = pv.Lease__r.Property__c;
                                        dw.tenantId = pv.Lease__r.Tenant__c;
                                        dw.currencyCode = pv.Currency_Code__c;
                                        dw.exchangeRate = pv.Exchange_Rate__c;
                                        dw.totalAmount = pv.Amount__c;
                                        dw.TotalAmountLocal = pv.Amount_Local__c;
                                        dw.TotalAmountForeign = pv.Amount_Foreign__c;
                                        dw.outstandingAmount = pv.Outstanding_Amount__c;
                                        dw.outstandingAmountLocal = pv.Outstanding_Amount_Local__c;
                                        dw.outstandingAmountForeign = pv.Outstanding_Amount_Foreign__c;
                                        dw.billingType = 'Payment Voucher';
                                        displayWrapList.add(dw);
                                    }
                                }
                            }
                                
                            if(displayWrapList.size()==0){
                                showResult=false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No outstanding record found. Please filter your search criteria.'));
                            }else{
                                if(currencyCode==label.Default_Currency){
                                    cr.payment_Currency__c = label.Default_Currency;
                                }
                                showResult = true;
                                List<Currency_Offset_Limit__c> curOffLmtList = [Select id,Name,Upper_Limit__c,Lower_Limit__c from Currency_Offset_Limit__c where name=:cr.payment_Currency__c];
                                Integer upperLimit = 0;
                                Integer lowerLimit = 0;
                                if(curOffLmtList.size()>0){
                                    curOffLimit = curOffLmtList[0];
                                    if(curOffLimit.Upper_Limit__c!=null){
                                        upperLimit = Integer.valueOf(curOffLimit.Upper_Limit__c);
                                    }
                                    if(curOffLimit.Lower_Limit__c!=null){
                                        lowerLimit = Integer.valueOf(curOffLimit.Lower_Limit__c);
                                    }
                                }
                                
                                
                                if(totalpayment!=null && totalpayment>0){
                                    Decimal tempAmt = totalpayment;
                                    for(displayWrapper dw:displayWrapList){
                                        if(cr.payment_Currency__c==label.Default_Currency){
                                            if(dw.outstandingAmountLocal >= tempAmt){
                                                dw.amountPaid = tempAmt;
                                                if((totalPayment - totalOutstandingAmountLocal)<0 && (totalOutstandingAmountLocal - totalPayment)<=lowerLimit){
                                                    dw.amountPaid += (totalOutstandingAmountLocal - totalPayment);
                                                    variance = totalOutstandingAmountLocal - totalPayment;
                                                }
                                                
                                                dw.selectRecord = true;
                                                tempAmt = 0;
                                            }else{
                                                dw.amountPaid = dw.outstandingAmountLocal;
                                                tempAmt = tempAMt - dw.outstandingAmountLocal;
                                                dw.selectRecord = true;
                                            }
                                        }else{
                                            if(dw.outstandingAmountForeign >= tempAmt){
                                                dw.amountPaid = tempAmt;
                                                if((totalPayment - totalOutstandingAmountForeign)<0 && (totalOutstandingAmountForeign - totalPayment)<=lowerLimit){
                                                    dw.amountPaid += (totalOutstandingAmountForeign - totalPayment);
                                                    variance = totalOutstandingAmountForeign - totalPayment;
                                                }
                                                
                                                dw.selectRecord = true;
                                                tempAmt = 0;
                                            }else{
                                                dw.amountPaid = dw.outstandingAmountForeign;
                                                tempAmt = tempAmt - dw.outstandingAmountForeign;
                                                dw.selectRecord = true;
                                            }
                                        }
                                        
                                        if(tempAmt==0){
                                            break;
                                        }
                                    }
                                }
                                calculation();
                            }
                        }else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Date : value is required.'));
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Mode: value is required.'));
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter (Property and Tenant) or Invoice Number.'));
                }
        }catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('Test===='+e.getLineNumber());
            
        }
        return null;
    }
    
    public pageReference generateCashReceipt(){
        calculation();
        decimal totalPaid = 0;
        Integer totalSelected = 0;
        for(displayWrapper dw:displayWrapList){
            if(dw.selectRecord){
                if(dw.billingtype!='Credit Note' && dw.billingtype!='Payment Voucher' && dw.amountPaid<0  && (dw.outstandingAmountLocal >=0 || dw.totalAmountLocal >= 0)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Amount Paid should not be less than or equal to 0 where Outstanding Amount is positive.'));
                    return null;
                }
                if((dw.billingtype=='Credit Note' || dw.billingtype=='Payment Voucher') && dw.amountPaid>=0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Amount Paid should not be more than or equal to 0 where Outstanding Amount is negative.'));
                    return null;
                }
                if(dw.currencyCode!=label.Default_Currency && cr.Payment_Currency__c==label.Base_Foreign_Currency){
                    if((dw.outstandingAmountForeign>0 && dw.amountPaid > dw.outstandingAmountForeign) || (dw.outstandingAmountForeign<0 && dw.amountPaid < dw.outstandingAmountForeign)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Amount Paid cannot exceed Outstanding Amount for selected rows.'));
                        return null;
                    }    
                }else{
                    if((dw.outstandingAmountLocal>0 && dw.amountPaid > dw.outstandingAmountLocal) || (dw.outstandingAmountLocal<0 && dw.amountPaid < dw.outstandingAmountLocal)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Amount Paid cannot exceed Outstanding Amount for selected rows.'));
                        return null;
                    }
                }
                
                totalPaid += dw.amountPaid;
                totalSelected++;
            }
        }
        
        if(totalSelected==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast 1 record.'));
            return null;
        }
        
        if(cr.Payment_Mode__c=='Credit Note' || cr.Payment_Mode__c=='Payment Voucher'){
            if(totalPayment!=0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Payment is not applicable when Payment Mode is either Credit Note or Payment Voucher.'));
                return null;
            }
            
            /*if((totalPaid+totalPenaltyAmount)!=0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Applied Amount must be equal to 0 in case of Credit Note or Payment Voucher.'));
                return null;
            }*/
        }
        
        if(totalPayment < 0 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Payment should not be less than 0.'));
            return null;
        }
        
        if(cr.Payment_Mode__c!='Credit Note' && cr.Payment_Mode__c!='Payment Voucher' && (totalPaid+variance+totalPenaltyAmount)!=totalPayment){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Applied Amount must be equal with Total Payment.'));
            return null;
        }
        
        if(cr.Payment_Mode__c=='Credit Note' && cr.Payment_Mode__c=='Payment Voucher' && (totalPaid+variance+totalPenaltyAmount)!=0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Applied Amount must be equal to 0 in case of Credit Note or Payment Voucher.'));
            return null;
        }
        
        if(curOffLimit!=null && curOffLimit.Id!=null){
            if(unAppliedAmount>0 && unAppliedAmount>curOffLimit.upper_Limit__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Un-Applied Amount cannot exceed more than ' + curOffLimit.upper_Limit__c + '.'));
                return null;
            }
            
            if(unAppliedAmount<0 && (-unAppliedAmount)>curOffLimit.lower_Limit__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Un-Applied Amount cannot deceed more than ' + curOffLimit.lower_Limit__c + '.'));
                return null;
            }
        }
        
        cr.Property__c = rRoll.Property__c;
        cr.Tenant__c = con.accountId;
        Integer IntIndex = 1;
        if(propList.size()>0){            
            Property__c prop = [Select id,Cash_Receipt_Index__c,Short_Code__c from Property__c where id=:propList[0].Id];
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
            prop.Cash_Receipt_Index__c = intIndex + 1;
            update prop;
        }
        
        if(tenantList.size()>0){
            cr.Tenant__c = tenantList[0].Id;
        }
        
        cr.Cash_Receipt_Generated__c = true;
        if(curOffLimit!=null && curOffLimit.Id!=null){
            if(variance<0){
                if((-variance)<=curOffLimit.lower_Limit__c){
                    cr.Offset_Amount__c = variance;
                }
            }else{
                if(variance<=curOffLimit.Upper_Limit__c){
                    cr.Offset_Amount__c = variance;
                }
            }
        }
        
        insert cr;
        
        Map<Id,Decimal> penaltyCollectMap = new Map<Id,decimal>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Cash_Detail__c> cashDetailList = new List<Cash_Detail__c>();
        Boolean penaltyAdded = false;
        for(displayWrapper dw:displayWrapList){
            if(dw.selectRecord){
                Cash_Detail__c cd = new Cash_Detail__c();
                cd.Amount_Paid__c = dw.amountPaid;
                cd.Cash_Receipt__c = cr.Id;
                cd.Deposit__c = dw.depositId;
                cd.Invoice__c = dw.invoiceId;
                cd.Payment_Voucher__c = dw.paymentVoucherId;
                if(cd.Payment_Voucher__c!=null){
                    cd.Refund_Mode__c = 'Offset Invoice';
                    cd.Paid__c = true;
                }
                cd.Remarks__c = dw.remarks;
                cd.Payment_Mode__c = cr.payment_Mode__c;
                cd.Currency_Code__c = cr.Payment_Currency__c;
                
                cashDetailList.add(cd);
                
                if(dw.invoiceId!=null){
                    Invoice__c inv = new Invoice__c();
                    inv.Id = dw.invoiceId;
                    inv.Last_Payment_Date__c = system.today();
                    invoiceList.add(inv);
                }
                
                
                if(dw.applyPenalty && dw.penaltyAmount>0){
                    if(cr.Payment_Currency__c==label.Default_Currency){
                        penaltyCollectMap.put(dw.invoiceId,dw.penaltyAmountLocal);
                    }else{
                        penaltyCollectMap.put(dw.invoiceId,dw.penaltyAmountForeign);
                    }
                    
                    penaltyAdded = true;
                    
                }
                
                /*if(dw.penaltyAmount>0){
                    penaltyAdded = true;
                }*/
            }
        }
        
        if(penaltyAdded){
            List<Lease_Unit__c> leaseUnits = [Select id,Area_Sq_Ft__c,Unit__r.Property__c from Lease_Unit__c where Unit__r.Property__c =:propList[0].Id and Area_Sq_Ft__c!=null];
            decimal totalLeaseArea = 0;
            for(Lease_Unit__c lu:leaseUnits){
                totalLeaseArea += lu.Area_Sq_Ft__c;
            }
            Rent_Roll__c rr = new Rent_Roll__c();
            rr.Property__c = propList[0].Id;
            rr.Total_Leased_Area_Sq_Ft__c = totalLeaseArea;
            rr.Expected_Invoice_Date__c = system.today();
            rr.Actual_Invoice_Date__c = system.today();
            
            rr.Billing_Type__c = 'Late Charge';
           
            rr.Rent_Roll_YYYY__c = ''+system.today().year();
            rr.Rent_Roll_MM__c = (system.today().month()<10?'0'+system.today().month():''+system.today().month());
            Property__c prop = [Select id,Name,Rent_Roll_Index__c,Short_Code__c from Property__c where Id=:propList[0].Id];
            IntIndex = 1;
            if(prop.Rent_Roll_Index__c!=null && prop.Rent_Roll_Index__c>0){
                intIndex = Integer.valueOf(prop.Rent_Roll_Index__c);
            }
            
            Integer indexSize = string.valueOf(intIndex).length();
           
            string index = '';
            for(integer i =1;i<=6-indexSize;i++){
                index += '0';
            }
            index += string.valueOf(intIndex);
            rr.Rent_Roll_Index__c = index;
            prop.Rent_Roll_Index__c = intIndex + 1;
            rr.Name = prop.Short_Code__c+'-RO-'+system.today().year()+(system.today().month()<10?'0':'')+system.today().month()+'-'+rr.Rent_Roll_Index__c;
            rr.Notified_Finance__c = true;
            rr.Notified_Billing__c = true;            
            insert rr;
            
            update prop;
            rr.Total_Amount__c = 0;
            List<Rent_Roll_Detail__c> rrdList = new List<Rent_Roll_Detail__c>();
            for(displayWrapper dw:displayWrapList){
                if(dw.selectRecord && dw.penaltyAmount>0){
                   Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
                   rrd.Active__c = true;
                   rrd.Start_Date__c = dw.paymentDueDate + 1;
                   rrd.End_Date__c = system.today();
                   rrd.Billing_Date__c = system.today() + 1;
                   rrd.Billing_Type__c = 'Late Charge';
                   rrd.Charge_Type__c = 'Late Charge';
                   rrd.Status__c = 'Approved';
                   rrd.Remarks__c = 'Late Charge for Invoice '+dw.invDepNo;
                   //rrd.Default_Days__c = rrd.Start_Date__c.DaysBetween(rrd.End_Date__c) + 1;
                   rrd.Default_Days__c = dw.dueDays;
                   rrd.Late_Percent_Rate__c = dw.latePaymentInterest ;
                   if(dw.currencyCode==label.Default_Currency){
                       rrd.Amount__c = dw.penaltyAmountLocal;
                       rrd.Outstanding_Amount__c = dw.OutstandingAmountLocal;
                   }else{
                       rrd.Amount__c = dw.penaltyAmountForeign;
                       rrd.Outstanding_Amount__c = dw.OutstandingAmountForeign;
                   }
                   
                   rr.Total_Amount__c += rrd.Amount__c;
                   rrd.Invoice__c = dw.invoiceId;
                   rrd.Rent_Roll__c = rr.Id;
                   rrd.Currency_Code__c = dw.currencyCode;
                   rrd.Exchange_Rate__c = dw.exchangeRate;
                   
                   rrd.Property_Name_Text__c = prop.Name;
                   rrdList.add(rrd);
                }
            }
            insert rrdList;
            rr.Approved__c = true;
            update rr;
            
            List<Invoice__c> newInvoiceList = [Select id,Rent_Roll__c,Amount__c,(Select id from Invoice_Line_Items__r limit 1) from Invoice__c where Rent_Roll__c=:rr.Id];
            Set<Id> lineItmIds = new Set<Id>();
            for(Invoice__c inv:newInvoiceList){
                if(inv.Invoice_Line_Items__r.size()>0){
                    lineItmIds.add(inv.Invoice_Line_Items__r[0].Id);
                }
            }
            Map<Id,Rent_Roll_Detail__c> invToRrdMap = new Map<Id,Rent_Roll_Detail__c>();
            for(Rent_Roll_Detail__c rrd:[Select id,Invoice_Line_Item__c,Invoice_Line_Item__r.Invoice__c,Invoice__c,Invoice__r.Name,Invoice__r.Outstanding_Amount__c,Invoice__r.Lease__r.Late_Payment_Interest__c from Rent_Roll_Detail__c where Invoice_Line_Item__c in:lineItmIds]){
                invToRrdMap.put(rrd.Invoice_Line_Item__r.Invoice__c,rrd);
            }
            
            for(Invoice__c inv:newInvoiceList){
                if(invToRrdMap.containsKey(inv.Id)){
                    
                    Rent_Roll_Detail__c rrd = invToRrdMap.get(inv.Id);
                    if(penaltyCollectMap.containsKey(rrd.Invoice__c)){
                        Cash_Detail__c cd = new Cash_Detail__c();
                        cd.Amount_Paid__c = penaltyCollectMap.get(rrd.Invoice__c);
                        cd.Cash_Receipt__c = cr.Id;
                        cd.Invoice__c = inv.Id;
                        cd.Payment_Mode__c = cr.payment_Mode__c;
                        cd.Remarks__c = 'Late Charge from '+rrd.Invoice__r.Name+'; '+(rrd.Invoice__r.Outstanding_Amount__c!=null?rrd.Invoice__r.Outstanding_Amount__c.format():'')+' with interest rate of '+rrd.Invoice__r.Lease__r.Late_Payment_Interest__c+'%';
                        cd.Currency_Code__c = cr.Payment_Currency__c;
                        cashDetailList.add(cd);
                    }
                }
                
            }
        }
        insert cashDetailList;
        update invoiceList;
        success = true;
        return null;
    }
    
    public pageReference generatePDF(){
        if(success){
            Blob body;
            PageReference pdf = new PageReference('/apex/CashReceiptPDF?id='+cr.id);
            if(Test.isRunningTest()){
                body = blob.valueOf('Test');
            }else{
                body = pdf.getContentAsPDF();
            }
            
            Attachment attach = new Attachment();
            attach.Body = body;
            attach.name= cr.name+'.PDF';
            attach.ParentId = cr.id;
            insert attach;
                    
            //return new pageReference('/servlet/servlet.FileDownload?file='+attach.Id);
            attachId = attach.Id;
        }
        return null;
    }
    
    public void calculation(){
        totalPaidAmount = 0;
        totalPaidAmountLocal = 0;
        totalPaidAmountForeign = 0;
        totalPenaltyAmount = 0;
        totalPenaltyAmountLocal = 0;
        totalPenaltyAmountForeign = 0;
        variance = 0;
        unAppliedAmount = 0;
        for(displayWrapper dw:displayWrapList){
            if(dw.selectRecord){
                if(dw.amountPaid==0 && !dw.applyPenalty){
                    if(dw.currencyCode!=label.Default_Currency){
                        if(cr.Payment_Currency__c==label.Default_Currency){
                            dw.amountPaid = dw.outstandingAmountLocal;
                        }else{
                            dw.amountPaid = dw.outstandingAmountForeign;
                        }
                    }else{
                        dw.amountPaid = dw.outstandingAmountLocal;
                    }
                    
                }
            }else{
                dw.amountPaid = 0;
                dw.applyPenalty = false;
            }
            
            if(dw.selectRecord && dw.amountPaid!=null){
                totalPaidAmount += dw.amountPaid;
                if(dw.currencyCode!=label.Default_Currency){
                    if(cr.Payment_Currency__c==label.Default_Currency){
                        totalPaidAmountLocal += dw.amountPaid;
                        totalPaidAmountForeign += dw.amountPaid/dw.exchangeRate;
                    }else{
                        totalPaidAmountForeign += dw.amountPaid;
                        totalPaidAmountLocal += dw.amountPaid*dw.exchangeRate;
                    }
                }else{
                    totalPaidAmountLocal += dw.amountPaid;
                }
                
            }
            if(dw.selectRecord && dw.applyPenalty && dw.penaltyAmount>0){
                if(dw.currencyCode!=label.Default_Currency){
                    if(cr.Payment_Currency__c==label.Default_Currency){
                        totalPenaltyAmountLocal += dw.penaltyAmountLocal;
                        totalPenaltyAmountForeign += dw.penaltyAmountForeign;
                        dw.penaltyAmount = dw.penaltyAmountLocal;
                    }else{
                        totalPenaltyAmountForeign += dw.penaltyAmountForeign;
                        totalPenaltyAmountLocal += dw.penaltyAmountLocal;
                    }
                }else{
                    totalPenaltyAmountLocal += dw.penaltyAmountLocal;
                }
                totalPenaltyAmount += dw.penaltyAmount;
            }
        }
        totalPenaltyAmount = totalPenaltyAmount.setScale(2);
        totalPenaltyAmountLocal = totalPenaltyAmountLocal.setScale(2);
        totalPenaltyAmountForeign = totalPenaltyAmountForeign.setScale(2);
        
        
        if(currencyCode!=label.Default_Currency){
            if(cr.Payment_Currency__c==label.Default_Currency){
                unAppliedAmount = totalPayment - totalPaidAmountLocal - totalPenaltyAmountLocal;
            }else{
                unAppliedAmount = totalPayment - totalPaidAmountForeign - totalPenaltyAmountForeign;
            }
        }else{
            unAppliedAmount = totalPayment - totalPaidAmountLocal - totalPenaltyAmountLocal;
        }
        
        if(curOffLimit.Id!=null){
            if(unAppliedAmount<0){
                if(-unAppliedAmount <= Integer.valueOf(curOffLimit.Lower_Limit__c)){
                    variance = unAppliedAmount;
                }
            }else if(unAppliedAmount>0){
                if(unAppliedAmount <= Integer.valueOf(curOffLimit.Upper_Limit__c)){
                    variance = unAppliedAmount;
                }
            }
        }
        
    }
    
    //Added by rajesh ---------- 18th March 2017
    public pageReference generateAccountStmtPdf(){
        //list<Account> acLst = [Select id,Name from Account where id =: con.AccountId];
        if(rroll.Property__c != null){
            Blob body;
            PageReference pdf = new PageReference('/apex/AccountStatementPDF?pId='+rroll.Property__c+'&tId='+con.AccountId);
            if(Test.isRunningTest()){
                body = blob.valueOf('Test');
            }else{
                body = pdf.getContentAsPDF();
            }
            
            
            DateTime d = datetime.now();
            timeStr = d.format('yyyyMMdd-hh:mm');
            String pdfName = propList [0].Short_Code__c+ '-' + 'SOA' + '-'+ timeStr ;//YYYYMMDD-HHMM
            
            Attachment attach = new Attachment();
            attach.Body = body;
            attach.name= pdfName+'.PDF';
            attach.ParentId = con.AccountId;
            insert attach;
            return new pageReference('/servlet/servlet.FileDownload?file='+attach.Id);
            
            //return new pageReference('/apex/AccountStatementPDF?pId='+rroll.Property__c+'&tId='+con.AccountId);
        }
        return null;
    }
    
    public class DisplayWrapper{
        public Boolean selectRecord{get;set;}
        public string invDepNo{get;set;}
        public Id invoiceId{get;set;}
        public Id depositId{get;set;}
        public Id paymentVoucherId{get;set;}
        public string propertyId{get;set;}
        public string tenantId{get;set;}
        public decimal totalAmount{get;set;}
        public decimal totalAmountLocal{get;set;}
        public decimal totalAmountForeign{get;set;}
        public decimal outstandingAmount{get;set;}
        public decimal outstandingAmountLocal{get;set;}
        public decimal outstandingAmountForeign{get;set;}
        public decimal amountPaid{get;set;}
        public string remarks{get;set;}
        public Integer dueDays{get;set;}
        public decimal penaltyAmount{get;set;}
        public decimal penaltyAmountLocal{get;set;}
        public decimal penaltyAmountForeign{get;set;}
        public Boolean applyPenalty{get;set;}
        public date paymentDueDate{get;set;}
        public decimal latePaymentInterest{get;set;}
        public string billingType{get;set;}
        public string currencyCode{get;set;}
        public decimal exchangeRate{get;set;}
        
        public DisplayWrapper(){
            selectRecord = false;
            applyPenalty = false;
            exchangeRate = 0;
        }
        
    }
}