@isTest(seeAllData=false)
public with sharing class GenerateCRandCD_Test {
	static Invoice__c inv;
	static Property__c prop;
    static void init(){
    	prop = new Property__c(); 
        prop.Name = 'TestProperty';
        prop.Short_Code__c = 'top';
        insert prop;
        
        Bank_Information__c bi1 = new Bank_Information__c();
        bi1.Currency_Code__c = label.Default_Currency;
        bi1.Property__c = prop.Id;
        bi1.Account_No__c ='accNo11';
        insert bi1;
        
        
        Bank_Information__c bi2 = new Bank_Information__c();
        bi2.Currency_Code__c = label.Base_Foreign_Currency;
        bi2.Property__c = prop.Id;
        bi1.Account_No__c ='accNo11';
        insert bi2;
        
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
        inv.Name = 'invoice11';
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 1000;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        insert ili;

    }
    static TestMethod void Test1(){
    	init();
    	Test.startTest();
    	
    	Quick_Pay_Info__c qp = new Quick_Pay_Info__c();
    	qp.Reference01__c = 'ref 01';
    	qp.Reference03__c = 'topRI000001';
    	qp.Reference02__c = prop.Short_Code__c;
    	qp.Account_No__c ='accNo11';
    	qp.CreditAmount__c = 100;
    	qp.ValueDate__c ='20170224';
    	qp.Currency_Code__c = label.Default_Currency;
    	insert qp;
    	
    	Test.stopTest();
    }
    static TestMethod void Test2(){
    	init();
    	Test.startTest();
    	
    	Quick_Pay_Info__c qp1 = new Quick_Pay_Info__c();
    	qp1.Reference03__c = '';
    	qp1.Reference02__c = '';
    	qp1.Account_No__c ='';
    	insert qp1;
    	Test.stopTest();
    }
    static TestMethod void Test3(){
    	init();
    	Test.startTest();
    	
    	Quick_Pay_Info__c qp2 = new Quick_Pay_Info__c();
    	qp2.Reference01__c = 'ref 01';
    	qp2.Reference03__c = 'abcd';
    	qp2.Reference02__c = 'erf';
    	qp2.Account_No__c ='xyz';
    	insert qp2;
    	Test.stopTest();
    }
    static TestMethod void Test4(){
    	init();
    	Test.startTest(); 
    	
    	Quick_Pay_Info__c qp3 = new Quick_Pay_Info__c();
    	qp3.Reference01__c = 'ref 01';
    	qp3.Reference03__c = inv.name;
    	qp3.Reference02__c = prop.Short_Code__c;
    	qp3.Account_No__c ='accNo11';
    	qp3.CreditAmount__c = 100000;
    	qp3.Currency_Code__c = label.Default_Currency;
    	insert qp3;
    	Test.stopTest();
    }
    
}