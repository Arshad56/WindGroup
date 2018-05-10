@isTest(seeAllData=false)
public with sharing class CalcMultiCurrency_Test {
    static Lease_Charges__c lc;
    static Exchange_Rate__c excLocal;
    static Exchange_Rate__c excForeign;
    static Rent_Schedules__c rsc;
    static Rent_Roll__c rentRoll;
    static Invoice__c inv;
    static Invoice_Line_Item__c ili;
    static Rent_Roll_Detail__c rrd;
    static void init(){
        
        excLocal = new Exchange_Rate__c();
        excLocal.Conversion_Rate__c = 1;
        excLocal.Currency_Code__c = label.Default_Currency;
        excLocal.Applicable_Function__c ='Finance';
        excLocal.Start_Date_Time__c = system.now();
        insert excLocal;
        
        excForeign = new Exchange_Rate__c();
        excForeign.Conversion_Rate__c = 1;
        excForeign.Currency_Code__c = label.Base_Foreign_Currency;
        excForeign.Applicable_Function__c ='Finance';
        excForeign.Start_Date_Time__c = system.now();
        insert excForeign;
        
        
        
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        insert unt;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
         
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
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
        lc.Currency_Code__c = label.Default_Currency;
        lc.Base_Value__c = 20;
        
        rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        rentRoll.Total_Amount__c = 5;
        rentRoll.Total_Diesel_Rate__c = 5;
        rentRoll.Total_Comm_Tax__c = 5;
        
        rsc = new Rent_Schedules__c();
        rsc.Unit__c = unt.Id;
        rsc.Status__c = 'In-Tenancy';
        rsc.Lease_Charge__c = lc.Id;
        rsc.Start_Date__c = system.today();
        rsc.End_Date__c = system.today().addMonths(1);
        rsc.Rent_Roll__c = rentRoll.Id;
        rsc.Approved__c = true;
        rsc.Amount__c = 10;
        rsc.Comm_Tax__c = 2;
        rsc.Currency_Code__c = label.Default_Currency;
        
        rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rsc.Unit__c;
        rrd.Status__c = 'Pending';
        rrd.Lease_Charge__c = rsc.Lease_Charge__c;
        rrd.Start_Date__c = rsc.Start_Date__c;
        rrd.End_Date__c = rsc.End_Date__c;
        rrd.Rent_Roll__c = rsc.Rent_Roll__c;
        rrd.Amount__c = 10;
        rrd.Currency_Code__c = rsc.Currency_Code__c;
        rrd.Comm_Tax_Amount__c = .2;
        
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Invoice__c' and Name='Local' Limit 1];
        
        inv = new Invoice__c();
        inv.name ='Test Inv';
        inv.Invoice_Date__c = system.today();
        inv.Tenant_Name__c = acc.Id;
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Amount_Paid__c = 20;
        inv.Currency_Code__c = label.Default_Currency;
        inv.recordtypeid= rt.Id;
        
        
    }
    static testMethod void testLCandRR() {
        Test.startTest();
        init();
        
        insert lc;
        insert rentRoll;
        insert rsc;
        insert rrd;
        
        lc.Currency_Code__c = label.Base_Foreign_Currency;
        lc.Exchange_Rate__c = 20;
        update lc;
        
        rentRoll.Currency_Code__c = label.Base_Foreign_Currency;
        rentRoll.Exchange_Rate__c = 20;
        update  rentRoll;
        
        rsc.Currency_Code__c = label.Base_Foreign_Currency;
        rsc.Exchange_Rate__c = 20;
        update rsc;
        
        Test.stopTest();
    }
    static testMethod void testLInv() {
        init();
        insert lc;
        insert rentRoll;
        insert rsc;
        
        Test.startTest();
        
        excLocal.Applicable_Function__c ='Operations';
        update excLocal;
        excForeign.Applicable_Function__c ='Operations';
        update excForeign;
        insert inv;
        
        ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id; 
        ili.Rent_Schedule__c = rsc.Id;
        ili.Amount__c =100;
        ili.Comm_Tax_Amount__c = 2;
        insert ili;
        
        inv.Currency_Code__c = label.Base_Foreign_Currency;
        inv.Exchange_Rate__c = 20;
        update inv;
        
        Test.stopTest();
    }
    
    static testMethod void testLDeposit() {
        init();
        insert lc;
        insert rentRoll;
        insert rsc;
        
        Test.startTest();
        
        excLocal.Applicable_Function__c ='Operations';
        update excLocal;
        excForeign.Applicable_Function__c ='Operations';
        update excForeign;
        insert inv;
        
        Deposit__c dep1 = new Deposit__c();
        dep1.name='--System Generated--';
        dep1.Lease__c = inv.Lease__c;
        dep1.Lease_Unit__c  = lc.Lease_Unit__c; 
        dep1.Deposit_Amount__c = 500;
        dep1.Currency_Code__c = label.Default_Currency;
        insert dep1;
        
        dep1.Currency_Code__c = label.Base_Foreign_Currency;
        dep1.Exchange_Rate__c = 20;
        update dep1;
        
        Exchange_Rate__c er = new Exchange_Rate__c();
        er.Currency_Code__c = label.Base_Foreign_Currency;
        er.Conversion_Rate__c = 1399;
        er.Applicable_Function__c = 'Finance';
        er.Start_Date_Time__c = system.today().addDays(-1);
        insert er;
        
        Payment_Voucher__c pv = new Payment_Voucher__c();
        pv.Deposit__c = dep1.Id;
        pv.Refund_Mode__c = 'Cash';
        pv.Currency_Code__c = dep1.Currency_Code__c;
        pv.Amount__c = -100;
        pv.Lease__c = dep1.Lease__c;            
        pv.Exchange_Rate__c = 1400;
        pv.Refunded_Amount__c = 5;
        insert pv;
        
        Payment_Voucher__c pv1 = new Payment_Voucher__c();
        pv1.Deposit__c = dep1.Id;
        pv1.Refund_Mode__c = 'Cash';
        pv1.Currency_Code__c = label.Default_Currency;
        pv1.Amount__c = -100;
        pv1.Lease__c = dep1.Lease__c;            
        pv1.Exchange_Rate__c = 1;
        pv1.Refunded_Amount__c = 5;
        insert pv1;
        
        Test.stopTest();
    }
    
}