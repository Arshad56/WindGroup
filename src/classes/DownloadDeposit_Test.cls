@isTest(seeAllData=false)
public with sharing class DownloadDeposit_Test {
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
        
		dep1 = new Deposit__c();
		dep1.name='--System Generated--';
		dep1.Lease__c = ls.id;
		dep1.Lease_Unit__c  = lu.id; 
		dep1.Deposit_Amount__c = 500;
		dep1.Currency_Code__c = label.Base_Foreign_Currency;
		insert dep1;   
	}
    static testMethod void runPDFPage() {
    	init();
    	Test.startTest();
    	DownloadDeposit.generateFromDeposit(dep1.Id, null);
		Test.stopTest();
    }
    static testMethod void depositStatusTest() {
    	init();
    	Test.startTest();
    		dep1.Deposit_Generated__c = true;
	    	dep1.Amount_Paid__c = 100;
			update dep1;  
			DownloadDeposit.generateFromDepositTrigger(new Set<Id>{dep1.Id}, 'LOI To LA Conversion');
			DownloadDeposit.generateFromDeposit(dep1.Id,'LOI To LA Conversion');
			
		Test.stopTest();
    }
    
}