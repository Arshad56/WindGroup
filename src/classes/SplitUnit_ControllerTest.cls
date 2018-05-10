@isTest(seeAllData=false)
public with sharing class SplitUnit_ControllerTest {
    static Property__c prop;
    static Units__c unt;
	static Lease_Unit__c lu;
	static SplitUnit_Controller suc;
	static void init(){
		prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        unt = new Units__c();
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
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c = system.today()+11;
        insert lu;
        
	}
	
    static testMethod void splitUnitValidate() {
    	init();
    	Test.startTest();
	    	PageReference pref = Page.SplitUnit;
		    pref.getParameters().put('unitId',unt.id);
		    Test.setCurrentPage(pref);
		    
		    ApexPages.StandardController con = new ApexPages.StandardController(lu);
		    suc = new SplitUnit_Controller();
		    suc.unitOnUI.start_Date__c = unt.Start_Date__c+10;
		    suc.unitOnUI.End_Date__c = unt.End_Date__c-20;
		    suc.noOfSplit = 10;
			suc.generateSplit();
		Test.stopTest();
        
    }
    static testMethod void splitUnit() {
    	init();
    	delete lu;
    	Test.startTest();
	    	PageReference pref = Page.SplitUnit;
		    pref.getParameters().put('unitId',unt.id);
		    Test.setCurrentPage(pref);
		    
		    ApexPages.StandardController con = new ApexPages.StandardController(lu);
		    suc = new SplitUnit_Controller();
		    suc.unitOnUI.start_Date__c = unt.Start_Date__c+10;
		    suc.unitOnUI.End_Date__c = unt.End_Date__c-20;
		    suc.noOfSplit = 10;
	        suc.generateSplit();
			suc.saveSplit();
		Test.stopTest();
        
    }
}