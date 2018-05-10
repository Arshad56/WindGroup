@isTest(seeAllData=true)
public with sharing class MainLeaseUnitTrigger_Test {
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
        unt.Generate_Lease_Plans__c = true;
        unt.Start_Date__c = Date.newInstance(System.today().year(),1,1);
        unt.End_Date__c = Date.newInstance(System.today().year(),12,31);
        unt.Charge_Method__c = 'Monthly Rate - L';
        insert unt;
        
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
        ac.Billing_Frequency__c ='Monthly';
        ac.Billing_Days__c ='1';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Start_Day__c = '1';
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
        lu.Lease_Start_Date__c = unt.Start_Date__c+10;
        lu.Fit_Out_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.End_Date__c.addMonths(- 2);
        LU.Update_Lease_Plans__c = true;
        insert lu;
        
        list<Lease_Plan__c> lpList= new list<Lease_Plan__c>();
        
        for(Integer i = 1; i<=12; i++){
            Lease_Plan__c lp = new Lease_Plan__c();
            lp.Unit__c = unt.Id;
            lp.Start_Date__c = Date.newInstance(unt.Start_Date__c.year(),i,1);
            lp.End_Date__c = Date.newInstance(lp.Start_Date__c.year(),i,Date.DaysInMonth(lp.Start_Date__c.Year(),lp.Start_Date__c.Month()));
            lpList.add(lp);
        }
        insert lpList;
        
        lU.Update_Lease_Plans__c = false;
        update lu;
        
        lu.Lease_End_Date__c = lu.Lease_End_Date__c.addMonths(- 5);
        lU.Update_Lease_Plans__c = true;
        update lu;
        
        lu.Lease_End_Date__c = lu.Lease_End_Date__c.addMonths(6);
        lU.Update_Lease_Plans__c = true; 
        update lu;
        
        try{
            Lease_Unit__c splitUnt = new Lease_Unit__c();
            splitUnt =  lU.clone(false, true);
            insert splitUnt;
        }catch(Exception e){}
    }
}