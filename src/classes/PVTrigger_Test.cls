@isTest
class PVTrigger_Test {
	static Payment_Voucher__c pv;
	static Payment_Voucher__c pv1;
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
        
		Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;

        Property__c prop = new Property__c();
        prop.Name = 'TestTenant';
        prop.short_code__c='TT';
        prop.Cash_Receipt_Index__c = 0001;
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addMonths(3);
        insert unt;

        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 2;
        ls.Lease_Tenure_Days__c = '0';
        ls.Lease_Status__c = 'New';
        ls.GTO_Billed__c = 'By Lease Unit';
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu.Lease_Unit_Status__c = 'New';
        lu.Unit__c = unt.Id;
        insert lu;
        
        Deposit__c dep = new Deposit__c();
        dep.Lease__c = ls.Id;
        dep.Lease_Unit__c = lu.Id;
        dep.Status__c = 'Paid';
        dep.Name = 'Test Deposit';
        dep.Amount_Paid__c = 1000;
        dep.Currency_Code__c = 'USD';
        insert dep;
        
        pv = new Payment_Voucher__c(); 
        pv.Name = 'TEST PV';
        pv.Currency_Code__c = 'MMK';
        pv.Exchange_Rate__c = 1;
        pv.Lease__c = ls.Id;
        pv.Deposit__c = dep.Id;
        pv.Status__c = 'New';
        pv.Amount__c = -1000000;
        pv.Refunded_Amount__c = -10;
        pv.Refund_Mode__c = 'Offset Invoice';
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        insert rentRoll; 
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Currency_Code__c = label.Default_Currency;
        insert inv;
        
        pv1 = new Payment_Voucher__c(); 
        pv1.Name = 'TEST PV1';
        pv1.Currency_Code__c = 'MMK';
        pv1.Exchange_Rate__c = 1.2345;
        pv1.Lease__c = ls.Id;
        pv1.Invoice__c = inv.Id;
        pv1.Status__c = 'New';
        pv1.Amount__c = -1000;
        pv1.Refunded_Amount__c = 0.0;
        pv1.Refund_Mode__c = 'Cash';
        
	}
	static TestMethod void Test(){
        init();
        Test.startTest();
        
        insert pv;
        
		insert pv1;
		checkRecursive.makeRunTrue();
        update pv;

        Test.stopTest();
    }
}