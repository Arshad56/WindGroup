@isTest()
Class TestCalcBaseRent{
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
        ls.GTO_Billed__c = 'By Lease Unit';
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = System.Today()+2;
        lu.Lease_End_Date__c = System.Today()+365;
        insert lu; 
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Billing_Days__c = '5';
        lc.Frequency__c='One Time';
        lc.Type__c='By Area';
        lc.Generate_Rent_Schedule__c = true;
        lc.Charge_Rate__c = 5;
        lc.Charge_Type__c = 'GTO Rent';
        lc.Base_Charge_Type__c = 'Advance Rental';
        lc.Due_Month_Formula__c = '-1';
        lc.Currency_Code__c = label.Base_Foreign_Currency;
        lcList.add(lc);
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Base Rent';
        lc1.Active__c = true;
        lc1.Billing_Terms__c = 'Non-Prorate';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Billing_Frequency__c='Monthly';
        lc1.Frequency__c='Monthly';
        lc1.Billing_Days__c = '5';
        lc1.Type__c='By Area';
        lc1.Generate_Rent_Schedule__c = true;
        lc1.Charge_Rate__c = 5;
        lc1.Charge_Type__c = 'Advance Rental';
        lc1.Due_Month_Formula__c = '-1';
        lc1.Currency_Code__c = label.Base_Foreign_Currency;
        lcList.add(lc1);
        
        insert lcList;
        
        List<Rent_Schedules__c> gtoRsList = [Select id from Rent_Schedules__c where Lease_Charge__c=:lc.Id];
        if(gtoRsList.size()>0){
            update gtoRsList;
        }
        
        Rent_Schedules__c rsTest = new Rent_Schedules__c();
        rsTest.Unit__c = unt.Id;
        rsTest.Status__c = 'In-Tenancy';
        rsTest.Lease_Charge__c = lc1.Id;
        rsTest.Base_Rent_LC__c = lc1.Id;
        rsTest.Start_Date__c = system.today()+10;
        rsTest.End_Date__c = system.today().addMonths(1)-1;
        //rsTest.Rent_Roll__c = rentRoll.Id;
        rsTest.Approved__c = true;
        rsTest.Lease_Unit__c = lu.Id;
        
        Test.startTest();
        
        insert rsTest;
        
        List<Rent_Schedules__c> baseRentRsList = [Select id from Rent_Schedules__c where Lease_Charge__c=:lc1.Id];
        if(baseRentRsList.size()>0){
            for(Rent_Schedules__c rs:baseRentRsList){
                rs.Amount__c = 100;
            }
            update  baseRentRsList;
        }
        
        Test.stopTest();
    }
}