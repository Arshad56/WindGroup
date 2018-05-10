@isTest
Class TestPosIdSetupTrigger{
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
        insert lc;
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='By Area';
        lc1.charge_Rate__c = 5;
        insert lc1;
        
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
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        insert ili;
        
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
        
        Deposit__c dp = new Deposit__c();
        dp.Deposit_Amount__c = 10;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        insert dp;
        
        Currency_Offset_Limit__c col = new Currency_Offset_Limit__c();
        col.Name = label.Default_Currency;
        col.Upper_Limit__c = 1;
        col.Lower_Limit__c = 1;
        insert col;
        
        GenerateCashReceiptController  gcr = new GenerateCashReceiptController ();
        gcr.totalpayment = 9;
        gcr.rroll.Property__c  = prop.Id;
        gcr.con.AccountId = acc.Id;
        gcr.cr.payment_Currency__c = label.Default_Currency;
        gcr.cr.Payment_Mode__c = 'Cash';
        gcr.cr.Payment_Date__c = system.today();
        gcr.search();
        gcr.generateCashReceipt();
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
        
        Lease_POS__c lp = new Lease_POS__c();
        lp.Name = '--system generated--';
        lp.Generate_POS_ID__c = 'Yes';
        lp.Lease_Unit__c = lu.Id;
        insert lp;
        
        List<Lease_POS__c> lpList = new List<Lease_POS__c>();
        
        Lease_POS__c lp1 = new Lease_POS__c();
        lp1.Name = '--system generated--';
        lp1.Generate_POS_ID__c = 'Yes';
        lp1.Lease_Unit__c = lu.Id;
        lpList.add(lp1);
        
        Lease_POS__c lp2 = new Lease_POS__c();
        lp2.Name = 'Test';
        lp2.Generate_POS_ID__c = 'No';
        lp2.Lease_Unit__c = lu.Id;
        lp2.Start_Date__c = system.today();
        lp2.End_Date__c = system.today().addMonths(1);
        lpList.add(lp2);
        
        insert lpList;
        
        Lease_POS__c lp3 = new Lease_POS__c();
        lp3.Name = 'Tset';
        lp3.Generate_POS_ID__c = 'Yes';
        lp3.Lease_Unit__c = lu.Id;
        try{
            insert lp3;
        }catch(exception e){}
        
    }
    
}