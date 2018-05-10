@isTest
Class TestCreateInvoiceForApproved{
    static Rent_Roll__c rentRoll;
    static Rent_Roll__c rentRoll1;
    static Rent_Roll_Detail__c rrd;
    static Lease_Unit__c lu;
    static Property__c prop;
    static void init(){
        
        
        prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        List<Billing_Due_Day__c> billingList = new List<Billing_Due_Day__c>();
        Billing_Due_Day__c billDays1= new Billing_Due_Day__c();
        billDays1.Billing_Due_Days__c = '10';
        billDays1.Billing_Type__c = 'Ad-Hoc Invoice; Credit Note; Debit Note; GTO Rent';
        billDays1.Property__c = prop.Id;
        billingList.add(billDays1);
        
        Billing_Due_Day__c billDays2= new Billing_Due_Day__c();
        billDays2.Billing_Due_Days__c = '20';
        billDays2.Billing_Type__c = 'Late Charge; Miscellaneous; Monthly; Rent';
        billDays2.Property__c = prop.Id;
        billingList.add(billDays2);
        
        billDays2= new Billing_Due_Day__c();
        billDays2.Billing_Due_Days__c = '20';
        billDays2.Billing_Type__c = 'Late Charge';
        billDays2.Property__c = prop.Id;
        billingList.add(billDays2);
        
        insert billingList;
        
        
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
        
        lu = new Lease_Unit__c();
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
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='By Area';
        lc1.charge_Rate__c = 5;
        insert lc1;
        
        rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        rentRoll.Actual_Invoice_Date__c = system.today();
        insert rentRoll;
        
       
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        
        
        rrd = new Rent_Roll_Detail__c();
        rrd.Lease_Unit__c = lu.Id;
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = 'Approved';
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        insert rrd;
    }
    static testMethod void Test1(){
        init();
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        insert ili;
        
        rentRoll1 = new Rent_Roll__c();
        rentRoll1.Property__c = prop.Id;
                        
        rentRoll1.Total_Amount__c = 100;
        rentRoll1.Actual_Invoice_Date__c = system.today();                
        rentRoll1.Billing_Type__c = 'Late Charge';
        insert rentRoll1;
        
        
        Rent_Roll_Detail__c rrd1 = new Rent_Roll_Detail__c();
        rrd1.Lease_Unit__c = lu.Id;
        rrd1.Unit__c = lu.Unit__c;
        rrd1.Status__c = 'Approved';
        rrd1.Start_Date__c = system.today();
        rrd1.End_Date__c = system.today().addDays(5);
        rrd1.Rent_Roll__c = rentRoll1.Id;
        rrd1.Approved__c = true;
        rrd1.Invoice__c = inv.Id;
        insert rrd1;
        
        Test.startTest();
            Utility.invCreateRun = true;
            rentRoll.Approved__c = true;
            update rentRoll;
            Utility.invCreateRun = true;
            rentRoll1.Approved__c = true;
            update rentRoll1;
        Test.stopTest();
    }
}