@isTest
public with sharing class TestInvoiceRefund {
	static Invoice__c inv;
	static Invoice_Line_Item__c ili;
    static void init(){
    	List<Exchange_Rate__c> ex=new List<Exchange_Rate__c>();
        Exchange_Rate__c eRate = new Exchange_Rate__c();
        eRate.Conversion_Rate__c=200;
        eRate.Currency_Code__c= label.Base_Foreign_Currency;
        eRate.Applicable_Function__c='Operations';
        eRate.Start_Date_Time__c=system.now() ;
        ex.add(eRate);
        
        Exchange_Rate__c eRate2 = new Exchange_Rate__c();
        eRate2.Conversion_Rate__c=200;
        eRate2.Currency_Code__c='JPY';
        eRate2.Applicable_Function__c='Finance';
        eRate2.Start_Date_Time__c=system.now() ;
        ex.add(eRate2);
        insert ex;  
        
        
        
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
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='By Percent';
        lc1.charge_Rate__c = 5;
        lc1.Charge_Type__c ='A&P';
        insert lc1;
        
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
        
         inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Currency_Code__c = label.Default_Currency;
       // insert inv;
        
         ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        //ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        ili.Lease_Charge__c = lc1.Id;
        //insert ili;
	}
	static TestMethod void testInvoice(){
		init();
		
		Test.startTest();
		
		insert inv;
		ili.Invoice__c = inv.Id;
		insert ili;
		
		inv.Requested_Amount__c = 100;
		inv.Refund_Mode__c = 'Cash';
		inv.Refund_Status__c = 'Approved';
		update inv;
		
        Test.stopTest();
	}
	static TestMethod void TestRefund(){
    	init();
    	insert inv;
		ili.Invoice__c = inv.Id;
		insert ili;
		
		inv.Exchange_Rate__c = 20;
		update inv;
		
		inv.Exchange_Rate__c = 1;
		update inv;
		
		ili.Amount__c = 10;
		update ili;
		
    	Test.startTest();
		
		Apexpages.currentPage().getParameters().put('id',inv.Id);
        InvoiceRefundController irC = new InvoiceRefundController(); 
        
        irC.getPaymentModeOptions();
        irC.cancel();
        
        irC.updateInv.Requested_Amount__c = 10;
        irC.invBalance = 20;
        
        irC.generateRefund();
        
        
        Test.stopTest();
    	   
    }
}