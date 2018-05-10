@isTest
Class TestCancelProcess{
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
        acc.BillingCity = 'Testity';
        acc.BillingCountry = 'Singapore';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c = system.today().addYears(2);
        insert lu;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c.addyears(2);
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp.Lease_Unit__c = lu.Id;
        insert lp;
        
        Lease_Plan__c lp1 = new Lease_Plan__c();
        lp1.Unit__c = unt.Id;
        lp1.Start_Date__c = lu.Lease_Start_Date__c- 10;
        lp1.End_Date__c = lu.Lease_End_Date__c + 10;
        for(Date dts=lp1.Start_Date__c;dts<=lp1.End_Date__c; dts = dts+1){
            lp1.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp1.Lease_Unit__c = lu.Id;
        insert lp1;
        
        Lease_Plan__c lp2 = new Lease_Plan__c();
        lp2.Unit__c = unt.Id;
        lp2.Start_Date__c = lu.Lease_Start_Date__c + 1;
        lp2.End_Date__c = lu.Lease_End_Date__c;
        for(Date dts=lp2.Start_Date__c;dts<=lp2.End_Date__c; dts = dts+1){
            lp2.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp2.Lease_Unit__c = lu.Id;
        insert lp2;
        
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        lc.Lease_Plan__c = lp.Id;
        lcList.add(lc);                
        insert lcList;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        insert rs;
        
        //CancelLeaseController cl0 = new CancelLeaseController();
       // cl0.checkSysAdmin();
        
        Apexpages.CurrentPage().getParameters().put('Id',ls.Id);
        CancelLeaseController cl = new CancelLeaseController();
        cl.checkSysAdmin();
        
        cl.bypass = false;
        cl.save();
        cl.lease.Cancel_Reason__c = 'Test Cancel';
        cl.save();
        cl.proceed();
    }
    
    static TestMethod void Test1(){
        
        
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
        acc.BillingCity = 'Testity';
        acc.BillingCountry = 'Singapore';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c = system.today().addYears(2);
        insert lu;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c.addyears(2);
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp.Lease_Unit__c = lu.Id;
        insert lp;
        
        Lease_Plan__c lp1 = new Lease_Plan__c();
        lp1.Unit__c = unt.Id;
        lp1.Start_Date__c = unt.Start_Date__c;
        lp1.End_Date__c = Date.newInstance(lp1.Start_Date__c.year(),lp1.Start_Date__c.month(),Date.DaysInMonth(lp1.Start_Date__c.Year(),lp1.Start_Date__c.Month()));
        for(Date dts=lp1.Start_Date__c;dts<=lp1.End_Date__c; dts = dts+1){
            lp1.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp1.Lease_Unit__c = lu.Id;
        insert lp1;
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        lc.Lease_Plan__c = lp.Id;
        lcList.add(lc);                
        insert lcList;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        insert rs;
        
        Apexpages.CurrentPage().getParameters().put('Id',lu.Id);
        CancelLeaseUnitController clu = new CancelLeaseUnitController();
        clu.checkSysAdmin();
        clu.bypass = false;
        clu.save();
        clu.lsUnt.Cancel_Reason__c = 'Test Cancel';
        clu.save();
        clu.proceed();
    }
    
    static TestMethod void Test2(){
        
        
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
        acc.BillingCity = 'Testity';
        acc.BillingCountry = 'Singapore';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today();
        lu.Lease_End_Date__c = system.today().addYears(2);
        insert lu;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c.addyears(2);
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        lp.Lease_Unit__c = lu.Id;
        insert lp;
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        lc.Lease_Plan__c = lp.Id;
        lcList.add(lc);                
        insert lcList;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        insert rs;
        
        CancelLeaseChargeController clc = new CancelLeaseChargeController();
        clc.checkSysAdmin();
        Apexpages.CurrentPage().getParameters().put('Id',lc.Id);
        clc = new CancelLeaseChargeController();
        clc.checkSysAdmin();
        clc.bypass = false;
        clc.save();
        clc.lsChg.Cancel_Reason__c = 'Test Cancel';
        clc.save();
        clc.proceed();
    }
    
}