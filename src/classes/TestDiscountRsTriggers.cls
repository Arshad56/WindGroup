@isTest
Class TestDiscountRsTriggers{
    static TestMethod void Test(){
        
        
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
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c = system.today().addYears(1);
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
        lc.Charge_Type__c = 'A&P';
        lc.Charge_Rate__c = 500;
        insert lc;
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'TestCharge Discount';
        lc1.Active__c = true;
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Billing_Frequency__c='Monthly';
        lc1.Type__c='By Percent';
        lc1.Commercial_Tax_Apply__c = true;
        lc1.Charge_Type__c = 'Discount';
        lc1.charge_Rate__c = 500;
        lc1.parent_Lease_Charge__c = lc.Id;
        insert lc1;
        
        Test.startTest();
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Approved__c = false;
        rs.Billing_Date__c = system.today();
        rs.Amount__c = 100;
        rs.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name=:label.RentScheduleRentRecordType][0].Id;
        insert rs;
        
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.parent_Rent_Schedule__c = rs.Id;
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'In-Tenancy';
        rs1.Lease_Charge__c = lc1.Id;
        rs1.Start_Date__c = system.today();
        rs1.End_Date__c = system.today().addMonths(1);
        rs1.Approved__c = false;
        rs1.Billing_Date__c = system.today();
        rs1.Amount__c = 100;
        rs1.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name='Discount'][0].Id;
        insert rs1;
        
        rs.Amount__c = rs.Amount__c + 100;
        update rs;        
        
        update rs1;
        Test.stopTest();
    }    
}