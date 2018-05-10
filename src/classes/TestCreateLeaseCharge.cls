@isTest
public class TestCreateLeaseCharge{
    static testMethod void Test(){
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
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Monthly Rate - L';
        insert unt;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c;
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        insert lp;
        
        Applicable_Charges__c ac = new Applicable_Charges__c();
        ac.Name = 'MEPE (CT Meter)';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Type__c = 'Gov Meter';
        ac.Property__c = prop.Id;
        ac.Charge_Rate__c = 125; 
        ac.Currency_Code__c  = label.Default_Currency;
        ac.Type__c = 'Meter Units';
        ac.Active__c = true;
        ac.Charge_Method__c = 'Monthly Rate - L';
        insert ac;
        
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
        lu.Lease_Start_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.End_Date__c;
        insert lu;
    }
    
    static testMethod void Test1(){
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
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Daily Rate';
        insert unt;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c;
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        insert lp;
        
        Applicable_Charges__c ac = new Applicable_Charges__c();
        ac.Name = 'MEPE (CT Meter)';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Type__c = 'Gov Meter';
        ac.Property__c = prop.Id;
        ac.Charge_Rate__c = 125; 
        ac.Currency_Code__c  = label.Default_Currency;
        ac.Type__c = 'Meter Units';
        ac.Active__c = true;
        ac.Charge_Method__c = 'Daily Rate';
        insert ac;
        
        Applicable_Charges__c ac1 = new Applicable_Charges__c();
        ac1.Name = 'MEPE (CT Meter)';
        ac1.Billing_Terms__c = 'Prorate';
        ac1.Charge_Type__c = 'Gov Meter';
        ac1.Property__c = prop.Id;
        ac1.Charge_Rate__c = 125; 
        ac1.Currency_Code__c  = label.Default_Currency;
        ac1.Type__c = 'Meter Units';
        ac1.Active__c = true;
        ac1.Charge_Method__c = 'Transaction Rate';
        insert ac1;
        
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
        lu.Lease_Start_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.End_Date__c;
        insert lu;
    }
    static testMethod void Test2(){
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
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Monthly Rate - CL;';
        insert unt;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c;
        lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),lp.Start_Date__c.month(),Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
        for(Date dts=lp.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        insert lp;
        
        Applicable_Charges__c ac = new Applicable_Charges__c();
        ac.Name = 'MEPE (CT Meter)';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Type__c = 'Advance REntal';
        ac.Property__c = prop.Id;
        ac.Charge_Rate__c = 125; 
        ac.Currency_Code__c  = label.Default_Currency;
        ac.Type__c = 'Meter Units';
        ac.Active__c = true;
        ac.Charge_Method__c = 'Monthly Rate - CL';
        insert ac;
        
        Applicable_Charges__c ac1 = new Applicable_Charges__c();
        ac1.Name = 'MEPE (CT Meter)';
        ac1.Billing_Terms__c = 'Prorate';
        ac1.Charge_Type__c = 'Advance REntal';
        ac1.Property__c = prop.Id;
        ac1.Charge_Rate__c = 125; 
        ac1.Currency_Code__c  = label.Default_Currency;
        ac1.Type__c = 'Meter Units';
        ac1.Active__c = true;
        ac1.Charge_Method__c = 'Transaction Rate';
        insert ac1;
        
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
        lu.Lease_Start_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.End_Date__c;
        insert lu;
    }
}