@isTest()
Class TestPopulateBaseRentRsController{
    Static TestMethod Void Test(){
        
    
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
        lu.Lease_Start_Date__c = System.Today()+2;
        lu.Lease_End_Date__c = System.Today()+365;
        insert lu; 
        
        Lease_Charges__c lc0 = new Lease_Charges__c();
        lc0.Name = 'TestRent';
        lc0.Active__c = true;
        lc0.Start_Date__c = system.today();
        lc0.End_Date__c = system.today().addYears(1);
        lc0.Lease_Unit__c = lu.Id;
        lc0.Billing_Frequency__c='Monthly';
        lc0.Billing_Days__c = '5';
        lc0.Frequency__c='Monthly';
        lc0.Type__c='By Area';
        lc0.Generate_Rent_Schedule__c = true;
        lc0.Charge_Rate__c = 5;
        lc0.Charge_Type__c = 'Advance Rental';
        lc0.Currency_Code__c =label.Default_Currency;
        insert lc0;
        Utility.firstRun = true;
        
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'TestCharge';
        lc2.Active__c = true;
        lc2.Start_Date__c = system.today();
        lc2.End_Date__c = system.today().addYears(1);
        lc2.Lease_Unit__c = lu.Id;
        lc2.Billing_Frequency__c='Monthly';
        lc2.Frequency__c='Quarterly';
        lc2.Billing_Days__c = '5';
        lc2.Type__c='By Area';
        lc2.Generate_Rent_Schedule__c = true;
        lc2.Charge_Rate__c = 5;
        lc2.Due_Month_Formula__c = '-1';
        lc2.Currency_Code__c = label.Default_Currency;
        insert lc2;
        
        lc2.Base_Charge_Type__c = 'Advance Rental';
        update lc2;
        
		Test.startTest();
        PopulateBaseRentRsController.pplBaseRent(lc2.Id,'Advance Rental');
		Test.stopTest();
    }
    
    Static TestMethod Void Test1(){
        
    
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
        lu.Lease_Start_Date__c = System.Today()+2;
        lu.Lease_End_Date__c = System.Today()+365;
        insert lu; 
        
        Lease_Charges__c lc0 = new Lease_Charges__c();
        lc0.Name = 'TestRent';
        lc0.Active__c = true;
        lc0.Start_Date__c = system.today();
        lc0.End_Date__c = system.today().addYears(1);
        lc0.Lease_Unit__c = lu.Id;
        lc0.Billing_Frequency__c='Monthly';
        lc0.Billing_Days__c = '5';
        lc0.Frequency__c='Monthly';
        lc0.Type__c='By Area';
        lc0.Generate_Rent_Schedule__c = true;
        lc0.Charge_Rate__c = 5;
        lc0.Charge_Type__c = 'Advance Rental';
        lc0.Currency_Code__c =label.Default_Currency;
        insert lc0;
        Utility.firstRun = true;
        
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'TestCharge';
        lc2.Active__c = true;
        lc2.Start_Date__c = system.today();
        lc2.End_Date__c = system.today().addYears(1);
        lc2.Lease_Unit__c = lu.Id;
        lc2.Billing_Frequency__c='Monthly';
        lc2.Frequency__c='Quarterly';
        lc2.Billing_Days__c = '5';
        lc2.Type__c='By Area';
        lc2.Generate_Rent_Schedule__c = true;
        lc2.Charge_Rate__c = 5;
        lc2.Due_Month_Formula__c = '-1';
        lc2.Currency_Code__c = label.Default_Currency;
        lc2.Billing_Terms__c = 'Prorate';
        lc2.Charge_Start_Day__c = '15';
        insert lc2;
        
        lc2.Base_Charge_Type__c = 'Advance Rental';
        update lc2;
        Test.startTest();
        PopulateBaseRentRsController.pplBaseRent(lc2.Id,'Advance Rental');
		Test.stopTest();
    }
}