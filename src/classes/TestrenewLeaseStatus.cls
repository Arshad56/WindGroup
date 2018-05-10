@isTest()
Class TestrenewLeaseStatus{
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
        
        Lease__c ls1 = new Lease__c();
        ls1.Tenant__c = acc.Id;
        ls1.Property__c = prop.Id;
        ls1.Precedent_Lease__c = ls.Id;
        insert ls1;
        
        ls1.Lease_Status__c = 'Expired';
        update ls1;
    }
}