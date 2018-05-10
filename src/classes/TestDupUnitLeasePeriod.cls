@isTest
Class TestDupUnitLeasePeriod{
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
        
        Lease_Unit__c lu1 = new Lease_Unit__c();
        lu1.Lease_Agreement_No__c = ls.Id;
        lu1.Unit__c = unt.Id;
        lu1.Lease_Start_Date__c = system.today();
        lu1.Lease_End_Date__c = system.today().addYears(1);
        try{
            insert lu1;
        }catch(exception e){}
    }
}