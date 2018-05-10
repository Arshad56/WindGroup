@isTest
private class PaymentVoucherRefundController_Test {

    @isTest
    private static void paymentVoucherRefund(){   
        Payment_Voucher__c pv = createTestData(); 
        PageReference pageRef = Page.PaymentVoucherRefund;
        pageRef.getParameters().put('pvId', String.valueOf(pv.Id));
        pageRef.getParameters().put('pvStatus', String.valueOf(pv.Status__c));
        pageRef.getParameters().put('pvBalance', String.valueOf('-1000'));
        pageRef.getParameters().put('pvLeaseId', String.valueOf(pv.Lease__c));
        pageRef.getParameters().put('pvCurrency', String.valueOf(pv.Currency_Code__c));
        Test.setCurrentPage(pageRef);
        
        PaymentVoucherRefundController pvcontroller = new PaymentVoucherRefundController();
        pvcontroller.getPaymentModeOptions();
        pvcontroller.paymentMode = 'Cash'; 
        pvcontroller.checkData();

        checkRecursive.run = TRUE;
		pv.Status__c = 'Closed';
        update pv;
    }
    
    @isTest
    private static void createPaymentVoucher(){ 
        
        Deposit__c dep = new Deposit__c();
        dep.Status__c = 'Paid';
        dep.Name = 'Test Deposit';
        dep.Amount_Paid__c = 1000;
        dep.Currency_Code__c = 'USD';
        dep.Refund_Mode__c ='Cash';
        dep.PV_Currency_Code__c = 'MMK';
        dep.Exchange_Rate__c = 1400;
        dep.Requested_Amount__c = 10000;
        dep.Refund_Status__c = 'Requested';
        insert dep;
        
        dep.Refund_Status__c = 'Approved';
        update dep;
    }
    
    @isTest
    private static Payment_Voucher__c createTestData(){
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;

        Property__c prop = new Property__c();
        prop.Name = 'TestTenant';
        prop.short_code__c='TT';
        prop.Cash_Receipt_Index__c = 0001;
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addMonths(3);
        insert unt;

        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 2;
        ls.Lease_Tenure_Days__c = '0';
        ls.Lease_Status__c = 'New';
        ls.GTO_Billed__c = 'By Lease Unit';
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu.Lease_Unit_Status__c = 'New';
        lu.Unit__c = unt.Id;
        insert lu;
        
        Deposit__c dep = new Deposit__c();
        dep.Lease__c = ls.Id;
        dep.Lease_Unit__c = lu.Id;
        dep.Status__c = 'Paid';
        dep.Name = 'Test Deposit';
        dep.Amount_Paid__c = 1000;
        dep.Currency_Code__c = 'USD';
        insert dep;
        
        Payment_Voucher__c pv = new Payment_Voucher__c(); 
        pv.Name = 'TEST PV';
        pv.Currency_Code__c = 'MMK';
        pv.Exchange_Rate__c = 1;
        pv.Lease__c = ls.Id;
        pv.Deposit__c = dep.Id;
        pv.Status__c = 'New';
        pv.Amount__c = -1000000;
        pv.Refunded_Amount__c = -10;
        pv.Refund_Mode__c = 'Offset Invoice';
        insert pv;
        
        Payment_Voucher__c pv1 = new Payment_Voucher__c(); 
        pv1.Name = 'TEST PV1';
        pv1.Currency_Code__c = 'MMK';
        pv1.Exchange_Rate__c = 1.2345;
        pv1.Lease__c = ls.Id;
        pv1.Deposit__c = dep.Id;
        pv1.Status__c = 'New';
        pv1.Amount__c = -1000;
        pv1.Refunded_Amount__c = 0.0;
        pv1.Refund_Mode__c = 'Cash';
        insert pv1;
        
        return pv;
    }

}