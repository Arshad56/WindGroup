@isTest
 public class InvoiceRefundController_Test {
	static Invoice__c inv;
	static void init(){
		
        
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
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
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
        insert lc;
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='By Percent';
        lc1.charge_Rate__c = 5;
        lc1.Charge_Type__c ='A&P';
        lcList.add(lc1);
        
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'Commercial Tax';
        lc2.Start_Date__c = system.today();
        lc2.End_Date__c = system.today().addYears(1);
        lc2.Lease_Unit__c = lu.Id;
        lc2.Charge_Type__c='GTO Rent';
        lc2.Type__c='GTO (Higher)';
        lc2.charge_Rate__c = 5;
        lcList.add(lc2);
        
        Lease_Charges__c lc3 = new Lease_Charges__c();
        lc3.Name = 'Commercial Tax';
        lc3.Start_Date__c = system.today();
        lc3.End_Date__c = system.today().addYears(1);
        lc3.Lease_Unit__c = lu.Id;
        lc3.Charge_Type__c='GTO Rent';
        lc3.Type__c='GTO (Higher)';
        lc3.charge_Rate__c = 5;
        lcList.add(lc3);
        insert lcList;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        insert rentRoll; 
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        inv = new Invoice__c();
        inv.Invoice_Date__c = system.today();
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Currency_Code__c = label.Default_Currency;
        inv.Amount_Local__c = 100;
        inv.Amount_Paid_Local__c = 200;
        insert inv;
        
        Bank_Information__c bi1 = new Bank_Information__c();
        bi1.Currency_Code__c = label.Default_Currency;
        bi1.Property__c = prop.Id;
        insert bi1;
        
        Bank_Information__c bi2 = new Bank_Information__c();
        bi2.Property__c = prop.Id;
        bi2.Currency_Code__c = label.Base_Foreign_Currency;
        insert bi2;
        
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        ili.Lease_Charge__c = lc1.Id;
        insert ili;
        
        Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
        ili1.Amount__c = 10;
        ili1.Invoice__c = inv.Id;
        ili1.Rent_Schedule__c = rs.Id;
        ili1.Lease_Charge__c = lc2.Id;
        insert ili1;
        
        Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = rs.Status__c;
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        rrd.Invoice_Line_Item__c = ili.Id;
        insert rrd;
        
	}
    static TestMethod void Test(){
        init();
        Test.startTest();
        Apexpages.currentPage().getParameters().put('id',inv.Id);
        InvoiceRefundController invRef = new InvoiceRefundController();
        
        List<SelectOption> str = new List<SelectOption>(invRef.getPaymentModeOptions());
        invRef.generateRefund();
        
        invRef.updateInv.Requested_Amount__c =1;
        invRef.invBalance =2;
        
        invRef.generateRefund();
        
        invRef.cancel();
        invRef.invId = null;
        invRef.cancel();
        Test.stopTest();
    }
}