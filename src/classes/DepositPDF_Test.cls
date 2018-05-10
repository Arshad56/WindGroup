@isTest(seeAllData=false)
public with sharing class DepositPDF_Test {
    static Property__c prop;
	static Lease_Unit__c lu;
	static Deposit__c dep;
	static Deposit__c dep1;
	static Lease__c ls;
	static void init(){
		prop = new Property__c();
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
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        cr.Name = 'Test';
        cr.Property__c = prop.Id;
        cr.Tenant__c = acc.Id;
        cr.Remarks__c = 'Testing';
        cr.Payment_Mode__c = 'Cash';
        cr.Payment_Date__c = system.today();
        cr.Payment_Currency__c = label.Default_Currency;
        insert cr;
        Apexpages.currentPage().getParameters().put('Id',cr.Id);
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        insert unt;
        
        ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
         Bank_Information__c bi1 = new Bank_Information__c();
        bi1.Currency_Code__c = label.Default_Currency;
        bi1.Property__c = prop.Id;
        insert bi1;
        
        Bank_Information__c bi2 = new Bank_Information__c();
        bi2.Currency_Code__c = label.Base_Foreign_Currency;
        bi2.Property__c = prop.Id;
        insert bi2;
        
        dep = new Deposit__c();
		dep.name='--System Generated--';
		dep.Lease__c = ls.id;
		dep.Lease_Unit__c  = lu.id;  
		//dep.Currency_Code__c = label.Base_Foreign_Currency;
		
		dep1 = new Deposit__c();
		dep1.name='--System Generated--';
		dep1.Lease__c = ls.id;
		dep1.Lease_Unit__c  = lu.id; 
		dep1.Deposit_Amount__c = 500;
		dep1.Currency_Code__c = label.Base_Foreign_Currency;
		insert dep1;   
	}
    static testMethod void runPDFPage() {
    	Test.startTest();
    	init();
    	PageReference pref = Page.DepositPDF;
	    pref.getParameters().put('depositId',dep1.id);
	    Test.setCurrentPage(pref);
	    
	    ApexPages.StandardController con = new ApexPages.StandardController(dep1);
	    DepositPDFController dp = new DepositPDFController();
		Test.stopTest();
    }
    static testMethod void runPDFPage1() {
    	Test.startTest();
    	init();
    	insert dep;
    	PageReference pref = Page.DepositPDF;
	    pref.getParameters().put('depositId',dep.id);
	    Test.setCurrentPage(pref);
	    
	    ApexPages.StandardController con = new ApexPages.StandardController(dep);
	    DepositPDFController dp = new DepositPDFController();
		Test.stopTest();
    }
    /*static testMethod void runPDFPage2() {
    	Test.startTest();
    	init();
    	PageReference pref = Page.DepositPDF;
	    pref.getParameters().put('depositId',dep.id);
	    Test.setCurrentPage(pref);
	    
	    ApexPages.StandardController con = new ApexPages.StandardController(dep1);
	    DepositPDFController dp = new DepositPDFController();
		Test.stopTest();
    }*/
    static testMethod void runPDFPage3() {
    	Test.startTest();
    	init();
    	PageReference pref = Page.DepositPDF;
	    pref.getParameters().put('depositId',dep1.Id);
	    Test.setCurrentPage(pref);
	    
	    ApexPages.StandardController con = new ApexPages.StandardController(dep1);
	    DepositPDFController dp = new DepositPDFController();
		Test.stopTest();
    }
}