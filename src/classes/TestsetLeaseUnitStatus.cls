@isTest()
Class TestsetLeaseUnitStatus{
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
        unt.End_Date__c = system.today().addYears(5);
        insert unt;
        
        Units__c unt1 = new Units__c();
        unt1.Property__c = prop.Id;
        unt1.Level__c = lvl.Id;
        unt1.Name = 'TestUnit1';
        unt1.Active__c = true;
        unt1.Start_Date__c = system.today();
        unt1.End_Date__c = system.today().addYears(5);
        insert unt1;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease__c ls1 = new Lease__c();
        ls1.Tenant__c = acc.Id;
        ls1.Property__c = prop.Id;
        ls1.Precedent_Lease__c = ls.Id;
        insert ls1;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = System.Today()+2;
        lu.Lease_End_Date__c = System.Today()+365;
        insert lu; 
        
        Lease_Unit__c lu01 = new Lease_Unit__c();
        lu01.Lease_Agreement_No__c = ls.Id;
        lu01.Unit__c = unt1.Id;
        lu01.Lease_Start_Date__c = System.Today()+2;
        lu01.Lease_End_Date__c = System.Today()+365;
        insert lu01;
        
        Lease_Unit__c lu1 = new Lease_Unit__c();
        lu1.Lease_Agreement_No__c = ls1.Id;
        lu1.Unit__c = unt.Id;
        lu1.Lease_Start_Date__c = lu.Lease_End_Date__c + 1;
        lu1.Lease_End_Date__c = lu1.Lease_Start_Date__c+365;
        insert lu1; 
    }
}