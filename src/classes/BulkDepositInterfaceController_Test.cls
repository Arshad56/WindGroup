@isTest(seeAllData=false)
public with sharing class BulkDepositInterfaceController_Test {
    static Property__c prop;
	static Lease_Unit__c lu;
	static Rent_Roll_Detail__c rrd1;
	static Rent_Schedules__c rs;
	static BulkDepositInterfaceController bdi;
	static void init(){
		prop = new Property__c();
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
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today()-1;
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        lc.Charge_Type__c = 'Advance Rental';
        //lc.Currency_Code__c = label.Base_Foreign_Currency;
        insert lc;
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='By Area';
        lc1.charge_Rate__c = 5;
        lc1.Charge_Type__c = 'Advance Rental';
        //lc1.Currency_Code__c = 'MMK';
        insert lc1;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'In-Tenancy';
        rs1.Lease_Charge__c = lc.Id;
        rs1.Start_Date__c = system.today();
        rs1.End_Date__c = system.today().addMonths(1);
        rs1.Rent_Roll__c = rentRoll.Id;
        rs1.Approved__c = true;
        insert rs1;
        
        Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = 'Pending';
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        insert rrd;                
        
        rrd1 = new Rent_Roll_Detail__c();
        rrd1.Unit__c = rs1.Unit__c;
        rrd1.Status__c = 'Pending';
        rrd1.Lease_Charge__c = rs1.Lease_Charge__c;
        rrd1.Start_Date__c = rs1.Start_Date__c;
        rrd1.End_Date__c = rs1.End_Date__c;
        rrd1.Rent_Roll__c = rs1.Rent_Roll__c;
        rrd1.Approved__c = rs1.Approved__c;
        rrd1.Comments__c = 'Testing';
        insert rrd1;
	}
	
    static testMethod void runCounterName() {
    	Test.startTest();
    	init();
    	PageReference pref = Page.BulkDepositInterface;
	    pref.getParameters().put('selectedLeaseUnits',lu.id);
	    pref.getParameters().put('toAddRow','1');
	    pref.getParameters().put('toDelRow','2');
	    Test.setCurrentPage(pref);
	    
	    ApexPages.StandardController con = new ApexPages.StandardController(lu);
	    bdi = new BulkDepositInterfaceController();
        bdi.leaseUnitWrap[0].dep.Deposit_Formula_Type__c = 'By Base Rent';
        bdi.leaseUnitWrap[0].dep.Currency_Code__c = label.Base_Foreign_Currency;
        bdi.leaseUnitWrap[0].dep.Deposit_Type__c = 'Fit-out';
        bdi.leaseUnitWrap[0].depositAmount = 10;
        
        bdi.addRow();
        bdi.delRow();
        for(BulkDepositInterfaceController.BulkLeaseUnitWrap wl : bdi.leaseUnitWrap){
        	wl.dep.Deposit_Formula_Type__c = 'By Base Rent';
	        wl.dep.Currency_Code__c = label.Base_Foreign_Currency;
	        wl.lcCurrencyCode = label.Base_Foreign_Currency;
	        wl.dep.Deposit_Type__c = 'Fit-out';
	        wl.depositAmount = 10;
	        wl.depositRate = 10;
	        wl.noOfMonths = 10;
        }
        bdi.save();
        bdi.generateDepositPDF();
        Test.stopTest();
    }
}