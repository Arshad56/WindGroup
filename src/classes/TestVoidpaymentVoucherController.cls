@isTest
Class TestVoidpaymentVoucherController{
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
        dp.Deposit_Amount__c = 10;
        dp.Lease__c = ls.Id;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        dp.Currency_Code__c = 'USD';
        insert dp;
        
        Payment_Voucher__c pv = new Payment_Voucher__c();
        pv.Deposit__c = dp.Id;
        pv.Refund_Mode__c = dp.Refund_Mode__c;
        pv.Currency_Code__c = dp.Currency_Code__c;
        pv.Amount__c = -100;
        pv.Void__c = true;
        pv.Lease__c = dp.Lease__c;            
        pv.Exchange_Rate__c = 1400;
        insert pv;

        VoidpaymentVoucherController.void(pv.Id);
        
        checkRecursive.run = true;
        update pv;
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        insert cr;
        
        Cash_Detail__c cd = new Cash_Detail__c();
        cd.Cash_Receipt__c = cr.Id;
        cd.Amount_Paid__c = 10;
        cd.Payment_Voucher__c = pv.id;
        insert cd;
        
        VoidpaymentVoucherController.void(pv.Id);
        
        checkRecursive.run = true;
        update pv;
        
        VoidpaymentVoucherController.void(null);
            
    }
}