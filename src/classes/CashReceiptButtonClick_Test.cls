@isTest(seeAllData=false)
public with sharing class CashReceiptButtonClick_Test {
    static TestMethod void Test(){
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        acc.BillingCity = 'TestCity';
        acc.BillingCountry = 'Singapore';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        insert inv;
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        cr.Name = 'Test';
        cr.Property__c = prop.Id;
        cr.Tenant__c = acc.Id;
        cr.Remarks__c = 'Testing';
        cr.Payment_Mode__c = 'Cash';
        cr.Payment_Date__c = system.today();
        cr.Payment_Currency__c = label.Default_Currency;
        insert cr;
        
        Cash_Detail__c cd =new Cash_Detail__c();
        cd.Amount_Paid__c = 10;
        cd.Cash_Receipt__c = cr.Id;
        cd.Invoice__c = inv.Id;
        cd.Payment_Mode__c = 'Cash';
        cd.Remarks__c = 'Testing';
        insert cd;
        
        Test.startTest();
        CashReceiptButtonClick.voidAllCashReceipts(cr.Id,'');
        Test.stopTest();
    }
}