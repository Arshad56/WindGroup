@isTest(seeAllData=false)
public with sharing class InvoiceButtonClick_Test {
    static TestMethod void Test(){
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
        unt.Charge_Method__c = 'Monthly Rate - L';
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
        
        Lease_Charges__c lc = new Lease_Charges__c();
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
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        insert ili;
         
        Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = 'Approved';
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        rrd.Invoice_Line_Item__c = ili.Id;
        insert rrd;
        
        rs.Rent_Roll_Detail__c = rrd.Id;
        update rs;
        
        Test.startTest();
        InvoiceButtonClick.voidAllInvoices(inv.Id, '');
        InvoiceButtonClick.unvoidAllInvoices(inv.Id);
        Test.stopTest();
    }
}