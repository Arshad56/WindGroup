@IsTest()
Class TestExtension{
    Static TestMethod void Test1(){
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
        ls.Late_Payment_Interest__c = 2;
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 12;
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
        lc.Charge_Method__c ='Daily Rate';
        lc.Commercial_Tax_Apply__c = true;
        
        insert lc;
                        
        Apexpages.currentPage().getParameters().put('Id',lu.Id);
        ExtensionLUController elu1 = new ExtensionLUController();
        elu1.leaseForUI.Lease_Start_Date__c = null;
        elu1.checkDate();
        elu1.leaseForUI.Lease_Start_Date__c = lu.Lease_End_Date__c.addMonths(-1);
        elu1.checkDate();
        elu1.leaseForUI.Lease_Start_Date__c = lu.Lease_End_Date__c.addMonths(4);
        elu1.checkDate();
        elu1.leaseForUI.Lease_Start_Date__c = lu.Lease_End_Date__c.addMonths(1);
        elu1.checkDate();
    }
    
    Static TestMethod void Test2(){
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
        ls.Late_Payment_Interest__c = 2;
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 12;
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
        lc.Charge_Method__c ='Daily Rate';
        lc.Commercial_Tax_Apply__c = true;
        insert lc;
        
        LeaseExtensionController lsExt = new LeaseExtensionController();
        lsExt.leaseForUI.Lease_Start_Date__c = lu.Lease_Start_Date__c.addMonths(13);
        lsExt.extend();
        
        Apexpages.currentPage().getParameters().put('Id',ls.Id);        
        LeaseExtensionController lsExt1 = new LeaseExtensionController();
        lsExt1.leaseForUI.Lease_Start_Date__c = lu.Lease_Start_Date__c.addMonths(13);
        lsExt1.extend();
    }
}