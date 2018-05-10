@isTest(seeAllData=false)
public with sharing class CashAdjustmentController_Test {
    static Rent_Roll_Detail__c rrd;
    static Property__c prop;
    static Account acc;
    static Lease_Unit__c lu;
    static Lease_Charges__c lc;
    static Invoice__c inv;
    Static Applicable_Charges__c ac;
    static void init(){
        prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        ac = new Applicable_Charges__c();
        ac.Name = 'Test Charge';
        ac.Property__c = prop.Id;
        ac.Charge_Type__c = 'Miscellaneous';
        ac.Currency_Code__c = Label.Default_Currency;
        ac.Billing_Terms__c = 'Prorate';
        ac.Type__c = 'Fixed';
        ac.Charge_Rate__c = 500;
        insert ac;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        insert unt;
        
        acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        ls.Lease_Start_Date__c =  System.today().addDays(-10);
        ls.Lease_Tenure_Days__c = ''+31;
        insert ls;
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c =  System.today().addDays(10);
        insert lu;
        
        lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        insert lc;
        
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        rentRoll.Billing_Type__c = 'Rent';
        insert rentRoll;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Currency_Code__c = Label.Default_Currency;
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        insert ili;
         
        rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = rs.Status__c;
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        rrd.Invoice_Line_Item__c = ili.Id;
        insert rrd;
    }
    /*static TestMethod void TestSelectOptions(){
        init();
        Test.startTest();
        PageReference pageRef = Page.CreditDebitNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('request_Id', rrd.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(rrd);
        
        CashAdjustmentController tt = new CashAdjustmentController();
        tt.filter  = new Rent_Schedules__c();
        tt.filter.PropertyLU__c = prop.Id;
        tt.filter.TenantLU__c = acc.Id;
        tt.billingType = 'Debit Note';
        List<SelectOption> listOpt = tt.getLeaseUnitOptionList();
        listOpt = tt.getLeaseChargeOptionList();
        listOpt = tt.getLeaseOptionList();
        listOpt = tt.getMonthList();
        listOpt = tt.getYearList();
        Test.stopTest();
     }  */
     static TestMethod void Test(){
        init();
        Test.startTest();
        PageReference pageRef = Page.CreditDebitNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('request_Id', rrd.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(rrd);
        
        CashAdjustmentController tt = new CashAdjustmentController();
        
        List<SelectOption> listOpt = tt.getMonthList();
        listOpt = tt.getYearList();
        
        tt.billingType = 'Ad-Hoc Invoice';
        tt.filter  = new Rent_Schedules__c();
        tt.search();
        tt.filter.PropertyLU__c = prop.Id;
        tt.search();
        tt.filter.TenantLU__c = acc.Id;
        tt.search();
        tt.leaseUnit = lu.Id;
        tt.invNumber = inv.name;
        
        listOpt = tt.getLeaseUnitOptionList();
        listOpt = tt.getLeaseChargeOptionList();
        listOpt = tt.getLeaseOptionList();
        tt.leaseChargeIds = new List<string>();
        tt.search();
        tt.leaseChargeIds.add(lc.Id);
        tt.search();
        tt.refresh();
        tt.next();
        tt.search();
        tt.filter.PropertyLU__c = prop.Id;
        for(CashAdjustmentController.adHocItemWrapper adi:tt.adhocItemList){
            adi.adjustAmount = 10;
        }
        tt.generate();
        for(CashAdjustmentController.adHocItemWrapper adi:tt.adhocItemList){
            adi.adjustAmount = 0;
        }
        tt.generate();
        Test.stopTest();
     }  
     static TestMethod void Test1(){
        init();
        Test.startTest();
        PageReference pageRef = Page.CreditDebitNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('request_Id', rrd.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(rrd);
        
        CashAdjustmentController tt = new CashAdjustmentController();
        List<SelectOption> listOpt = tt.getMonthList();
        listOpt = tt.getYearList();
        
        tt.filter  = new Rent_Schedules__c();
        tt.filter.PropertyLU__c = prop.Id;
        tt.filter.TenantLU__c = acc.Id;
        tt.billingType = 'Debit Note';
        tt.leaseUnit = lu.Id;
        
        listOpt = tt.getLeaseUnitOptionList();
        listOpt = tt.getLeaseChargeOptionList();
        listOpt = tt.getLeaseOptionList();
        tt.leaseChargeIds = new List<string>();
        tt.search();
        tt.leaseChargeIds.add(lc.Id);
        tt.leaseAgreementNo = lu.Lease_Agreement_No__c;
        tt.search();
        tt.invNumber = inv.name;
        tt.currencyCode = Label.Default_Currency;
        tt.search();
        
        tt.next();
        for(CashAdjustmentController.DCWrapper adi:tt.dcWrapList){
            adi.adjustAmount = 10;
            adi.isSelected = true;
        }
        tt.generate();
        tt.refresh();
        tt.invNumber = inv.name;
        for(CashAdjustmentController.DCWrapper adi:tt.dcWrapList){
            adi.adjustAmount = 10;
            adi.remarks = '';
            adi.isSelected = true;
        }
        tt.generate();
        
        for(CashAdjustmentController.DCWrapper adi:tt.dcWrapList){
            adi.adjustAmount = 0;
            adi.isSelected = true;
        }
        tt.generate();
        tt.back();
        Test.stopTest();
     }  
     
     static TestMethod void Test2(){
        init();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rrd);
        
        CashAdjustmentController tt = new CashAdjustmentController();
        List<SelectOption> listOpt = tt.getMonthList();
        listOpt = tt.getYearList();
        
        tt.filter  = new Rent_Schedules__c();
        tt.filter.PropertyLU__c = prop.Id;
        tt.filter.TenantLU__c = acc.Id;
        tt.billingType = 'Miscellaneous';
        
        tt.getMiscApplChargeList();
        tt.getCurrencyCodes();
        
        tt.CurrencyCode = Label.Default_Currency;
        
        tt.applChargeIds.add(ac.Id);
        tt.search();
        
        tt.next();
        
        for(CashAdjustmentController.MiscWrapper mw:tt.miscWrapList){
            mw.amount = 10;
            mw.applyCommTax = true;
            mw.remarks = 'Test';
        }
        tt.generate();
        tt.refresh();
        tt.back();
        Test.stopTest();
     }  
}