@isTest()
Class TestCreateLP{
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
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 12;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = System.Today();
        lu.Lease_End_Date__c = System.Today().addYears(1);
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
        
        prop.End_Year__c = ''+(system.today().year()+2);
        update prop;
    }
}