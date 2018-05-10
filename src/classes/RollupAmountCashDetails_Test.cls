@isTest(seeAllData=false)
public with sharing class RollupAmountCashDetails_Test { 
    static TestMethod void Test(){
        Test.startTest();
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        prop.Deposit_Refund_Index__c = null;
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        acc.BillingCity = 'TestCity';
        acc.BillingCountry = 'Singapore';
        insert acc;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        insert unt;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        insert inv;
        
        Deposit__c dep1 = new Deposit__c();
        dep1.name='--System Generated--';
        dep1.Lease__c = ls.id;
        dep1.Lease_Unit__c  = lu.id; 
        insert dep1;   
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        cr.Name = 'Test';
        cr.Property__c = prop.Id;
        cr.Tenant__c = acc.Id;
        cr.Remarks__c = 'Testing';
        cr.Payment_Mode__c = 'Cash';
        cr.Payment_Date__c = system.today();
        cr.Payment_Currency__c = Label.Default_Currency;
        insert cr;
        
        Cash_Detail__c cd =new Cash_Detail__c();
        cd.Amount_Paid__c = 10;
        cd.Cash_Receipt__c = cr.Id;
        cd.Invoice__c = inv.Id;
        cd.Deposit__c = dep1.Id;
        cd.Payment_Mode__c = 'Cash';
        cd.Remarks__c = 'Testing';
        insert cd;
        
        cd.Invoice__c = null;
        cd.Deposit__c = null;
        update cd;
        
        cd.Invoice__c = inv.Id;
        cd.Deposit__c = dep1.Id;
        update cd;
         
        delete cd;
        Test.stopTest();
    }
}