@isTest()
Class TestRelinkRentSchedulesController{
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
        
        Electric_Meter__c em1 = new Electric_Meter__c();
        em1.Meter_No__c = 'M1';
        em1.Unit__c = unt.Id;
        em1.Meter_Type__c = 'Gov Meter';
        em1.Status__c = 'InActive';
        em1.Start_Date__c = System.today();
        em1.End_Date__c = System.today();
        insert em1;
        
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Billing_Days__c = '31';
        lc.Frequency__c='One Time';
        lc.Type__c='By Area';
        lc.Generate_Rent_Schedule__c = true;
        lc.Charge_Rate__c = 5;
        lc.Charge_Type__c = 'Gov Meter';
        lc.Base_Charge_Type__c = 'Advance Rental';
        lc.Due_Month_Formula__c = '-1';
        lc.Currency_Code__c = label.Default_Currency;
        lc.Charge_Start_Day__c = '1';
        lc.Billing_Terms__c = 'Prorate';
        insert lc;
        
        List<Rent_Schedules__c> rsList = [Select id from Rent_Schedules__c where Lease_Charge__c=:lc.Id];
        for(Rent_Schedules__c rs:rsList){
            rs.Electric_Meter_Number__c = 'M1';
        }
        update rsList;
        
        Apexpages.currentPage().getParameters().put('Id',em1.Id);
        Test.startTest();
        RelinkRentSchedulesController rrs = new RelinkRentSchedulesController();
        rrs.elecMtrUIDt.Start_Date__c = system.today();
        rrs.elecMtrUIDt.End_Date__c = system.today().addDays(30);
        rrs.save();
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
        
        Electric_Meter__c em1 = new Electric_Meter__c();
        em1.Meter_No__c = 'M1';
        em1.Unit__c = unt.Id;
        em1.Meter_Type__c = 'Gov Meter';
        em1.Status__c = 'Active';
        em1.Start_Date__c = System.today();
        em1.End_Date__c = System.today();
        insert em1;
        
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Billing_Days__c = '31';
        lc.Frequency__c='One Time';
        lc.Type__c='By Area';
        lc.Generate_Rent_Schedule__c = true;
        lc.Charge_Rate__c = 5;
        lc.Charge_Type__c = 'Gov Meter';
        lc.Base_Charge_Type__c = 'Advance Rental';
        lc.Due_Month_Formula__c = '-1';
        lc.Currency_Code__c = label.Default_Currency;
        lc.Charge_Start_Day__c = '1';
        lc.Billing_Terms__c = 'Prorate';
        insert lc;
        
        /*List<Rent_Schedules__c> rsList = [Select id from Rent_Schedules__c where Lease_Charge__c=:lc.Id];
        for(Rent_Schedules__c rs:rsList){
            rs.Electric_Meter_Number__c = 'M1';
        }
        update rsList;*/
        
        Apexpages.currentPage().getParameters().put('Id',em1.Id);
        Test.startTest();
        RelinkRentSchedulesController rrs = new RelinkRentSchedulesController();        
        rrs.getStatus();
        rrs.elecMeter.Meter_No__c = 'M2';
        rrs.elecMtrUIDt.Start_Date__c = system.today();
        rrs.elecMtrUIDt.End_Date__c = system.today().addDays(30);
        rrs.save();
        
        RelinkRentSchedulesController rrs1 = new RelinkRentSchedulesController();        
        rrs1.elecMeter.Meter_No__c = 'M1';
        rrs1.elecMtrUIDt.Start_Date__c = system.today();
        rrs1.elecMtrUIDt.End_Date__c = system.today().addDays(30);
        rrs1.save();
        
        List<Rent_Schedules__c> rsList = [Select id from Rent_Schedules__c where Lease_Charge__c=:lc.Id];
        for(Rent_Schedules__c rs:rsList){
            rs.Electric_Meter_Number__c = 'Test';
        }
        update rsList;
        
        RelinkRentSchedulesController rrs2 = new RelinkRentSchedulesController();        
        rrs2.elecMeter.Meter_No__c = 'M1';
        rrs2.elecMtrUIDt.Start_Date__c = system.today();
        rrs2.elecMtrUIDt.End_Date__c = system.today().addDays(30);
        rrs2.save();
        Test.stopTest();
    }
}