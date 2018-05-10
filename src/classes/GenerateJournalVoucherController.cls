/*
    Name    :   GenerateJournalVoucherController
    Author  :   Arshad
    Date    :   14th March 2017
    Description : This controller is used for generate Journal vochers or Journal entries for the Invoices
    Test Class - GenerateJournalVoucherControllerTest
*/
public class GenerateJournalVoucherController {
    //Public variables  
    public Rent_Roll__c rentRoll {get;set;}
    public list < InvoiceModel > invModList {get;set;}
    public integer month {get;set;}
    public integer year {get;set;}
    public string sltdCurrCodeInv {get;set;}
    public string sltdCurrCodeCR {get;set;}
    public string sltdCurrCodeDep {get;set;}
    public string sltdCurrCodePV {get;set;}
    
    public string sltdAction {get;set;}
    
    //Variables for Dep
    public list < DepositModel > depModList {get;set;}
    public Lease__c leaseObj{get;set;}
    public Deposit__c depObj{get;set;}
    public integer monthDep {get;set;}
    public integer yearDep {get;set;}
    
    //Variables for Dep
    public list < PVModel > pvModList {get;set;}
    public Lease__c leasePVObj{get;set;}
    public Payment_Voucher__c pvObj{get;set;}
    public integer monthPV {get;set;}
    public integer yearPV {get;set;}
    
    //Variables for CR
    public Cash_Receipt__c crObj {get;set;}
    public list < CaseRecptModel > crModList {get;set;}
    public integer monthCR {get;set;}
    public integer yearCR {get;set;}
    Map<Integer,String> MonthMap;

    private property__c proInv;
    private property__c proCR;
    private property__c proDep;
    private property__c proPV;
    //Default constructor 
    
    public string selectedFPInv{get;set;}
    public List<Selectoption> fiscalPeriodInv{get;set;}
    public string selectedFPCR{get;set;}
    public List<Selectoption> fiscalPeriodCR{get;set;}
    public string selectedFPDep{get;set;}
    public List<Selectoption> fiscalPeriodDep{get;set;}
    public string selectedFPPV{get;set;}
    public List<Selectoption> fiscalPeriodPV{get;set;}
    
    public GenerateJournalVoucherController() {
        month = system.today().month();
        year = system.today().year();
        monthCR = month;
        yearCR = year;
        monthDep = month;
        yearDep = year;
        monthPV = month;
        yearPV = year;
        
        sltdCurrCodeInv = label.Default_Currency;
        sltdCurrCodeCR = label.Default_Currency;
        sltdCurrCodeDep = label.Default_Currency;
        sltdCurrCodePV = label.Default_Currency;
        sltdAction = 'Invoice';
        
        init();
    }

    private void init() {
        rentRoll = new Rent_Roll__c();
        proInv = new Property__c();
        proDep = new Property__c();
        proCR = new Property__c();
        proPV = new Property__c();
        invModList = new list < InvoiceModel > ();

        crObj = new Cash_Receipt__c();
        crModList = new list < CaseRecptModel > ();
        
        depObj     = new Deposit__c();
        leaseObj   = new Lease__c();
        depModList = new list < DepositModel > ();
        
        pvModList = new List<PVModel>();
        leasePVObj = new Lease__c();
        pvObj = new Payment_Voucher__c();
    
        MonthMap = new Map<Integer,String>();
        MonthMap.put(1, 'January');
        MonthMap.put(2, 'February');
        MonthMap.put(3, 'March');
        MonthMap.put(4, 'April');
        MonthMap.put(5, 'May');
        MonthMap.put(6, 'June');
        MonthMap.put(7, 'July');
        MonthMap.put(8, 'August');
        MonthMap.put(9, 'September');
        MonthMap.put(10, 'October');
        MonthMap.put(11, 'November');
        MonthMap.put(12, 'December');
        
        fiscalPeriodInv = new List<Selectoption>();
        fiscalPeriodCR = new List<Selectoption>();
        fiscalPeriodDep = new List<Selectoption>();
        fiscalPeriodPV = new List<Selectoption>();
    }


    public void reloadPg() {
        invModList = new list < InvoiceModel > ();
        crModList  = new list < CaseRecptModel > ();
        depModList = new list < DepositModel > ();
        pvModList = new list<PVModel>();
    }

    //This getter method is used to populate year picklist on vf page
    public list < selectOption > getYearList() {
        list < selectOption > tempList = new list < selectOption > ();
        integer currentyear = system.today().year();
        for (integer i = currentYear - 1; i <= currentYear + 4; i++) {
            tempList.add(new selectOption('' + i, '' + i));
        }
        return tempList;
    }

    //This getter method is used to get Billing types fields values on vf page from the Rent Roll object
    public list < selectOption > getBillingTypes() {
        list < selectOption > tempList = new list < selectOption > ();
        Schema.DescribeFieldResult fieldResult = Rent_Roll__c.Billing_Type__c.getDescribe();
        list < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        tempList.add(new SelectOption('', 'All'));
        for (Schema.PicklistEntry f: ple) {
            tempList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return tempList;
    }

    //This getter method is used to populate month picklist values on vf page
    public list < selectOption > getMonthList() {
        list < selectOption > tempList = new list < selectOption > ();
        tempList.add(new selectOption('1', 'January'));
        tempList.add(new selectOption('2', 'February'));
        tempList.add(new selectOption('3', 'March'));
        tempList.add(new selectOption('4', 'April'));
        tempList.add(new selectOption('5', 'May'));
        tempList.add(new selectOption('6', 'June'));
        tempList.add(new selectOption('7', 'July'));
        tempList.add(new selectOption('8', 'August'));
        tempList.add(new selectOption('9', 'September'));
        tempList.add(new selectOption('10', 'October'));
        tempList.add(new selectOption('11', 'November'));
        tempList.add(new selectOption('12', 'December'));
        return tempList;
    }
    
    public list < selectOption > getPVRefundModeList() {
        list < selectOption > tempList = new list < selectOption > ();
        tempList.add(new selectOption('Cash', 'Cash'));
        tempList.add(new selectOption('Cheque', 'Cheque'));
        return tempList;
    }

    public void searchData() {
        reloadPg();
        if (sltdAction == 'Invoice') {
            searchInvoices();
        } else {
            searchCashReceipt();
        }
    } 
    
    public List<Selectoption> getFiscalPeriods(Id cmpny, Integer yr){
        List<Selectoption> lstnamesel = new List<selectoption>();
        lstnamesel.add(new selectOption('', '- None -'));
        System.debug('inside loop==>'+cmpny +'  '+ yr);  
        for(Fiscal_Period__c fpp :[SELECT Id, Month_Text__c,Fiscal_Year__r.Company__c, Month__c, Year__c
                FROM Fiscal_Period__c
                WHERE Fiscal_Year__r.Company__c =: cmpny AND Year__c =: yr And Allow_Posting__c != 'No' Order by Month__c Asc
            ]){
        lstnamesel.add(new selectoption(fpp.id,fpp.Month_Text__c+' '+ fpp.Year__c));
        }
        return lstnamesel; 
    }
    //This method is used to search invocies based on the property or Tenant 
    public void searchInvoices() {
        reloadPg();
        if (String.isBlank(rentRoll.Property__c)) {
            rentRoll.Property__c.addError('Please select Property');
            return;
        }

        Date startDate = Date.newInstance(year, month, 1);
        Date endDate = Date.newInstance(year, month, Date.daysInMonth(year, Month));

        //Creating Dynamic soql query
        String qry = 'SELECT Id,Name,Billing_Type__c,Tenant_Name__c,JV_Status__c,Tenant_Name__r.Name,Amount__c,Currency_Code__c,Invoice_Date__c,Total_Amount__c,Total_Amount_Local__c,Tenant__c,Account__c,JV_Type__c ';
        qry += ' FROM Invoice__c ';
        qry += ' WHERE Rent_Roll__r.Property__c = \'' + rentRoll.Property__c + '\' AND (JV_Status__c = null OR JV_Status__c = \'Pending\')';
        qry += ' AND (Invoice_Date__c >=: startDate AND Invoice_Date__c <=: endDate AND Total_amount__c != null) ';

        if (String.isNotBlank(rentRoll.Billing_Type__c))
            qry += ' AND Billing_Type__c = \'' + rentRoll.Billing_Type__c + '\'';

        if (String.isNotBlank(sltdCurrCodeInv))
            qry += ' AND Currency_Code__c = \'' + sltdCurrCodeInv + '\'';


        qry += ' ORDER BY Billing_Type__c';

        for (Invoice__c inv: Database.query(qry)) {
            invModList.add(new InvoiceModel(false, inv));
        }

        //Fetching property
        proInv = [SELECT Id, Short_Code__c, Landlord__c, Journal_Voucher_Index__c, Journal_Entry_Index__c, Journal_Batch_Index__c FROM Property__c WHERE Id =: rentRoll.Property__c LIMIT 1];

        if (invModList.size() == 0)
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Invoices not found.'));
            //map < String, Id > fiscalYearMap = getFiscalPrd(compnySet, postedMonthSet, postedYearSet);
       fiscalPeriodInv = getFiscalPeriods(proInv.Landlord__c,year);
            
    }

    //This method is used to generate Journal vochers or Entries for the selected invoices
    public PageReference generateJournalVoucher() {
        SavePoint sp = Database.setSavePoint();
        
        if(selectedFPInv == null){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please select Fiscal Posting month.'));
            return null;
        }
        Boolean isCheked = false;
        list < Invoice__c > selInvLst = new list < Invoice__c > ();
        //Filtering selected invoices
        for (InvoiceModel invMod: invModList) {
            if (invMod.isChek) {
                isCheked = true;
                selInvLst.add(invMod.inv);
                if(invMod.inv.JV_Type__c == null){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Data error, please contact admin' ));
                    return null;
                }
            }
        }
        if (!isCheked) {
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please check atleast 1 Invoice.'));
            return null;
        }

        if (selInvLst.size() > 0) {
            list < Invoice__c > invUpdList = new list < Invoice__c > ();
            map < Id, Invoice__c > invLineItemMap = new map < Id, Invoice__c > ([SELECT Id, Invoice_Date__c, Total_Amount__c, Description__c, Account_Id__c, JV_Type__c, Currency_Code__c, Total_Amount_Local__c,
                (SELECT Id, Name, Lease_Charge__r.Charge_Type__c, Comm_Tax_Amount__c, Comm_Tax_Amount_Local__c, Comm_Tax_Amount_Foreign__c, Amount__c, Amount_Local__c, Amount_Foreign__c,
                    Total_Amount__c, Total_Amount_Local__c, Total_Amount_Foreign__c, End_Date__c, Currency_Code__c FROM Invoice_Line_Items__r WHERE Lease_Charge__r.Charge_Type__c != null AND Amount__c != null)
                FROM Invoice__c WHERE Id IN: selInvLst
            ]);

            Set < String > compnySet = new Set < String > ();
            Set < String > chargeTypeSet = new Set < String > ();
            Set < String > JVTypeSet = new Set < String > ();
            list < Journal_Voucher__c > insertJrvLst = new list < Journal_Voucher__c > ();

            //Set current month and year
            Integer currentMonth = system.today().month();
            Integer currentYear = system.today().Year();

            for (Id invId: invLineItemMap.keySet()) {
                Invoice__c inv = invLineItemMap.get(invId);
                inv.JV_Status__c = 'Generated';
                invUpdList.add(inv);

                Integer jrVIndex = 0;
                if (proInv.Journal_Voucher_Index__c != null)
                    jrVIndex = Integer.valueOf('' + proInv.Journal_Voucher_Index__c);

                jrVIndex = jrVIndex + 1;
                proInv.Journal_Voucher_Index__c = jrVIndex;

                string indxVal = addZeroIndex(jrVIndex);

                String name = proInv.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                Journal_Voucher__c jrnlVou = fillJRvoucher(inv, name);
                insertJrvLst.add(jrnlVou);

                for (Invoice_Line_Item__c invLnItm: inv.Invoice_Line_Items__r) {
                    chargeTypeSet.add(invLnItm.Lease_Charge__r.Charge_Type__c);

                    //Adding Journal vouchers with Invoice line items for the Advance Rental
                    if (invLnItm.Lease_Charge__r.Charge_Type__c == 'Advance Rental') {
                        jrVIndex = 0;
                        if (proInv.Journal_Voucher_Index__c != null)
                            jrVIndex = Integer.valueOf('' + proInv.Journal_Voucher_Index__c);

                        jrVIndex = jrVIndex + 1;
                        proInv.Journal_Voucher_Index__c = jrVIndex;

                        indxVal = addZeroIndex(jrVIndex);

                        name = proInv.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                        Journal_Voucher__c jrnlVouNew = fillJRvoucher(inv, name);
                        jrnlVouNew.Invoice_Line_Item__c = invLnItm.Id;
                        jrnlVouNew.Posting_Date__c = invLnItm.End_Date__c;
                        //jrnlVouNew.Amount__c = invLnItm.Total_Amount_Local__c;
                        jrnlVouNew.Amount__c = invLnItm.Amount_Local__c;
                        insertJrvLst.add(jrnlVouNew);
                    }
                }

                if (inv.Account_Id__c != null)
                    compnySet.add(inv.Account_Id__c);

                if (inv.JV_Type__c != null)
                    JVTypeSet.add(inv.JV_Type__c);
            }

            if (insertJrvLst.size() > 0) {
                // Start process for insert Journal Batch -----------------------------------------
                Integer jBIndex = 0;
                if (proInv.Journal_Batch_Index__c != null)
                    jBIndex = Integer.valueOf('' + proInv.Journal_Batch_Index__c);

                jBIndex = jBIndex + 1;
                proInv.Journal_Batch_Index__c = jBIndex;

                string indxVal = addZeroIndex(jBIndex);

                String name = proInv.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                Journal_Batch__c jrBatch = new Journal_Batch__c(Property__c = proInv.Id);
                jrBatch.name = name;
                
                jrBatch.Billing_Type__c = rentRoll.Billing_Type__c;
                jrBatch.Currency_Code__c = sltdCurrCodeInv;
                //jrBatch.JV_Type__c = ;
                jrBatch.Month__c = MonthMap.get(month);
                //jrBatch.Payment_Mode__c = ;
                jrBatch.Transaction__c = 'Invoice';
                jrBatch.Year__c = year;
                                
                insert jrBatch;
                // End process for insert Journal Batch -----------------------------------------

                //--------- Start Filtering Posting Month and Year ----------------------------------
                Set < Integer > postedMonthSet = new Set < Integer > ();
                Set < Integer > postedYearSet = new Set < Integer > ();
                for (Journal_Voucher__c jrVoucher: insertJrvLst) {
                    if (jrVoucher.Posting_Date__c != null) {
                        postedMonthSet.add(jrVoucher.Posting_Date__c.month());
                        postedYearSet.add(jrVoucher.Posting_Date__c.year());
                    }
                }
                //--------- End Filtering Posting Month and Year ----------------------------------
 
                //Getting FiscalPeriod in journal vouchers
                if (compnySet.size() > 0 && postedMonthSet.size() > 0) {
                    map < String, Id > fiscalYearMap = getFiscalPrd(compnySet, postedMonthSet, postedYearSet);
                    for (Journal_Voucher__c jrVoucher: insertJrvLst) {
                        jrVoucher.Journal_Batch__c = jrBatch.Id;
                        if (jrVoucher.Posting_Date__c != null) {
                            String mapKeyFP = jrVoucher.Company__c + '#' + jrVoucher.Posting_Date__c.month() + '#' + jrVoucher.Posting_Date__c.year();

                            if (fiscalYearMap.containsKey(mapKeyFP)) {
                                jrVoucher.Fiscal_Period__c = fiscalYearMap.get(mapKeyFP);
                            }else{
                                jrVoucher.Fiscal_Period__c = selectedFPInv; 
                            }
                        }
                    }
                }

                insert insertJrvLst;

                //-------------- Start, Filter Inserted journal voucher For the advance rental, Invoice line items 
                map < Id, Journal_Voucher__c > insertedJrnlVocAdvanRenMap = new map < Id, Journal_Voucher__c > ();
                list < Journal_Voucher__c > templst = insertJrvLst;
                insertJrvLst = new list < Journal_Voucher__c > ();
                for (integer i = 0; i < templst.size(); i++) {
                    Journal_Voucher__c jrvTemp = templst.get(i);

                    if (jrvTemp.Invoice_Line_Item__c != null) {
                        insertedJrnlVocAdvanRenMap.put(jrvTemp.Invoice_Line_Item__c, jrvTemp);
                    } else {
                        insertJrvLst.add(jrvTemp);
                    }
                }
                templst = new list < Journal_Voucher__c > ();
                //-------------- End, Filter Inserted journal voucher For the advance rental, Invoice line items

                if (compnySet.size() > 0 && chargeTypeSet.size() > 0 && JVTypeSet.size() > 0) {
                    list < Journal_Entry__c > jrEntryLst = new list < Journal_Entry__c > ();
                    map < String, Id > coaBalanceMap = new map < String, Id > ();
                    map < String, JE_Logic__c > fetchJELogic = getJeLogic('Invoice', compnySet, chargeTypeSet, JVTypeSet);

                    //------------------------- Start process for get Coa_Balance ----------------------------- 
                    if (postedMonthSet.size() > 0) {
                        Set < String > coeMasterId = new Set < String > ();
                        for (JE_Logic__c jeLogic: fetchJELogic.values()) {
                            for (JE_Configuration__c jeConfig: jeLogic.JE_Configurations__r) {
                                if (jeConfig.COA_Master__c != null)
                                    coeMasterId.add(jeConfig.COA_Master__c);
                            }
                        }
                        if (coeMasterId.size() > 0) {
                            coaBalanceMap = getCoaBalance(compnySet, coeMasterId, postedMonthSet, postedYearSet);
                        }
                    }
                    //------------------------- End process for fetching Coa_Balance -----------------------------
                    for (Journal_Voucher__c jrVoucher: insertJrvLst) {
                        Invoice__c inv = invLineItemMap.get(jrVoucher.Invoice__c);
                        map < String, Decimal > summConfigMap = new map < String, Decimal > ();
                        
                        map < String, Decimal > summConfigAdvanceRentalMap = new map < String, Decimal > ();
                        map < String, String > summConfigCurrencyMap = new map < String, String > ();

                        for (Invoice_Line_Item__c invLnItm: inv.Invoice_Line_Items__r) {
                            String mapKey = jrVoucher.Company__c + '#' + 'Invoice' + '#' + invLnItm.Lease_Charge__r.Charge_Type__c + '#' + inv.JV_Type__c;
                            JE_Logic__c jeLogic = fetchJELogic.get(mapKey);

                            //string currCode =  invLnItm.Currency_Code__c != null ? invLnItm.Currency_Code__c : label.Default_Currency;

                            if (invLnItm.Currency_Code__c == label.Base_Foreign_Currency) {
                                if (fetchJELogic.containsKey(mapKey + '#' + label.Base_Foreign_Currency)) {
                                    jeLogic = fetchJELogic.get(mapKey + '#' + invLnItm.Currency_Code__c);
                                } else if (fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                                    jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                                }
                            } else if (invLnItm.Currency_Code__c == label.Default_Currency && fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                            }

                            if (jeLogic != null) {

                                for (JE_Configuration__c jeConfig: jeLogic.JE_Configurations__r) {
                                    //get amount on the bases of transaction type
                                    Decimal tempAmt = invLnItm.Amount_Local__c;
                                    if (jeConfig.COA_Master_CC__c == label.Base_Foreign_Currency)
                                        tempAmt = invLnItm.Amount_Foreign__c;

                                    if (jeConfig.Journal_Amount__c == 'Tax Amount') {
                                        tempAmt = invLnItm.Comm_Tax_Amount_Local__c;

                                        if (jeConfig.COA_Master_CC__c == label.Base_Foreign_Currency)
                                            tempAmt = invLnItm.Comm_Tax_Amount_Foreign__c;
                                    }

                                    if (jeConfig.Summarization__c.equalsIgnoreCase('Y')) {
                                        String summMap = jeConfig.COA_Master__c + '#' + jeConfig.Transaction_Type__c;
                                        Decimal tempSummAmt = tempAmt;

                                        tempSummAmt = jeLogic.Convert_Negative_Amount__c ? math.abs(tempSummAmt) : tempSummAmt;

                                        //Summarization for 'Advance rental' related with Jv Run equals to 'Run' 
                                        if (insertedJrnlVocAdvanRenMap.containsKey(invLnItm.Id) && jeConfig.JV_Run__c == 'Run 2') {
                                            summMap = insertedJrnlVocAdvanRenMap.get(invLnItm.Id).Id + '#' + summMap;

                                            if (summConfigAdvanceRentalMap.containsKey(summMap))
                                                tempSummAmt = tempSummAmt + summConfigAdvanceRentalMap.get(summMap);

                                            summConfigAdvanceRentalMap.put(summMap, tempSummAmt);
                                        } else {
                                            if (summConfigMap.containsKey(summMap))
                                                tempSummAmt = tempSummAmt + summConfigMap.get(summMap);

                                            summConfigMap.put(summMap, tempSummAmt);
                                        }

                                        summConfigCurrencyMap.put(summMap, jeConfig.COA_Master_CC__c);
                                    } else {
                                        Integer jrEntryIndex = 0;
                                        if (proInv.Journal_Entry_Index__c != null)
                                            jrEntryIndex = Integer.valueOf('' + proInv.Journal_Entry_Index__c);

                                        jrEntryIndex = jrEntryIndex + 1;
                                        proInv.Journal_Entry_Index__c = jrEntryIndex;

                                        indxVal = addZeroIndex(jrEntryIndex);
                                        name = proInv.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                        Journal_Entry__c jEntry = new Journal_Entry__c();
                                        jEntry.Name = name;
                                        jEntry.Posting_Status__c = 'Unposted';
                                        jEntry.Journal_Voucher__c = jrVoucher.Id;
                                        jEntry.Doc_Ref__c = invLnItm.Id;
                                        jEntry.Currency_Code__c = jeConfig.COA_Master_CC__c;
                                        jEntry.JE_Logic__c = jeLogic.Id;
                                        jEntry.JE_Configuration__c = jeConfig.Id;

                                        //Filling COA Balance                                        
                                        /*
                                        if(jrVoucher.Posting_Date__c != null){
                                            String mapKeyCoa = jrVoucher.Company__c + '#' + jeConfig.COA_Master__c +'#'+jrVoucher.Posting_Date__c.month()+'#'+jrVoucher.Posting_Date__c.Year();
                                            if(coaBalanceMap.containsKey(mapKeyCoa)){
                                                jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                            }
                                        }*/
                                        Date pstDate;
                                        if (insertedJrnlVocAdvanRenMap.containsKey(invLnItm.Id) && jeConfig.JV_Run__c == 'Run 2')
                                            pstDate = insertedJrnlVocAdvanRenMap.get(invLnItm.Id).Posting_Date__c;
                                        else
                                            pstDate = jrVoucher.Posting_Date__c;

                                        if (pstDate != null) {
                                            String mapKeyCoa = jrVoucher.Company__c + '#' + jeConfig.COA_Master__c + '#' + pstDate.month() + '#' + pstDate.Year();
                                            if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                                jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                            }
                                        }


                                        tempAmt = jeLogic.Convert_Negative_Amount__c ? math.abs(tempAmt) : tempAmt;
                                       /* if (jeConfig.Transaction_Type__c == 'Dr') {
                                            jEntry.Dr_Amount__c = tempAmt;
                                        } else if (jeConfig.Transaction_Type__c == 'Cr') {
                                            jEntry.Cr_Amount__c = tempAmt;
                                        }*/
                                        if ((jeConfig.Transaction_Type__c == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                            jEntry.Dr_Amount__c = tempAmt;
                                        } else if ((jeConfig.Transaction_Type__c == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                            jEntry.Cr_Amount__c = tempAmt;
                                        }

                                        //Journal Entry for the 'Advance Rental' Rent
                                        if (insertedJrnlVocAdvanRenMap.containsKey(invLnItm.Id) && jeConfig.JV_Run__c == 'Run 2') {
                                            jEntry.Journal_Voucher__c = insertedJrnlVocAdvanRenMap.get(invLnItm.Id).Id;
                                        }

                                        jrEntryLst.add(jEntry);
                                    }
                                }
                            }else{
                                Database.rollback(sp);
                                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                                return null;
                            }
                        

                        //-------------------- Start work for the Summarization ----------------------------------                       
                        for (String summKey: summConfigMap.keySet()) {
                            list < String > strLst = summKey.split('#');
                            if (strLst.size() == 2) {
                                String coaMasterId = strLst.get(0);
                                String transType = strLst.get(1);
                                Decimal tempAmt = summConfigMap.get(summKey);
                                String currCode = summConfigCurrencyMap.get(summKey);

                                Integer jrEntryIndex = 0;
                                if (proInv.Journal_Entry_Index__c != null)
                                    jrEntryIndex = Integer.valueOf('' + proInv.Journal_Entry_Index__c);

                                jrEntryIndex = jrEntryIndex + 1;
                                proInv.Journal_Entry_Index__c = jrEntryIndex;

                                indxVal = addZeroIndex(jrEntryIndex);
                                name = proInv.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                Journal_Entry__c jEntry = new Journal_Entry__c();
                                jEntry.Name = name;
                                jEntry.Currency_code__c = currCode;
                                jEntry.Posting_Status__c = 'Unposted';
                                jEntry.Journal_Voucher__c = jrVoucher.Id;

                                if (jrVoucher.Posting_Date__c != null) {
                                    String mapKeyCoa = jrVoucher.Company__c + '#' + coaMasterId + '#' + jrVoucher.Posting_Date__c.month() + '#' + jrVoucher.Posting_Date__c.Year();
                                    if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                        jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                    }
                                }

                                /*if (transType == 'Dr') {
                                    jEntry.Dr_Amount__c = tempAmt;
                                } else if (transType == 'Cr') {
                                    jEntry.Cr_Amount__c = tempAmt;
                                }*/
                                if ((transType == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                    jEntry.Dr_Amount__c = tempAmt;
                                } else if ((transType == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                    jEntry.Cr_Amount__c = tempAmt;
                                }
                                
                                jrEntryLst.add(jEntry);
                            }
                        }
                        //-------------------- End work for the Summarization ----------------------------------

                        //-------------------- Start work for the Summarization Advamce Rental process ----------------------------------
                        for (String summKey: summConfigAdvanceRentalMap.keySet()) {
                            list < String > strLst = summKey.split('#');
                            if (strLst.size() == 3) {
                                String jrnlVovId = strLst.get(0);
                                String coaMasterId = strLst.get(1);
                                String transType = strLst.get(2);
                                Decimal tempAmt = summConfigAdvanceRentalMap.get(summKey);
                                String currCode = summConfigCurrencyMap.get(summKey);

                                Integer jrEntryIndex = 0;
                                if (proInv.Journal_Entry_Index__c != null)
                                    jrEntryIndex = Integer.valueOf('' + proInv.Journal_Entry_Index__c);

                                jrEntryIndex = jrEntryIndex + 1;
                                proInv.Journal_Entry_Index__c = jrEntryIndex;

                                indxVal = addZeroIndex(jrEntryIndex);
                                name = proInv.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                Journal_Entry__c jEntry = new Journal_Entry__c();
                                jEntry.Name = name;
                                jEntry.Posting_Status__c = 'Unposted';
                                jEntry.Journal_Voucher__c = jrnlVovId;
                                jEntry.Currency_code__c = currCode;
                                if (jrVoucher.Posting_Date__c != null) {
                                    String mapKeyCoa = jrVoucher.Company__c + '#' + coaMasterId + '#' + jrVoucher.Posting_Date__c.month() + '#' + jrVoucher.Posting_Date__c.Year();
                                    if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                        jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                    }
                                }

                                /*if (transType == 'Dr') {
                                    jEntry.Dr_Amount__c = tempAmt;
                                } else if (transType == 'Cr') {
                                    jEntry.Cr_Amount__c = tempAmt;
                                }*/
                                if ((transType == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                    jEntry.Dr_Amount__c = tempAmt;
                                } else if ((transType == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                    jEntry.Cr_Amount__c = tempAmt;
                                }

                                jrEntryLst.add(jEntry);
                            }
                        }
                    }
                        //-------------------- End work for the Summarization Advamce Rental process ----------------------------------
                    }
                    
                                        
                    
                    if (invUpdList.size() > 0)
                        //update invUpdList;

                    //Insert Journal Entries
                    insert jrEntryLst;

                    update proInv;

                    return new PageReference('/' + jrBatch.Id);
                }else{
                    Database.rollback(sp);
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Data error, please contact admin' ));
                    return null;
                }
            }
        }

        return null;
    }

    //This methos is used to fill Journal vochers
    private Journal_Voucher__c fillJRvoucher(Invoice__c inv, String name) {
        Journal_Voucher__c jrV = new Journal_Voucher__c();

        jrV.Name = name;
        jrV.Invoice__c = inv.Id;
        jrV.Amount__c = inv.Total_Amount_Local__c;
        jrv.Currency_Code__c = label.Default_Currency; //inv.Currency_Code__c;
        jrV.Company__c = inv.Account_Id__c;
        jrV.Document_Description__c = inv.Description__c;
        jrv.Posting_Date__c = inv.Invoice_Date__c;
        jrV.Posting_Status__c = 'Unposted';
        return jrV;
    }

    //This methos is used to get jelogic for the invoice process
    private map < String, JE_Logic__c > getJeLogic(String transType, Set < String > compnySet, Set < String > chargeTypeSet, Set < String > JVTypeSet) {
        map < String, JE_Logic__c > fetchJELogicMap = new map < String, JE_Logic__c > ();
        //String transType = 'Invoice';

        for (JE_Logic__c je: [SELECT Id, Company__c, Transaction__c, Charge_Type__c,JV_Type__c, Document_Currency__c,Convert_Negative_Amount__c,
                (SELECT Id, COA_Master__c, Journal_Amount__c, Summarization__c, Transaction_Type__c, JV_Run__c, COA_Master_CC__c FROM JE_Configurations__r WHERE Summarization__c != null)
                FROM JE_Logic__c
                WHERE Company__c IN: compnySet AND Charge_Type__c IN: chargeTypeSet AND Transaction__c =: transType AND JV_Type__c IN: JVTypeSet
            ]) {

            String mapKey = je.Company__c + '#' + je.Transaction__c + '#' + je.Charge_Type__c + '#' + je.JV_Type__c;

            if (String.isNotBlank(je.Document_Currency__c))
                mapKey = mapKey + '#' + je.Document_Currency__c;

            fetchJELogicMap.put(mapKey, je);
        }

        return fetchJELogicMap;
    }

    //This methos is used to get Coa Balance
    private map < String, Id > getCoaBalance(Set < String > compnySet, Set < String > coaMasterSet, Set < Integer > monthSet, Set < Integer > yearSet) {
        map < String, Id > coaMasterMap = new map < String, Id > ();

        for (COA_Balance__c coBal: [SELECT Id, Company__c, Fiscal_Period__c, COA_Master__c, Fiscal_Period__r.Month__c, Fiscal_Period__r.Year__c
                FROM COA_Balance__c
                WHERE Company__c IN: compnySet AND COA_Master__c IN: coaMasterSet AND Fiscal_Period__r.Month__c IN: monthSet AND Fiscal_Period__r.Year__c IN: yearSet
            ]) {

            String mapKey = coBal.Company__c + '#' + coBal.COA_Master__c + '#' + coBal.Fiscal_Period__r.Month__c + '#' + coBal.Fiscal_Period__r.Year__c;
            coaMasterMap.put(mapKey, coBal.Id);
        }

        return coaMasterMap;
    }

    //Fetch Fisical year for the Journal voucher
    private map < String, Id > getFiscalPrd(Set < String > compnySet, Set < Integer > monthSet, Set < Integer > yearSet) {
        map < String, Id > fisicalYearMap = new map < String, Id > ();

        for (Fiscal_Period__c fisPrd: [SELECT Id,Allow_Posting__c, Fiscal_Year__r.Company__c, Month__c, Year__c
                FROM Fiscal_Period__c
                WHERE Fiscal_Year__r.Company__c IN: compnySet AND Month__c IN: monthSet AND Year__c IN: yearSet
            ]) {
            String mapKey = fisPrd.Fiscal_Year__r.Company__c + '#' + fisPrd.Month__c + '#' + fisPrd.Year__c;
            mapKey += (fisPrd.Allow_Posting__c == 'No')?'#' + fisPrd.Allow_Posting__c:'';
            fisicalYearMap.put(mapKey, fisPrd.Id);
        }

        return fisicalYearMap;
    }

    //This is used to create name with property short name for the Journal voucher,entry
    private string addZeroIndex(Integer indexVal) {
        Integer indexSize = string.valueOf(indexVal).length();
        String zeroVal = '';
        for (integer i = 1; i <= 6 - indexSize; i++) {
            zeroVal += '0';
        }
        return zeroVal + indexVal;
    }

    //This method is used to get currency_code picklist field value of invoice object
    public List < SelectOption > getCurrencyCode() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', 'All'));

        Schema.DescribeFieldResult fieldResult = Invoice__c.Currency_Code__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple)
            options.add(new SelectOption(f.getLabel(), f.getValue()));

        return options;
    }


    //Module class for the selection of Invoices
    public class InvoiceModel {
        public Boolean isChek {get;set;}
        public Invoice__c inv {get;set;}

        public InvoiceModel(Boolean isChek, Invoice__c inv) {
            this.isChek = isChek;
            this.inv = inv;
        }
    }
    
    //-------------- Start process for the Deposit  ------------------------------------------------------->
    //This method is used to search Deposit based on the property or other filters 
    //Module class for the selection of Invoices
    public class PVModel {
        public Boolean isChek {get;set;}
        public Payment_Voucher__c pv {get;set;}

        public PVModel(Boolean isChek, Payment_Voucher__c pv) {
            this.isChek = isChek;
            this.pv = pv;
        }
    }
    public void searchPV() {
        reloadPg();
        if (String.isBlank(leasePVObj.Property__c)) {
            leasePVObj.Property__c.addError('Please select Property');
            return;
        }
        Date startDate = Date.newInstance(yearPV, monthPV, 1);
        Date endDate = Date.newInstance(yearPV, monthPV, Date.daysInMonth(yearPV, monthPV));
        
        //Creating Dynamic soql query
        String qry = 'SELECT Id,Name,Lease__c,Lease__r.Property__c ,Refund_Mode__c,Lease__r.Property__r.Landlord__c,Transaction_Type__c,Lease__r.Tenant__c,JV_Status__c,Lease__r.Tenant__r.Name, ';
        qry += ' Amount__c,Amount_Foreign__c,Amount_Local__c,Currency_Code__c, CreatedDate, Payment_Mode__c ';
        qry += ' FROM Payment_Voucher__c '; 
        qry += ' WHERE Lease__r.Property__c = \'' + leasePVObj.Property__c + '\' AND (JV_Status__c = null OR JV_Status__c = \'Pending\')';
        qry += ' And CreatedDate >=: startDate AND CreatedDate <=: endDate  AND Transaction_Type__c != null AND Refund_Mode__c != null ';
        
        if (String.isNotBlank(pvObj.Refund_Mode__c))
            qry += ' AND Refund_Mode__c = \'' + pvObj.Refund_Mode__c + '\'';

        if (String.isNotBlank(sltdCurrCodePV))
            qry += ' AND Currency_Code__c = \'' + sltdCurrCodePV + '\'';
        
        if (String.isNotBlank(pvObj.Transaction_Type__c))
            qry += ' AND Transaction_Type__c = \'' + pvObj.Transaction_Type__c + '\'';
            
        for (Payment_Voucher__c pv: Database.query(qry))
            pvModList.add(new PVModel(false, pv));

        //Fetching property
        proPV = [SELECT Id, Short_Code__c,Landlord__c, Journal_Voucher_Index__c, Journal_Entry_Index__c, Journal_Batch_Index__c FROM Property__c WHERE Id =: leasePVObj.Property__c LIMIT 1];

        if (pvModList.size() == 0)
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Payment Voucher not found.'));
        
        fiscalPeriodPV  = getFiscalPeriods(proPV.Landlord__c,yearPV);  
    }
    public PageReference generateJournalVoucherPV(){
        SavePoint sp = Database.setSavePoint();
        if(selectedFPPV == null){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please select Fiscal Posting month.'));
            return null;
        }
        
        list < Payment_Voucher__c > selPVLst = new list < Payment_Voucher__c > ();
        list < Payment_Voucher__c > updatePV = new list < Payment_Voucher__c > ();
        //Filtering selected Deposit__c
        String tempJVError = '';
        
        for (PVModel pv: pvModList) {
            if (pv.isChek){
                selPVLst.add(pv.pv);
                Payment_Voucher__c tempPV = new Payment_Voucher__c();
                tempPV.Id = pv.pv.Id;
                tempPV.JV_Status__c = 'Generated';
                updatePV.add(tempPV);
            }
        }
        System.debug('@@@ selPVLst   '+selPVLst);
        if (selPVLst.size() > 0) {
            Set < String > propertySet = new Set < String > ();
            Set < String > transTypeSet = new Set < String > ();
            Set < String > refundModeSet = new Set < String > ();
            Set < String > compnySet = new Set < String > ();
            Set < Integer > postedMonthSet = new Set < Integer > ();
            Set < Integer > postedYearSet = new Set < Integer > ();
            
            //Set current month and year
            Integer currentMonth = system.today().month();
            Integer currentYear = system.today().Year();
        
            // Start process for insert Journal Batch -----------------------------------------
            Integer jBIndex = 0;
            if (proPV.Journal_Batch_Index__c != null)
                jBIndex = Integer.valueOf('' + proPV.Journal_Batch_Index__c);
        
            jBIndex = jBIndex + 1;
            proPV.Journal_Batch_Index__c = jBIndex;
        
            string indxVal = addZeroIndex(jBIndex);
        
            String name = proPV.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
            Journal_Batch__c jrBatch = new Journal_Batch__c(Property__c = proPV.Id);
            jrBatch.name = name;
            
            //jrBatch.Billing_Type__c = ;
            jrBatch.Currency_Code__c = sltdCurrCodePV;
            //jrBatch.JV_Type__c = depObj.Deposit_Type__c;
            jrBatch.Month__c = MonthMap.get(monthDep);
            jrBatch.Payment_Mode__c = pvObj.Refund_Mode__c;
            jrBatch.Transaction__c = 'Payment Voucher';
            jrBatch.Year__c = yearDep;
            
            insert jrBatch;
            
            System.debug('@@@ jrBatch   '+jrBatch);
            // End process for insert Journal Batch -----------------------------------------
            for (Payment_Voucher__c pv: selPVLst) {
                propertySet.add(pv.Lease__r.Property__c);
                
                
                if (String.isNotBlank(pv.Refund_Mode__c))
                    refundModeSet.add(pv.Refund_Mode__c);
                    
                if (String.isNotBlank(pv.Transaction_Type__c))
                    transTypeSet.add(pv.Transaction_Type__c);
        
                if (String.isNotBlank(pv.Lease__r.Property__r.Landlord__c))
                    compnySet.add(pv.Lease__r.Property__r.Landlord__c);
        
                postedMonthSet.add(pv.CreatedDate.month());
                postedYearSet.add(pv.CreatedDate.year());
            }       
            System.debug(propertySet.size() +' '+ refundModeSet.size() +' '+transTypeSet.size() +' '+compnySet.size() +' '+postedMonthSet.size() +'@@@ inside if   '+jrBatch);
            if (propertySet.size() > 0 && refundModeSet.size() > 0 && transTypeSet.size() > 0 && compnySet.size() > 0 && postedMonthSet.size() > 0) {
                //Fetching je logic
       
                map < String, JE_Logic__c > fetchJELogic = new map < String, JE_Logic__c > ();
                Set < String > coeMasterId = new Set < String > ();
                System.debug('@@@ compnySet   '+compnySet+' transTypeSet '+transTypeSet);
                for (JE_Logic__c je: [SELECT Id, Convert_Negative_Amount__c,Company__c, Transaction__c, Charge_Type__c, JV_Type__c, Document_Currency__c, Bank_Name__r.Property__c, Payment_Mode__c,
                        (SELECT Id, COA_Master__c, Journal_Amount__c, Summarization__c, Transaction_Type__c, JV_Run__c, COA_Master_CC__c FROM JE_Configurations__r WHERE Summarization__c != null)
                        FROM JE_Logic__c
                        WHERE Company__c IN: compnySet  AND JV_Type__c IN: transTypeSet And  Payment_Mode__c IN: refundModeSet
                              AND Transaction__c = 'Payment Voucher']) {//AND Bank_Name__r.Property__c IN: propertySet
        
                    String mapKey = je.Company__c + '#' + je.JV_Type__c+ '#' + je.Payment_Mode__c ;
        
                    if (String.isNotBlank(je.Document_Currency__c))
                        mapKey = mapKey + '#' + je.Document_Currency__c;
        
                    fetchJELogic.put(mapKey, je);
                    System.debug('@@@ mapKey   '+mapKey +'  '+je);
                    //filtering Coa Master Id
                    for (JE_Configuration__c jeConfig: je.JE_Configurations__r) {
                        if (jeConfig.COA_Master__c != null)
                            coeMasterId.add(jeConfig.COA_Master__c);
                    }
                }  
                System.debug('@@@ coeMasterId   '+coeMasterId);
        
                if (coeMasterId.size() > 0) {
                    map < String, Id > coaBalanceMap = getCoaBalance(compnySet, coeMasterId, postedMonthSet, postedYearSet);
                    map < String, Id > fiscalYearMap = getFiscalPrd(compnySet, postedMonthSet, postedYearSet);
                    
                    System.debug('@@@ coaBalanceMap   '+coaBalanceMap );    
                    list < Journal_Voucher__c > insertJrvLst = new list < Journal_Voucher__c > ();
                    list < Journal_Entry__c > jrEntryLst = new list < Journal_Entry__c > ();
                    
                    for (Payment_Voucher__c pv: selPVLst) {
                        Integer jrVIndex = 0;
                        if (proPV.Journal_Voucher_Index__c != null)
                            jrVIndex = Integer.valueOf('' + proPV.Journal_Voucher_Index__c);
            
                        jrVIndex = jrVIndex + 1;
                        proPV.Journal_Voucher_Index__c = jrVIndex;
        
                        indxVal = addZeroIndex(jrVIndex);
        
                        name = proPV.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
        
                        Journal_Voucher__c jrV = new Journal_Voucher__c();
                        jrV.Name = name;
                        jrV.Payment_Voucher__c = pv.Id;
                        jrV.Amount__c = pv.Amount_Local__c;
                        jrv.Currency_Code__c = label.Default_Currency;
                        jrV.Company__c = pv.Lease__r.Property__r.Landlord__c;
                        jrV.Journal_Batch__c = jrBatch.Id;
                        //jrV.Remarks__c = dep.Description__c;
                        DateTime dT = pv.CreatedDate;
                        jrv.Posting_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        jrV.Posting_Status__c = 'Unposted';
                        
                        String mapKeyFP = jrV.Company__c + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.year();
                        if (fiscalYearMap.containsKey(mapKeyFP)){
                            jrV.Fiscal_Period__c = fiscalYearMap.get(mapKeyFP);                        
                        }else{
                                jrV.Fiscal_Period__c = selectedFPPV; 
                        }    
                        insertJrvLst.add(jrV);
                        
                        String mapKey = pv.Lease__r.Property__r.Landlord__c + '#' + pv.Transaction_Type__c+ '#' + pv.Payment_Mode__c ;//+ '#' + dep.Lease__r.Property__c 
                        JE_Logic__c jeLogic = fetchJELogic.get(mapKey);
                        
                        if (pv.Currency_Code__c == label.Base_Foreign_Currency) {
                            if (fetchJELogic.containsKey(mapKey + '#' + label.Base_Foreign_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + pv.Currency_Code__c);
                            } else if (fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                            }
                        } else if (pv.Currency_Code__c == label.Default_Currency && fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                            jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                        }
                        System.debug('@@@ mapKeyXX   '+mapKey );
                        System.debug('@@@ jeLogic '+jeLogic );     
                          
                        if (jeLogic != null ){
                            map < String, Decimal > summConfigMap = new map < String, Decimal > (); 
                   
                            for (JE_Configuration__c jeConfig: jeLogic.JE_Configurations__r) {
                                System.debug('@@@ jeConfig  '+jeConfig); 
                                Decimal tempAmt = pv.Amount_Local__c;
                                
                                if (jeConfig.COA_Master_CC__c == label.Base_Foreign_Currency)
                                    tempAmt = pv.Amount__c;
                                 
                                tempAmt = jeLogic.Convert_Negative_Amount__c ? math.abs(tempAmt) : tempAmt;
                                  
                                if (jeConfig.Summarization__c.equalsIgnoreCase('Y')) {
                                    String summMap = jeConfig.COA_Master__c + '#' + jeConfig.Transaction_Type__c + '#' + jeConfig.COA_Master_CC__c;
                                    Decimal tempSummAmt = tempAmt;
        
                                    if (summConfigMap.containsKey(summMap))
                                        tempSummAmt = tempSummAmt + summConfigMap.get(summMap);
        
                                    summConfigMap.put(summMap, tempSummAmt);
                                    
                                    System.debug('@@@ summConfigMap  '+summConfigMap); 
                                } else {
                                    Integer jrEntryIndex = 0;
                                    if (proPV.Journal_Entry_Index__c != null)
                                        jrEntryIndex = Integer.valueOf('' + proPV.Journal_Entry_Index__c);
        
                                    jrEntryIndex = jrEntryIndex + 1;
                                    proPV.Journal_Entry_Index__c = jrEntryIndex;
        
                                    indxVal = addZeroIndex(jrEntryIndex);
                                    name = proPV.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
        
                                    Journal_Entry__c jEntry = new Journal_Entry__c();
                                    jEntry.Name = name;
                                    jEntry.Posting_Status__c = 'Unposted';
                                    jEntry.Journal_Voucher__r = jrV;
                                    //jEntry.Cash_Detail__c = crDet.Id;
                                    jEntry.Currency_Code__c = jeConfig.COA_Master_CC__c;
                                    jEntry.JE_Logic__c = jeLogic.Id;
                                    jEntry.JE_Configuration__c = jeConfig.Id;
        
                                    Date pstDate = jrV.Posting_Date__c;
                                    if (pstDate != null) {
                                        String mapKeyCoa = jrV.Company__c + '#' + jeConfig.COA_Master__c + '#' + pstDate.month() + '#' + pstDate.Year();
                                        if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                            jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                        }
                                    }
        
                                    /*if (jeConfig.Transaction_Type__c == 'Dr') {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if (jeConfig.Transaction_Type__c == 'Cr') {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }*/
                                    if ((jeConfig.Transaction_Type__c == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if ((jeConfig.Transaction_Type__c == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }

                                    jrEntryLst.add(jEntry);
                                    
                                     System.debug('@@@ jEntry'+jEntry); 
                                }
                            }
                            //-------------------- Start work for the Summarization ----------------------------------                       
                            for (String summKey: summConfigMap.keySet()) {
                             System.debug('@@@ summKey'+summKey); 
                                list < String > strLst = summKey.split('#');
                                if (strLst.size() == 3) {
                                    String coaMasterId = strLst.get(0);
                                    String transType = strLst.get(1);
                                    Decimal tempAmt = summConfigMap.get(summKey);
                                    String currCode = strLst.get(2);
        
                                    Integer jrEntryIndex = 0;
                                    if (proPV.Journal_Entry_Index__c != null)
                                        jrEntryIndex = Integer.valueOf('' + proPV.Journal_Entry_Index__c);
        
                                    jrEntryIndex = jrEntryIndex + 1;
                                    proPV.Journal_Entry_Index__c = jrEntryIndex;
        
                                    indxVal = addZeroIndex(jrEntryIndex);
                                    name = proPV.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                    Journal_Entry__c jEntry = new Journal_Entry__c();
                                    jEntry.Name = name;
                                    jEntry.Currency_code__c = currCode;
                                    jEntry.Posting_Status__c = 'Unposted';
                                    jEntry.Journal_Voucher__r = jrV;
        
                                    if (jrV.Posting_Date__c != null) {
                                        String mapKeyCoa = jrV.Company__c + '#' + coaMasterId + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.Year();
                                        if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                            jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                        }
                                    }
        
                                    /*if (transType == 'Dr') {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if (transType == 'Cr') {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }*/
                                    if ((transType == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if ((transType == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }
        
                                    jrEntryLst.add(jEntry);
                                }
                            }
                        }else{
                                Database.rollback(sp);
                                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                                return null;
                        }
                    }
                    if (insertJrvLst.size() > 0) {
                        insert insertJrvLst;
                        //update updateDep;
                        if (jrEntryLst.size() > 0) {
                            for (Journal_Entry__c jre: jrEntryLst)
                                jre.Journal_Voucher__c = jre.Journal_Voucher__r.Id;
                        }
                        insert jrEntryLst;
                        
                        update proPV;
                        return new PageReference('/' + jrBatch.Id);
                    }
                }else{
                    Database.rollback(sp);
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                    return null;
                }
            }else{
                Database.rollback(sp);
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Data error, please contact admin' ));
                return null;
            }
        }else {
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please check atleast 1 Payment Voucher.'));
            return null;
        }
        return null;    
    }
    //-------------------------------------------------------------------->
    //-------------- Start process for the Deposit  ------------------------------------------------------->
    //This method is used to search Deposit based on the property or other filters 
    public void searchDeposit() {
        reloadPg();
        if (String.isBlank(leaseObj.Property__c)) {
            leaseObj.Property__c.addError('Please select Property');
            return;
        }
        Date startDate = Date.newInstance(yearDep, monthDep, 1);
        Date endDate = Date.newInstance(yearDep, monthDep, Date.daysInMonth(yearDep, monthDep));
        
        //Creating Dynamic soql query
        String qry = 'SELECT Id,Name,Lease_Unit__c,Lease__r.Property__c ,Lease__r.Property__r.Landlord__c,Deposit_Type__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant__c,JV_Status__c,Lease_Unit__r.Lease_Agreement_No__r.Tenant__r.Name, ';
        qry += 'Loi__c,Loi_Unit__c,Loi__r.Property__c ,Loi__r.Property__r.Landlord__c,Loi__r.Stage__c,Landlord__c,Property__c,Tenant__c,Tenant_Name__c,';
        qry += ' Deposit_Amount__c,Deposit_Amount_Foreign__c,Deposit_Amount_Local__c,Description__c,Currency_Code__c,Deposit_Date__c ';
        qry += ' FROM Deposit__c '; 
        qry += ' WHERE (Lease__r.Property__c = \'' + leaseObj.Property__c + '\' Or LOI__r.Property__c = \'' + leaseObj.Property__c + '\') AND (JV_Status__c = null OR JV_Status__c = \'Pending\')';
        qry += ' AND (Deposit_Date__c >=: startDate AND Deposit_Date__c <=: endDate AND Deposit_Amount__c != null AND Deposit_Type__c != null) ';
        
        if (String.isNotBlank(depObj.Deposit_Type__c))
            qry += ' AND Deposit_Type__c = \'' + depObj.Deposit_Type__c + '\'';

        if (String.isNotBlank(sltdCurrCodeDep))
            qry += ' AND Currency_Code__c = \'' + sltdCurrCodeDep + '\'';
        
        
        
        for (Deposit__c dep: Database.query(qry))
            depModList.add(new DepositModel(false, dep));

        //Fetching property
        proDep = [SELECT Id, Short_Code__c,Landlord__c, Journal_Voucher_Index__c, Journal_Entry_Index__c, Journal_Batch_Index__c FROM Property__c WHERE Id =: leaseObj.Property__c LIMIT 1];
 
        if (depModList.size() == 0)
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Deposits not found.'));
        System.debug(leaseObj.Property__c + '<===>'+yearDep);
        fiscalPeriodDep = getFiscalPeriods(proDep.Landlord__c,yearDep);
         System.debug('fiscalPeriodDep==>'+yearDep);    
    }
     //This method is used to generate Journal vochers or Entries for the selected Deposits
    public PageReference generateJournalVoucherDeposit() {
        SavePoint sp = Database.setSavePoint();
        if(selectedFPDep == null){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please select Fiscal Posting month.'));
            return null;
        }
         
        list < Deposit__c > selDepLst = new list < Deposit__c > ();
        list < Deposit__c > updateDep = new list < Deposit__c > ();
        //Filtering selected Deposit__c
        for (DepositModel dep: depModList) {
            if (dep.isChek){
                selDepLst.add(dep.dep);
                Deposit__c tempDep = new Deposit__c();
                tempDep.Id = dep.dep.Id;
                tempDep.JV_Status__c = 'Generated';
                updateDep.add(tempDep);
                if(dep.dep.Loi__c != null && dep.dep.Loi__r.Stage__c != 'LOI Signed'){
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please select LOI signed Deposit only <b> <a target="_blank" href="/'+dep.dep.Id+'">'+dep.dep.Name+'</a></b>'));
                    return null;
                }
            }
        }
        System.debug('@@@ selDepLst   '+selDepLst);
        if (selDepLst.size() > 0) {
            Set < String > propertySet = new Set < String > ();
            Set < String > depTypeSet = new Set < String > ();
            Set < String > compnySet = new Set < String > ();
            Set < Integer > postedMonthSet = new Set < Integer > ();
            Set < Integer > postedYearSet = new Set < Integer > ();
            
            //Set current month and year
            Integer currentMonth = system.today().month();
            Integer currentYear = system.today().Year();
        
            // Start process for insert Journal Batch -----------------------------------------
            Integer jBIndex = 0;
            if (proDep.Journal_Batch_Index__c != null)
                jBIndex = Integer.valueOf('' + proDep.Journal_Batch_Index__c);
        
            jBIndex = jBIndex + 1;
            proDep.Journal_Batch_Index__c = jBIndex;
        
            string indxVal = addZeroIndex(jBIndex);
        
            String name = proDep.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
            Journal_Batch__c jrBatch = new Journal_Batch__c(Property__c = proDep.Id);
            jrBatch.name = name;
            
            //jrBatch.Billing_Type__c = ;
            jrBatch.Currency_Code__c = sltdCurrCodeDep;
            jrBatch.JV_Type__c = depObj.Deposit_Type__c;
            jrBatch.Month__c = MonthMap.get(monthDep);
            //jrBatch.Payment_Mode__c = ;
            jrBatch.Transaction__c = 'Deposit';
            jrBatch.Year__c = yearDep;
            
            insert jrBatch;
            
            System.debug('@@@ jrBatch   '+jrBatch);
            // End process for insert Journal Batch -----------------------------------------
            for (Deposit__c dep: selDepLst) {
                propertySet.add(dep.Property__c);
        
                if (String.isNotBlank(dep.Deposit_Type__c))
                    depTypeSet.add(dep.Deposit_Type__c);
        
                if (String.isNotBlank(dep.Landlord__c))
                    compnySet.add(dep.Landlord__c);
        
                if (dep.Deposit_Date__c != null) {
                    postedMonthSet.add(dep.Deposit_Date__c.month());
                    postedYearSet.add(dep.Deposit_Date__c.year());
                }
            }       
            System.debug(propertySet.size() +' '+depTypeSet.size() +' '+compnySet.size() +' '+postedMonthSet.size() +'@@@ inside if   '+jrBatch);
            if (propertySet.size() > 0 && depTypeSet.size() > 0 && compnySet.size() > 0 && postedMonthSet.size() > 0) {
                //Fetching je logic
               
                map < String, JE_Logic__c > fetchJELogic = new map < String, JE_Logic__c > ();
                Set < String > coeMasterId = new Set < String > ();
                System.debug('@@@ compnySet   '+compnySet+' depTypeSet '+depTypeSet);
                for (JE_Logic__c je: [SELECT Id, Company__c, Transaction__c, Charge_Type__c, JV_Type__c, Document_Currency__c, Convert_Negative_Amount__c, Bank_Name__r.Property__c, Payment_Mode__c,
                        (SELECT Id, COA_Master__c, Journal_Amount__c, Summarization__c, Transaction_Type__c, JV_Run__c, COA_Master_CC__c FROM JE_Configurations__r WHERE Summarization__c != null)
                        FROM JE_Logic__c
                        WHERE Company__c IN: compnySet  AND JV_Type__c IN: depTypeSet 
                              AND Transaction__c = 'Deposit']) {//AND Bank_Name__r.Property__c IN: propertySet
        
                    String mapKey = je.Company__c + '#' + je.JV_Type__c;//+ '#' + je.Bank_Name__r.Property__c 
        
                    if (String.isNotBlank(je.Document_Currency__c))
                        mapKey = mapKey + '#' + je.Document_Currency__c;
        
                    fetchJELogic.put(mapKey, je);
                    System.debug('@@@ mapKey   '+mapKey +'  '+je);
                    //filtering Coa Master Id
                    for (JE_Configuration__c jeConfig: je.JE_Configurations__r) {
                        if (jeConfig.COA_Master__c != null)
                            coeMasterId.add(jeConfig.COA_Master__c);
                    }
                }    
                
                System.debug('@@@ coeMasterId   '+coeMasterId);
                
                if (coeMasterId.size() > 0) {
                    map < String, Id > coaBalanceMap = getCoaBalance(compnySet, coeMasterId, postedMonthSet, postedYearSet);
                    map < String, Id > fiscalYearMap = getFiscalPrd(compnySet, postedMonthSet, postedYearSet);
                    
                    System.debug('@@@ coaBalanceMap   '+coaBalanceMap );    
                    list < Journal_Voucher__c > insertJrvLst = new list < Journal_Voucher__c > ();
                    list < Journal_Entry__c > jrEntryLst = new list < Journal_Entry__c > ();
                    
                    for (Deposit__c dep: selDepLst) {
                        Integer jrVIndex = 0;
                        if (proDep.Journal_Voucher_Index__c != null)
                            jrVIndex = Integer.valueOf('' + proDep.Journal_Voucher_Index__c);
            
                        jrVIndex = jrVIndex + 1;
                        proDep.Journal_Voucher_Index__c = jrVIndex;
        
                        indxVal = addZeroIndex(jrVIndex);
        
                        name = proDep.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
        
                        Journal_Voucher__c jrV = new Journal_Voucher__c();
                        jrV.Name = name;
                        jrV.Deposit__c = dep.Id;
                        jrV.Amount__c = dep.Deposit_Amount_Local__c;
                        jrv.Currency_Code__c = label.Default_Currency;
                        jrV.Company__c = dep.Landlord__c;
                        jrV.Journal_Batch__c = jrBatch.Id;
                        jrV.Remarks__c = dep.Description__c;
                        jrv.Posting_Date__c = dep.Deposit_Date__c;
                        jrV.Posting_Status__c = 'Unposted';
                        
                        String mapKeyFP = jrV.Company__c + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.year();
                        if (fiscalYearMap.containsKey(mapKeyFP)){
                            jrV.Fiscal_Period__c = fiscalYearMap.get(mapKeyFP);                        
                        }else{
                                jrV.Fiscal_Period__c = selectedFPDep; 
                        }    
                        insertJrvLst.add(jrV);
                        
                        String mapKey = dep.Landlord__c + '#' + dep.Deposit_Type__c;//+ '#' + dep.Lease__r.Property__c 
                        JE_Logic__c jeLogic = fetchJELogic.get(mapKey);
        
                        if (dep.Currency_Code__c == label.Base_Foreign_Currency) {
                            if (fetchJELogic.containsKey(mapKey + '#' + label.Base_Foreign_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + dep.Currency_Code__c);
                            } else if (fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                            }
                        } else if (dep.Currency_Code__c == label.Default_Currency && fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                            jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                        }
                        System.debug('@@@ mapKeyXX   '+mapKey );
                        System.debug('@@@ jeLogic '+jeLogic );     
                          
                       if (jeLogic != null ){ 
                           map < String, Decimal > summConfigMap = new map < String, Decimal > (); 
                           
                           for (JE_Configuration__c jeConfig: jeLogic.JE_Configurations__r) {
                                System.debug('@@@ jeConfig  '+jeConfig); 
                                Decimal tempAmt = dep.Deposit_Amount_Local__c;
                                
                                if (jeConfig.COA_Master_CC__c == label.Base_Foreign_Currency)
                                    tempAmt = dep.Deposit_Amount__c;
                                
                                tempAmt = jeLogic.Convert_Negative_Amount__c ? math.abs(tempAmt) : tempAmt;
                                
                                if (jeConfig.Summarization__c.equalsIgnoreCase('Y')) {
                                    String summMap = jeConfig.COA_Master__c + '#' + jeConfig.Transaction_Type__c + '#' + jeConfig.COA_Master_CC__c;
                                    Decimal tempSummAmt = tempAmt;
    
                                    if (summConfigMap.containsKey(summMap))
                                        tempSummAmt = tempSummAmt + summConfigMap.get(summMap);
    
                                    summConfigMap.put(summMap, tempSummAmt);
                                    
                                    System.debug('@@@ summConfigMap  '+summConfigMap); 
                                } else {
                                    Integer jrEntryIndex = 0;
                                    if (proDep.Journal_Entry_Index__c != null)
                                        jrEntryIndex = Integer.valueOf('' + proDep.Journal_Entry_Index__c);
    
                                    jrEntryIndex = jrEntryIndex + 1;
                                    proDep.Journal_Entry_Index__c = jrEntryIndex;
    
                                    indxVal = addZeroIndex(jrEntryIndex);
                                    name = proDep.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
    
                                    Journal_Entry__c jEntry = new Journal_Entry__c();
                                    jEntry.Name = name;
                                    jEntry.Posting_Status__c = 'Unposted';
                                    jEntry.Journal_Voucher__r = jrV;
                                    //jEntry.Cash_Detail__c = crDet.Id;
                                    jEntry.Currency_Code__c = jeConfig.COA_Master_CC__c;
                                    jEntry.JE_Logic__c = jeLogic.Id;
                                    jEntry.JE_Configuration__c = jeConfig.Id;
    
                                    Date pstDate = jrV.Posting_Date__c;
                                    if (pstDate != null) {
                                        String mapKeyCoa = jrV.Company__c + '#' + jeConfig.COA_Master__c + '#' + pstDate.month() + '#' + pstDate.Year();
                                        if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                            jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                        }
                                    }
    
                                    /*if (jeConfig.Transaction_Type__c == 'Dr') {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if (jeConfig.Transaction_Type__c == 'Cr') {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }*/
                                    if ((jeConfig.Transaction_Type__c == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if ((jeConfig.Transaction_Type__c == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }
                                    jrEntryLst.add(jEntry);
                                    
                                     System.debug('@@@ jEntry'+jEntry); 
                                }
                            }
                            //-------------------- Start work for the Summarization ----------------------------------                       
                            for (String summKey: summConfigMap.keySet()) {
                             System.debug('@@@ summKey'+summKey); 
                                list < String > strLst = summKey.split('#');
                                if (strLst.size() == 3) {
                                    String coaMasterId = strLst.get(0);
                                    String transType = strLst.get(1);
                                    Decimal tempAmt = summConfigMap.get(summKey);
                                    String currCode = strLst.get(2);
        
                                    Integer jrEntryIndex = 0;
                                    if (proDep.Journal_Entry_Index__c != null)
                                        jrEntryIndex = Integer.valueOf('' + proDep.Journal_Entry_Index__c);
        
                                    jrEntryIndex = jrEntryIndex + 1;
                                    proDep.Journal_Entry_Index__c = jrEntryIndex;
        
                                    indxVal = addZeroIndex(jrEntryIndex);
                                    name = proDep.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                    Journal_Entry__c jEntry = new Journal_Entry__c();
                                    jEntry.Name = name;
                                    jEntry.Currency_code__c = currCode;
                                    jEntry.Posting_Status__c = 'Unposted';
                                    jEntry.Journal_Voucher__r = jrV;
        
                                    if (jrV.Posting_Date__c != null) {
                                        String mapKeyCoa = jrV.Company__c + '#' + coaMasterId + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.Year();
                                        if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                            jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                        }
                                    }
        
                                    /*if (transType == 'Dr') {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if (transType == 'Cr') {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }*/
                                    if ((transType == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if ((transType == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }
                                    
                                    jrEntryLst.add(jEntry);
                                }
                            }
                            //-------------------- End work for the Summarization ----------------------------------
                       }else{
                            Database.rollback(sp);
                            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                            return null;
                        }
                    }       
                    if (insertJrvLst.size() > 0) {
                        insert insertJrvLst;
                        //update updateDep;
                        if (jrEntryLst.size() > 0) {
                            for (Journal_Entry__c jre: jrEntryLst){
                                jre.Journal_Voucher__c = jre.Journal_Voucher__r.Id;
                                System.debug('jre.Currency_Code__c-->'+jre.Currency_Code__c);
                            }
                        }
                        insert jrEntryLst;
                        
                        update proDep;
                        return new PageReference('/' + jrBatch.Id);
                    }
                } else{
                    Database.rollback(sp);
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                    return null;
                }
                                   
            }else{
                Database.rollback(sp);
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Data error, please contact admin' ));
                return null;
            }
        }else {
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please check atleast 1 Deposit.'));
            return null;
        }
        return null;
    }
    //Module class for the selection of Deposits
    public class DepositModel {
        public Boolean isChek {get;set;}
        public Deposit__c dep {get;set;}

        public DepositModel(Boolean isChek, Deposit__c dep) {
            this.isChek = isChek;
            this.dep = dep;
        }
    }
    //-------------- Start process for the Cash Receipt  ------------------------------------------------------->
    //This method is used to search cash receipt based on the property or other filters 
    public void searchCashReceipt() {
        reloadPg();
        if (String.isBlank(crObj.Property__c)) {
            crObj.Property__c.addError('Please select Property');
            return;
        }

        Date startDate = Date.newInstance(yearCR, monthCR, 1);
        Date endDate = Date.newInstance(yearCR, monthCR, Date.daysInMonth(yearCR, monthCR));

        //Creating Dynamic soql query
        String qry = 'SELECT Id,Name,Property__r.Landlord__c,Payment_Mode__c,Tenant__c,JV_Status__c,Tenant__r.Name, ';
        qry += ' Payment_Currency__c,Payment_Date__c,Remarks__c,Payment_Amount__c,Payment_Amount_Local__c,Total_Amount_Paid__c,Total_Paid__c ';
        qry += ' FROM Cash_Receipt__c ';
        qry += ' WHERE Property__c = \'' + crObj.Property__c + '\' AND (JV_Status__c = null OR JV_Status__c = \'Pending\')';
        qry += ' AND (Payment_Date__c >=: startDate AND Payment_Date__c <=: endDate AND Payment_Amount__c != null AND Payment_Mode__c != null) ';

        if (String.isNotBlank(crObj.Payment_Mode__c))
            qry += ' AND Payment_Mode__c = \'' + crObj.Payment_Mode__c + '\'';

        if (String.isNotBlank(sltdCurrCodeCR))
            qry += ' AND Payment_Currency__c = \'' + sltdCurrCodeCR + '\'';


        qry += ' ORDER BY Payment_Mode__c';

        for (Cash_Receipt__c cr: Database.query(qry))
            crModList.add(new CaseRecptModel(false, cr));

        //Fetching property
        proCR = [SELECT Id, Short_Code__c,Landlord__c, Journal_Voucher_Index__c, Journal_Entry_Index__c, Journal_Batch_Index__c FROM Property__c WHERE Id =: crObj.Property__c LIMIT 1];

        if (crModList.size() == 0)
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Cash Receipts not found.'));
        
        fiscalPeriodCR  = getFiscalPeriods(proCR.Landlord__c,yearCr);
        
    }

    //This method is used to generate Journal vochers or Entries for the selected invoices
    public PageReference generateJournalVoucherCR() {
        SavePoint sp = Database.setSavePoint();
        
        if(selectedFPCR == null){
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please select Fiscal Posting month.'));
            return null;
        }
        
        list < Cash_Receipt__c > selCRLst = new list < Cash_Receipt__c > ();
        list < Cash_Receipt__c > updateCR = new list < Cash_Receipt__c > ();
        //Filtering selected CR
        for (CaseRecptModel cr: crModList) {
            if (cr.isChek){
                selCRLst.add(cr.cr);
                Cash_Receipt__c tempCR = new Cash_Receipt__c();
                tempCR.Id = cr.cr.Id;
                tempCR.JV_Status__c = 'Generated';
                updateCR.add(tempCR);
            }
        }

        if (selCRLst.size() > 0) {
            Set < String > propertySet = new Set < String > ();
            Set < String > paymentModeSet = new Set < String > ();
            Set < String > compnySet = new Set < String > ();
            Set < Integer > postedMonthSet = new Set < Integer > ();
            Set < Integer > postedYearSet = new Set < Integer > ();

            //Set current month and year
            Integer currentMonth = system.today().month();
            Integer currentYear = system.today().Year();

            // Start process for insert Journal Batch -----------------------------------------
            Integer jBIndex = 0;
            if (proCR.Journal_Batch_Index__c != null)
                jBIndex = Integer.valueOf('' + proCR.Journal_Batch_Index__c);

            jBIndex = jBIndex + 1;
            proCR.Journal_Batch_Index__c = jBIndex;

            string indxVal = addZeroIndex(jBIndex);

            String name = proCR.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
            Journal_Batch__c jrBatch = new Journal_Batch__c(Property__c = proCR.Id);
            jrBatch.name = name;
            //jrBatch.Billing_Type__c = ;
            jrBatch.Currency_Code__c = sltdCurrCodeCR;
            //jrBatch.JV_Type__c = depObj.Deposit_Type__c;
            jrBatch.Month__c = MonthMap.get(monthcr);
            jrBatch.Payment_Mode__c = crObj.Payment_Mode__c;
            jrBatch.Transaction__c = 'Cash Receipt';
            jrBatch.Year__c = yearCR;
            insert jrBatch;
            // End process for insert Journal Batch -----------------------------------------

            for (Cash_Receipt__c cr: selCRLst) {
                propertySet.add(cr.Property__c);

                if (String.isNotBlank(cr.Payment_Mode__c))
                    paymentModeSet.add(cr.Payment_Mode__c);

                if (String.isNotBlank(cr.Property__r.Landlord__c))
                    compnySet.add(cr.Property__r.Landlord__c);

                if (cr.Payment_Date__c != null) {
                    postedMonthSet.add(cr.Payment_Date__c.month());
                    postedYearSet.add(cr.Payment_Date__c.year());
                }
            }

            if (propertySet.size() > 0 && paymentModeSet.size() > 0 && compnySet.size() > 0 && postedMonthSet.size() > 0) {
                //Fetching JE logic
                map < Id, list < Cash_Detail__c >> crdetailMap = new map < Id, list < Cash_Detail__c >> ();
                for (Cash_Detail__c crDet: [SELECT Id, Amount_Paid__c, Amount_Paid_Local__c, Cash_Receipt__c, Currency_Code__c,
                                            Deposit__c, Parent_Exchange_Rate__c, Payment_Date__c, Payment_Mode__c
                                            FROM Cash_Detail__c WHERE Cash_Receipt__c IN: selCRLst]) {
                    list < Cash_Detail__c > tempLst = new list < Cash_Detail__c > ();

                    if (crdetailMap.containsKey(crDet.Cash_Receipt__c))
                        tempLst = crdetailMap.get(crDet.Cash_Receipt__c);

                    tempLst.add(crDet);
                    crdetailMap.put(crDet.Cash_Receipt__c, tempLst);
                }

                //Fetching je logic
                map < String, JE_Logic__c > fetchJELogic = new map < String, JE_Logic__c > ();
                Set < String > coeMasterId = new Set < String > ();

                for (JE_Logic__c je: [SELECT Id, Company__c, Transaction__c, Charge_Type__c, JV_Type__c, Document_Currency__c, Convert_Negative_Amount__c, Bank_Name__r.Property__c, Payment_Mode__c,
                        (SELECT Id, COA_Master__c, Journal_Amount__c, Summarization__c, Transaction_Type__c, JV_Run__c, COA_Master_CC__c FROM JE_Configurations__r WHERE Summarization__c != null)
                        FROM JE_Logic__c
                        WHERE Company__c IN: compnySet AND Bank_Name__r.Property__c IN: propertySet AND Payment_Mode__c IN: paymentModeSet 
                              AND Transaction__c = 'Cash Receipt']) {

                    String mapKey = je.Company__c + '#' + je.Bank_Name__r.Property__c + '#' + je.Payment_Mode__c;

                    if (String.isNotBlank(je.Document_Currency__c))
                        mapKey = mapKey + '#' + je.Document_Currency__c;

                    fetchJELogic.put(mapKey, je);

                    //filtering Coa Master Id
                    for (JE_Configuration__c jeConfig: je.JE_Configurations__r) {
                        if (jeConfig.COA_Master__c != null)
                            coeMasterId.add(jeConfig.COA_Master__c);
                    }
                }
                
                System.debug('@@@ coeMasterId   '+coeMasterId);

                if (coeMasterId.size() > 0) {
                    map < String, Id > coaBalanceMap = getCoaBalance(compnySet, coeMasterId, postedMonthSet, postedYearSet);
                    map < String, Id > fiscalYearMap = getFiscalPrd(compnySet, postedMonthSet, postedYearSet);
                    
                    System.debug('@@@ coaBalanceMap   '+coaBalanceMap );    
                    list < Journal_Voucher__c > insertJrvLst = new list < Journal_Voucher__c > ();
                    list < Journal_Entry__c > jrEntryLst = new list < Journal_Entry__c > ();

                    for (Cash_Receipt__c cr: selCRLst) {
                    
                        Integer jrVIndex = 0;
                        if (proCR.Journal_Voucher_Index__c != null)
                            jrVIndex = Integer.valueOf('' + proCR.Journal_Voucher_Index__c);

                        jrVIndex = jrVIndex + 1;
                        proCR.Journal_Voucher_Index__c = jrVIndex;

                        indxVal = addZeroIndex(jrVIndex);

                        name = proCR.Short_Code__c + '-JV-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;

                        Journal_Voucher__c jrV = new Journal_Voucher__c();
                        jrV.Name = name;
                        jrV.Cash_Receipt__c = cr.Id;
                        jrV.Amount__c = cr.Payment_Amount_Local__c;
                        jrv.Currency_Code__c = label.Default_Currency;
                        jrV.Company__c = cr.Property__r.Landlord__c;
                        jrV.Journal_Batch__c = jrBatch.Id;
                        jrV.Remarks__c = cr.Remarks__c;
                        jrv.Posting_Date__c = cr.Payment_Date__c;
                        jrV.Posting_Status__c = 'Unposted';
                        
                        String mapKeyFP = jrV.Company__c + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.year();
                        if (fiscalYearMap.containsKey(mapKeyFP)){
                            jrV.Fiscal_Period__c = fiscalYearMap.get(mapKeyFP);                        
                        }else{
                                jrV.Fiscal_Period__c = selectedFPCR; 
                        }    
                        insertJrvLst.add(jrV);

                        String mapKey = cr.Property__r.Landlord__c + '#' + cr.Property__c + '#' + cr.Payment_Mode__c;
                        JE_Logic__c jeLogic = fetchJELogic.get(mapKey);

                        if (cr.Payment_Currency__c == label.Base_Foreign_Currency) {
                            if (fetchJELogic.containsKey(mapKey + '#' + label.Base_Foreign_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + cr.Payment_Currency__c);
                            } else if (fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                                jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                            }
                        } else if (cr.Payment_Currency__c == label.Default_Currency && fetchJELogic.containsKey(mapKey + '#' + label.Default_Currency)) {
                            jeLogic = fetchJELogic.get(mapKey + '#' + label.Default_Currency);
                        }
                        
                         System.debug('@@@ jeLogic '+jeLogic );     
                            
                        if (jeLogic != null && crdetailMap.containsKey(cr.Id)) {
                            map < String, Decimal > summConfigMap = new map < String, Decimal > ();

                            for (Cash_Detail__c crDet: crdetailMap.get(cr.Id)) {
                                 System.debug('@@@ coaBalanceMap   '+crdetailMap.containsKey(cr.Id)); 
                                for (JE_Configuration__c jeConfig: jeLogic.JE_Configurations__r) {
                                    System.debug('@@@ jeConfig  '+jeConfig); 
                                    Decimal tempAmt = crDet.Amount_Paid_Local__c;
                                    
                                    if (jeConfig.COA_Master_CC__c == label.Base_Foreign_Currency)
                                        tempAmt = crDet.Amount_Paid__c;
                                    
                                    tempAmt = jeLogic.Convert_Negative_Amount__c ? math.abs(tempAmt) : tempAmt;
                                    
                                    if (jeConfig.Summarization__c.equalsIgnoreCase('Y')) {
                                        String summMap = jeConfig.COA_Master__c + '#' + jeConfig.Transaction_Type__c + '#' + jeConfig.COA_Master_CC__c;
                                        Decimal tempSummAmt = tempAmt;

                                        if (summConfigMap.containsKey(summMap))
                                            tempSummAmt = tempSummAmt + summConfigMap.get(summMap);

                                        summConfigMap.put(summMap, tempSummAmt);
                                        
                                        System.debug('@@@ summConfigMap  '+summConfigMap); 
                                    } else {
                                        Integer jrEntryIndex = 0;
                                        if (proCR.Journal_Entry_Index__c != null)
                                            jrEntryIndex = Integer.valueOf('' + proCR.Journal_Entry_Index__c);

                                        jrEntryIndex = jrEntryIndex + 1;
                                        proCR.Journal_Entry_Index__c = jrEntryIndex;

                                        indxVal = addZeroIndex(jrEntryIndex);
                                        name = proCR.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;

                                        Journal_Entry__c jEntry = new Journal_Entry__c();
                                        jEntry.Name = name;
                                        jEntry.Posting_Status__c = 'Unposted';
                                        jEntry.Journal_Voucher__r = jrV;
                                        jEntry.Cash_Detail__c = crDet.Id;
                                        jEntry.Currency_Code__c = jeConfig.COA_Master_CC__c;
                                        jEntry.JE_Logic__c = jeLogic.Id;
                                        jEntry.JE_Configuration__c = jeConfig.Id;

                                        Date pstDate = jrV.Posting_Date__c;
                                        if (pstDate != null) {
                                            String mapKeyCoa = jrV.Company__c + '#' + jeConfig.COA_Master__c + '#' + pstDate.month() + '#' + pstDate.Year();
                                            if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                                jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                            }
                                        }

                                        /*if (jeConfig.Transaction_Type__c == 'Dr') {
                                            jEntry.Dr_Amount__c = tempAmt;
                                        } else if (jeConfig.Transaction_Type__c == 'Cr') {
                                            jEntry.Cr_Amount__c = tempAmt;
                                        }*/
                                        if ((jeConfig.Transaction_Type__c == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                            jEntry.Dr_Amount__c = tempAmt;
                                        } else if ((jeConfig.Transaction_Type__c == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (jeConfig.Transaction_Type__c == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                            jEntry.Cr_Amount__c = tempAmt;
                                        }
                                        jrEntryLst.add(jEntry);
                                        
                                         System.debug('@@@ jEntry'+jEntry); 
                                    }
                                }
                            }

                            //-------------------- Start work for the Summarization ----------------------------------                       
                            for (String summKey: summConfigMap.keySet()) {
                             System.debug('@@@ summKey'+summKey); 
                                list < String > strLst = summKey.split('#');
                                if (strLst.size() == 3) {
                                    String coaMasterId = strLst.get(0);
                                    String transType = strLst.get(1);
                                    Decimal tempAmt = summConfigMap.get(summKey);
                                    String currCode = strLst.get(2);

                                    Integer jrEntryIndex = 0;
                                    if (proCR.Journal_Entry_Index__c != null)
                                        jrEntryIndex = Integer.valueOf('' + proCR.Journal_Entry_Index__c);

                                    jrEntryIndex = jrEntryIndex + 1;
                                    proCR.Journal_Entry_Index__c = jrEntryIndex;

                                    indxVal = addZeroIndex(jrEntryIndex);
                                    name = proCR.Short_Code__c + '-JE-' + currentYear + (currentMonth < 10 ? '0' + currentMonth : '' + currentMonth) + '-' + indxVal;
                                    Journal_Entry__c jEntry = new Journal_Entry__c();
                                    jEntry.Name = name;
                                    jEntry.Currency_code__c = currCode;
                                    jEntry.Posting_Status__c = 'Unposted';
                                    jEntry.Journal_Voucher__r = jrV;

                                    if (jrV.Posting_Date__c != null) {
                                        String mapKeyCoa = jrV.Company__c + '#' + coaMasterId + '#' + jrV.Posting_Date__c.month() + '#' + jrV.Posting_Date__c.Year();
                                        if (coaBalanceMap.containsKey(mapKeyCoa)) {
                                            jEntry.COA_Balance__c = coaBalanceMap.get(mapKeyCoa);
                                        }
                                    }

                                    /*if (transType == 'Dr') {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if (transType == 'Cr') {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }*/
                                    if ((transType == 'Dr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Cr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Dr_Amount__c = tempAmt;
                                    } else if ((transType == 'Cr' && !jeLogic.Convert_Negative_Amount__c) || (transType == 'Dr' && jeLogic.Convert_Negative_Amount__c)) {
                                        jEntry.Cr_Amount__c = tempAmt;
                                    }

                                    jrEntryLst.add(jEntry);
                                }
                            }
                            //-------------------- End work for the Summarization ----------------------------------
                        }else{
                            Database.rollback(sp);
                            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                            return null;
                        }
                    }                    
                    if (insertJrvLst.size() > 0) {
                        insert insertJrvLst;
                        //update updateCR;
                        if (jrEntryLst.size() > 0) {
                            for (Journal_Entry__c jre: jrEntryLst)
                                jre.Journal_Voucher__c = jre.Journal_Voucher__r.Id;
                        }
                        insert jrEntryLst;
                        
                        update proCR;
                        return new PageReference('/' + jrBatch.Id);
                    }
                    
                }else{
                    Database.rollback(sp);
                    Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'No JE logic found' ));
                    return null;
                }
            } else{
                Database.rollback(sp);
                Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Data error, please contact admin' ));
                return null;
            }
        }else {
            Apexpages.addMessage(new apexpages.message(Apexpages.Severity.Error, 'Please check atleast 1 Cash Receipt.'));
            return null;
        }
        return null;
    }
    
    //Module class for the selection of Invoices
    public class CaseRecptModel {
        public Boolean isChek {get;set;}
        public Cash_Receipt__c cr {get;set;}

        public CaseRecptModel(Boolean isChek, Cash_Receipt__c cr) {
            this.isChek = isChek;
            this.cr = cr;
        }
    }
}