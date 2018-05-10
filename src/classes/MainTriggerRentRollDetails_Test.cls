@isTest(seeAllData=false)
public with sharing class MainTriggerRentRollDetails_Test {
    static Property__c prop;
    static Lease_Unit__c lu;
    static Rent_Roll_Detail__c rrd1;
    static Rent_Schedules__c rs;
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
        lc1.Type__c='By Area';
        lc1.charge_Rate__c = 5;
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
        checkRecursive.runAlready();
        rrd1.Voided__c = true;
        update rrd1;
        checkRecursive.runAlready();
        delete rrd1;
        Test.stopTest();
    }
    static testMethod void runCounterSecond() {
        Test.startTest();
        init();
        checkRecursive.runAlready();
        rrd1.Voided__c = true;
        update rrd1;
        checkRecursive.runAlready();
        rs.Rent_Roll_Detail__c = rrd1.Id;
        update rs;
        checkRecursive.runAlready();
        update rrd1;
        Test.stopTest();
    }
}