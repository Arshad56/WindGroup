@isTest(seeAllData=false)
public with sharing class MainDepositTrigger_Test {
	static Property__c prop;
	static Lease_Unit__c lu;
	static Loi_Unit__c loiU;
	static Deposit__c dep;
	static Deposit__c dep1;
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
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
        LOI__c loi = new LOI__c();
        loi.Tenant__c = acc.Id;
        loi.Property__c = prop.Id;
        insert loi;
        
        loiU = new LOI_Unit__c();
        loiU.LOI_Agreement_No__c = loi.Id;
        loiU.Unit__c = unt.Id;
        insert loiU;
        
        dep = new Deposit__c();
		dep.name='--System Generated--';
		dep.Lease__c = ls.id;
		dep.Lease_Unit__c  = lu.id;  
		
		dep1 = new Deposit__c();
		dep1.name='--System Generated--';
		dep1.Lease__c = ls.id;
		dep1.Lease_Unit__c  = lu.id; 
		insert dep1;   
		
		dep1 = new Deposit__c();
		dep1.name='--System Generated--';
		dep1.Lease__c = ls.id;
		dep1.Lease_Unit__c  = lu.id; 
		insert dep1;  
	}
    static testMethod void runCounterOnNULL() {
    	Test.startTest();
    	init();
    	insert dep;
		Test.stopTest();
    }
    
    static testMethod void runCounterOnInit() {
    	init();
    	prop.Deposit_Refund_Index__c = 1;
        update prop;
        checkRecursive.runAlready();
    	Test.startTest();
        dep1.Refund_Status__c = 'Approved';
    	update dep1;
		Test.stopTest();
    }
    static testMethod void runDPrefund() {
    	
    	init();
    	insert dep;
    	Test.startTest();
    	checkRecursive.makeRunTrue();
    	dep.Refund_Status__c = 'Approved';
    	update dep;
		Test.stopTest();
    }
    
    static testMethod void runDepLOI1() {
    	init();
    	
    	prop.Deposit_Refund_Index__c = 1;
        update prop;
        checkRecursive.runAlready();
    	Test.startTest();
    	
    	dep1 = new Deposit__c();
		dep1.name='--System Generated--';
		dep1.LOI__c = loiU.LOI_Agreement_No__c;
		dep1.LOI_Unit__c  = loiU.Id; 
		insert dep1;  

        dep1.Refund_Status__c = 'Approved';
    	update dep1;
		Test.stopTest();
    }
    static testMethod void runDepLOI2() {
    	
    	init();
    	dep.Lease__c = null;
		dep.Lease_Unit__c  = null; 
		dep.LOI__c = loiU.LOI_Agreement_No__c;
		dep.LOI_Unit__c  = loiU.Id; 
    	insert dep;
    	Test.startTest();
    	checkRecursive.makeRunTrue();
    	dep.Refund_Status__c = 'Approved';
    	update dep;
		Test.stopTest();
    }
    static testMethod void runDepLOI3() {
    	Test.startTest();
    	init();
    	dep.Lease__c = null;
		dep.Lease_Unit__c  = null; 
		dep.LOI__c = loiU.LOI_Agreement_No__c;
		dep.LOI_Unit__c  = loiU.Id; 
    	insert dep;
		Test.stopTest();
    }
    
}