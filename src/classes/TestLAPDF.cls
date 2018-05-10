@isTest
Class TestLAPDF{
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
        
        List<Electric_Meter__c> elMetList = new List<Electric_Meter__c>();
        
        Electric_Meter__c em1 = new Electric_Meter__c();
        em1.Meter_No__c = 'M1';
        em1.Unit__c = unt.Id;
        em1.Meter_Type__c = 'Gov Meter';
        elMetList.add(em1);
        
        Electric_Meter__c em2 = new Electric_Meter__c();
        em2.Meter_No__c = 'M2';
        em2.Unit__c = unt.Id;
        em2.Meter_Type__c = 'Sub Meter';
        elMetList.add(em2);
        
        Electric_Meter__c em3 = new Electric_Meter__c();
        em3.Meter_No__c = 'M3';
        em3.Unit__c = unt.Id;
        em3.Meter_Type__c = 'Generator';
        elMetList.add(em3);
        
        insert elMetList;
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc0 = new Lease_Charges__c();
        lc0.Name = 'TestCharge';
        lc0.Active__c = true;
        lc0.Start_Date__c = system.today();
        lc0.End_Date__c = system.today().addYears(1);
        lc0.Lease_Unit__c = lu.Id;
        lc0.Billing_Frequency__c='Monthly';
        lc0.Billing_Days__c = '5';
        lc0.Frequency__c='One Time';
        lc0.Type__c='By Area';
        lc0.Charge_Rate__c = 5;
        lc0.Charge_Type__c = 'GTO Rent';
        lc0.Base_Charge_Type__c = 'Advance Rental';
        lc0.Due_Month_Formula__c = '-1';
        lc0.Currency_Code__c = label.Base_Foreign_Currency;
        lcList.add(lc0);
        
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
        lc.Charge_Rate__c = 5;
        lc.Charge_Type__c = 'Generator';
        lc.Base_Charge_Type__c = 'Advance Rental';
        lc.Due_Month_Formula__c = '-1';
        lc.Currency_Code__c = label.Default_Currency;
        lcList.add(lc);
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'TestCharge';
        lc1.Active__c = true;
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Billing_Frequency__c='Monthly';
        lc1.Frequency__c='Monthly';
        lc1.Billing_Days__c = '31';
        lc1.Type__c='By Area';
        lc1.Charge_Rate__c = 5;
        lc1.Charge_Type__c = 'Generator';
        lc1.Multiple_Rental_Schedule__c = true;
        lc1.Billing_Terms__c = 'Non-prorate';
        lc1.Due_Month_Formula__c = '-1';
        lc1.Currency_Code__c = label.Base_Foreign_Currency;
        lcList.add(lc1);
        
        
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'TestCharge';
        lc2.Active__c = true;
        lc2.Start_Date__c = system.today();
        lc2.End_Date__c = system.today().addYears(1);
        lc2.Lease_Unit__c = lu.Id;
        lc2.Billing_Frequency__c='Monthly';
        lc2.Frequency__c='Quarterly';
        lc2.Billing_Days__c = '31';
        lc2.Type__c='Meter Units';
        lc2.Charge_Rate__c = 5;
        lc2.Charge_Type__c = 'Gov Meter';
        lc2.Billing_Terms__c = 'Non-prorate';
        lc2.Base_Charge_Type__c = 'Advance Rental';
        lc2.Due_Month_Formula__c = '-1';
        lc2.Currency_Code__c = label.Base_Foreign_Currency;
        lcList.add(lc2);
        
        Lease_Charges__c lc3 = new Lease_Charges__c();
        lc3.Name = 'TestCharge';
        lc3.Active__c = true;
        lc3.Start_Date__c = system.today();
        lc3.End_Date__c = system.today().addYears(1);
        lc3.Lease_Unit__c = lu.Id;
        lc3.Billing_Frequency__c='Monthly';
        lc3.Frequency__c='Yearly';
        lc3.Billing_Days__c = '31';
        lc3.Type__c='Meter Units';
        lc3.Charge_Rate__c = 5;
        lc3.Charge_Type__c = 'Sub Meter';
        lc3.Base_Charge_Type__c = 'Advance Rental';
        lc3.Due_Month_Formula__c = '-1';
        lc3.Billing_Terms__c = 'Non-prorate';
        lc3.Currency_Code__c = label.Default_Currency;
        lcList.add(lc3);
        
        Lease_Charges__c lc5 = new Lease_Charges__c();
        lc5.Name = 'TestCharge';
        lc5.Active__c = true;
        lc5.Start_Date__c = system.today();
        lc5.End_Date__c = system.today().addYears(1);
        lc5.Lease_Unit__c = lu.Id;
        lc5.Billing_Frequency__c='Monthly';
        lc5.Billing_Days__c = '31';
        lc5.Frequency__c='One Time';
        lc5.Type__c='Meter Units';
        lc5.Charge_Rate__c = 5;
        lc5.Charge_Type__c = 'Generator';
        lc5.Base_Charge_Type__c = 'Advance Rental';
        lc5.Due_Month_Formula__c = '-1';
        lc5.Currency_Code__c = label.Default_Currency;
        lcList.add(lc5);
        
        Lease_Charges__c lc6 = new Lease_Charges__c();
        lc6.Name = 'TestRent';
        lc6.Active__c = true;
        lc6.Start_Date__c = system.today();
        lc6.End_Date__c = system.today().addYears(1);
        lc6.Lease_Unit__c = lu.Id;
        lc6.Billing_Frequency__c='Monthly';
        lc6.Billing_Days__c = '31';
        lc6.Frequency__c='Monthly';
        lc6.Type__c='By Area';
        lc6.Charge_Rate__c = 5;
        lc6.Charge_Type__c = 'Advance Rental';
        lc6.Currency_Code__c =label.Default_Currency;
        lcList.add(lc6);
        
        Lease_Charges__c lc7 = new Lease_Charges__c();
        lc7.Name = 'TestService';
        lc7.Active__c = true;
        lc7.Start_Date__c = system.today();
        lc7.End_Date__c = system.today().addYears(1);
        lc7.Lease_Unit__c = lu.Id;
        lc7.Billing_Frequency__c='Monthly';
        lc7.Billing_Days__c = '31';
        lc7.Frequency__c='Monthly';
        lc7.Type__c='By Area';
        lc7.Charge_Rate__c = 5;
        lc7.Charge_Type__c = 'Service';
        lc7.Currency_Code__c =label.Default_Currency;
        lcList.add(lc7);
        
        Lease_Charges__c lc8 = new Lease_Charges__c();
        lc8.Name = 'F&B Service Charge';
        lc8.Active__c = true;
        lc8.Start_Date__c = system.today();
        lc8.End_Date__c = system.today().addYears(1);
        lc8.Lease_Unit__c = lu.Id;
        lc8.Billing_Frequency__c='Monthly';
        lc8.Billing_Days__c = '31';
        lc8.Frequency__c='Monthly';
        lc8.Type__c='By Area';
        lc8.Charge_Rate__c = 5;
        lc8.Charge_Type__c = 'Service';
        lc8.Currency_Code__c =label.Default_Currency;
        lcList.add(lc8);
        
        Lease_Charges__c lc9 = new Lease_Charges__c();
        lc9.Name = 'TestAnP';
        lc9.Active__c = true;
        lc9.Start_Date__c = system.today();
        lc9.End_Date__c = system.today().addYears(1);
        lc9.Lease_Unit__c = lu.Id;
        lc9.Billing_Frequency__c='Monthly';
        lc9.Billing_Days__c = '31';
        lc9.Frequency__c='Monthly';
        lc9.Type__c='By Area';
        lc9.Charge_Rate__c = 5;
        lc9.Charge_Type__c = 'A&P';
        lc9.Currency_Code__c =label.Default_Currency;
        lcList.add(lc9);
        
        Lease_Charges__c lc10 = new Lease_Charges__c();
        lc10.Name = 'TestGas';
        lc10.Active__c = true;
        lc10.Start_Date__c = system.today();
        lc10.End_Date__c = system.today().addYears(1);
        lc10.Lease_Unit__c = lu.Id;
        lc10.Billing_Frequency__c='Monthly';
        lc10.Billing_Days__c = '31';
        lc10.Frequency__c='Monthly';
        lc10.Type__c='By Area';
        lc10.Charge_Rate__c = 5;
        lc10.Charge_Type__c = 'Gas';
        lc10.Currency_Code__c =label.Default_Currency;
        lcList.add(lc10);
                
        insert lcList;

                
        Apexpages.CurrentPage().getParameters().put('Id',ls.Id);
        LaPDFController lpc = new LaPDFController();
        
        LAPDFGenerator.generatePDF(ls.Id);        
    }    
}