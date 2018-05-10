@isTest
Class TestDepositRefundController{
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
        unt.NLA_SQF__c = 10;
        insert unt;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        ls.Late_Payment_Interest__c = 2;
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
        lc.Charge_Type__c = 'Gov Meter';
        lc.Billing_Terms__c = 'Prorate';
        insert lc;        
        
        Deposit__c dp = new Deposit__c();
        dp.Amount_Paid_Local__c = 10;
        dp.Status__c = 'Paid';
        dp.Lease__c = ls.Id;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        dp.Currency_Code__c = 'USD';
        dp.Amount_Paid__c = 5;
        insert dp;
        
        Deposit__c dp1 = new Deposit__c();
        dp1.Amount_Paid_Local__c = 100000;
        dp1.Status__c = 'Outstanding';
        dp1.Lease__c = ls.Id;
        dp1.Lease_Unit__c = lu.Id;
        dp1.Lease_Charge__c = lc.Id;
        dp1.Payment_Due_Date__c = system.today().addDays(-2);
        dp1.Currency_Code__c = 'MMK';
        dp1.Amount_Paid__c = 500000;
        insert dp1;
        
        Apexpages.currentPage().getParameters().put('Id',dp1.Id);
        DepositRefundController dr1 = new DepositRefundController();        
        dr1.deposit.Refund_Mode__c = 'Cash';
        dr1.deposit.Requested_Amount__c = 10000;
        dr1.refund(); 
        
        Apexpages.currentPage().getParameters().put('Id',dp1.Id);
        DepositRefundController dr2 = new DepositRefundController();        
        dr2.deposit.Refund_Mode__c = 'Cash';
        dr2.deposit.Requested_Amount__c = 100000000;
        dr2.refund(); 
        
        Apexpages.currentPage().getParameters().put('Id',dp.Id);
        DepositRefundController dr = new DepositRefundController();        
        dr.deposit.Refund_Mode__c = 'Cash';
        dr.deposit.Requested_Amount__c = 9;
        dr.refund(); 
        dr.cancel();
        
        Apexpages.currentPage().getParameters().put('Id',null);
        dr = new DepositRefundController();   
        dr.refund(); 
        dr.cancel(); 
        
    }
}