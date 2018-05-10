@isTest
Class TestGenerateCashReceiptController{
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
        rentRoll.Billing_Type__c = 'Rent';
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
        rs.Cap_Value__c = 10;
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
        ili.Lease_Charge__c = lc.Id;
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
        rs.Cap_Value__c = 10;
        insert rs;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        inv.Exchange_Rate__c = 1;
        inv.Currency_Code__c = label.Default_Currency;
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
        dp.Deposit_Amount_Local__c = 10;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Exchange_Rate__c = 2;
        dp.Currency_Code__c = label.Base_Foreign_Currency;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        insert dp;
        
        Currency_Offset_Limit__c col = new Currency_Offset_Limit__c();
        col.Name = label.Default_Currency;
        col.Upper_Limit__c = 1;
        col.Lower_Limit__c = 1;
        insert col;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('tid',acc.Id);
        GenerateCashReceiptController  gcr = new GenerateCashReceiptController ();
        gcr.totalpayment = 9;
        gcr.InvNumber = [Select name from Invoice__c where id=:inv.Id][0].Name;
        gcr.cr.payment_Currency__c = label.Default_Currency;
        gcr.cr.Payment_Mode__c = 'Cash';
        gcr.cr.Payment_Date__c = system.today();
        gcr.search();
        if(gcr.displayWrapList.size()>0){
           gcr.displayWrapList[0].applyPenalty = true; 
           gcr.TotalPayment += gcr.displayWrapList[0].penaltyAmount;
        }
        gcr.generateCashReceipt();
        gcr.generatePDF();
        gcr.rRoll.Property__c = prop.Id;
        
        gcr.generateAccountStmtPdf();
        
        GenerateCashReceiptController  gcr1 = new GenerateCashReceiptController ();
        gcr1.totalpayment = 9;
        gcr1.InvNumber = [Select name from Deposit__c where id=:dp.Id][0].Name;
        gcr1.cr.payment_Currency__c = label.Default_Currency;
        gcr1.cr.Payment_Mode__c = 'Cash';
        gcr1.cr.Payment_Date__c = system.today();
        gcr1.search();
        if(gcr1.displayWrapList.size()>0){
           gcr1.displayWrapList[0].applyPenalty = true; 
           //gcr1.TotalPayment += gcr1.displayWrapList[0].penaltyAmount;
        }
        gcr1.generateCashReceipt();
        Test.stopTest();
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
        rentRoll.Billing_Type__c = 'Monthly';
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
        rs.Cap_Value__c = 10;
        insert rs;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        inv.Exchange_Rate__c = 1;
        inv.Currency_Code__c = label.Default_Currency;
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
        dp.Deposit_Amount_Local__c = 10;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Exchange_Rate__c = 2;
        dp.Currency_Code__c = label.Base_Foreign_Currency;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        insert dp;
        
        Currency_Offset_Limit__c col = new Currency_Offset_Limit__c();
        col.Name = label.Default_Currency;
        col.Upper_Limit__c = 1;
        col.Lower_Limit__c = 1;
        insert col;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('tid',acc.Id);
        GenerateCashReceiptController  gcr = new GenerateCashReceiptController ();
        gcr.totalpayment = 9;
        gcr.InvNumber = [Select name from Invoice__c where id=:inv.Id][0].Name;
        gcr.cr.payment_Currency__c = label.Default_Currency;
        gcr.cr.Payment_Mode__c = 'Cash';
        gcr.cr.Payment_Date__c = system.today();
        gcr.search();
        if(gcr.displayWrapList.size()>0){
           gcr.displayWrapList[0].applyPenalty = true; 
           gcr.TotalPayment += gcr.displayWrapList[0].penaltyAmount;
        }
        gcr.generateCashReceipt();
        gcr.generatePDF();
        gcr.rRoll.Property__c = prop.Id;
        
        gcr.generateAccountStmtPdf();
        
        GenerateCashReceiptController  gcr1 = new GenerateCashReceiptController ();
        gcr1.totalpayment = 9;
        gcr1.InvNumber = [Select name from Deposit__c where id=:dp.Id][0].Name;
        gcr1.cr.payment_Currency__c = label.Default_Currency;
        gcr1.cr.Payment_Mode__c = 'Cash';
        gcr1.cr.Payment_Date__c = system.today();
        gcr1.search();
        if(gcr1.displayWrapList.size()>0){
           gcr1.displayWrapList[0].applyPenalty = true; 
           //gcr1.TotalPayment += gcr1.displayWrapList[0].penaltyAmount;
        }
        gcr1.generateCashReceipt();
        Test.stopTest();
    }
    
    static TestMethod void Test3(){
        
        
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
        lc.Charge_Type__C = 'GTO Rent';
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
        rentRoll.Billing_Type__C = 'GTO Rent';
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
        rs.Cap_Value__c = 10;
        insert rs;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        inv.Exchange_Rate__c = 1;
        inv.Currency_Code__c = label.Default_Currency;
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Amount__c = 10;
        ili.Invoice__c = inv.Id;
        ili.Rent_Schedule__c = rs.Id;
        ili.Lease_Charge__c = lc.Id;
        ili.Transaction_Start_Date__c = rs.Start_Date__c;
        ili.Transaction_End_Date__c = rs.End_Date__c;
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
        dp.Deposit_Amount_Local__c = 10;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Exchange_Rate__c = 2;
        dp.Currency_Code__c = label.Base_Foreign_Currency;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        insert dp;
        
        Currency_Offset_Limit__c col = new Currency_Offset_Limit__c();
        col.Name = label.Default_Currency;
        col.Upper_Limit__c = 1;
        col.Lower_Limit__c = 1;
        insert col;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('tid',acc.Id);
        GenerateCashReceiptController  gcr = new GenerateCashReceiptController ();
        gcr.totalpayment = 9;
        gcr.InvNumber = [Select name from Invoice__c where id=:inv.Id][0].Name;
        gcr.cr.payment_Currency__c = label.Default_Currency;
        gcr.cr.Payment_Mode__c = 'Cash';
        gcr.cr.Payment_Date__c = system.today();
        gcr.search();
        if(gcr.displayWrapList.size()>0){
           gcr.displayWrapList[0].applyPenalty = true; 
           gcr.TotalPayment += gcr.displayWrapList[0].penaltyAmount;
        }
        gcr.generateCashReceipt();
        gcr.generatePDF();
        gcr.rRoll.Property__c = prop.Id;
        
        gcr.generateAccountStmtPdf();
        
        GenerateCashReceiptController  gcr1 = new GenerateCashReceiptController ();
        gcr1.totalpayment = 9;
        gcr1.InvNumber = [Select name from Deposit__c where id=:dp.Id][0].Name;
        gcr1.cr.payment_Currency__c = label.Default_Currency;
        gcr1.cr.Payment_Mode__c = 'Cash';
        gcr1.cr.Payment_Date__c = system.today();
        gcr1.modPaymentCurrency();
        gcr1.search();
        if(gcr1.displayWrapList.size()>0){
           gcr1.displayWrapList[0].applyPenalty = true; 
           //gcr1.TotalPayment += gcr1.displayWrapList[0].penaltyAmount;
        }
        gcr1.generateCashReceipt();
        Test.stopTest();
    }
    
    static TestMethod void Test4(){
        
        
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
        rentRoll.Billing_Type__c = 'Monthly';
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
        rs.Cap_Value__c = 10;
        insert rs;
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Date__c = system.today().addDays(-7);
        inv.Lease__c = ls.Id;
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Payment_Due_Date__c = system.today().addDays(-2);
        inv.Exchange_Rate__c = 1;
        inv.Currency_Code__c = label.Default_Currency;
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
        dp.Deposit_Amount_Local__c = 10;
        dp.Lease_Unit__c = lu.Id;
        dp.Lease_Charge__c = lc.Id;
        dp.Exchange_Rate__c = 2;
        dp.Currency_Code__c = label.Base_Foreign_Currency;
        dp.Payment_Due_Date__c = system.today().addDays(-2);
        insert dp;
        
        Payment_Voucher__c pv = new Payment_Voucher__c();
        pv.Deposit__c = dp.Id;
        pv.Refund_Mode__c = 'Offset Invoice';
        pv.Status__c = 'New';
        pv.Currency_Code__c = dp.Currency_Code__c;
        pv.Amount__c = -100;
        pv.Void__c = true;
        pv.Lease__c = dp.Lease__c;            
        pv.Exchange_Rate__c = 1400;
        insert pv;
        
        Currency_Offset_Limit__c col = new Currency_Offset_Limit__c();
        col.Name = label.Default_Currency;
        col.Upper_Limit__c = 1;
        col.Lower_Limit__c = 1;
        insert col;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('tid',acc.Id);
        GenerateCashReceiptController  gcr = new GenerateCashReceiptController ();
        gcr.totalpayment = 9;
        gcr.InvNumber = [Select name from Invoice__c where id=:inv.Id][0].Name;
        gcr.cr.payment_Currency__c = label.Default_Currency;
        gcr.cr.Payment_Mode__c = 'Cash';
        gcr.cr.Payment_Date__c = system.today();
        gcr.search();
        if(gcr.displayWrapList.size()>0){
           gcr.displayWrapList[0].applyPenalty = true; 
           gcr.TotalPayment += gcr.displayWrapList[0].penaltyAmount;
        }
        gcr.generateCashReceipt();
        gcr.generatePDF();
        gcr.rRoll.Property__c = prop.Id;
        
        gcr.generateAccountStmtPdf();
        
        GenerateCashReceiptController  gcr1 = new GenerateCashReceiptController ();
        gcr1.totalpayment = 9;
        gcr1.InvNumber = [Select name from Payment_Voucher__c where id=:pv.Id][0].Name;
        gcr1.cr.payment_Currency__c = label.Default_Currency;
        gcr1.cr.Payment_Mode__c = 'Payment Voucher';
        gcr1.cr.Payment_Date__c = system.today();
        gcr1.search();
        if(gcr1.displayWrapList.size()>0){
           gcr1.displayWrapList[0].applyPenalty = true; 
           //gcr1.TotalPayment += gcr1.displayWrapList[0].penaltyAmount;
        }
        gcr1.generateCashReceipt();
        Test.stopTest();
    }
    
}