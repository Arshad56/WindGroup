/*
 * Name               :       GenerateJournalVoucherController Test Class
 * Author             :       Mohd Anas
 * Date               :       29/3/2017
 * Description        :       Unit Test class for GenerateJournalVoucherController.
*/
@isTest
private class GenerateJournalVoucherControllerTest {
    public static Fiscal_Period__c fp;
    public static Property__c prop;
    public static JE_Logic__c jeLog;
    public static JE_Configuration__c jeConfig;
    public static Account acc;
    public static void init(){
         //-------------------------------Inserting Test Data------------------------
         acc = new Account();
        acc.Name = 'TestTenantGenJVC';
        insert acc;
        
        
        
         prop = new Property__c();
        prop.Name = 'TestGenJVC';
        prop.short_code__c='TGJVC';
        prop.Landlord__c=acc.id;
        prop.Journal_Voucher_Index__c=213;
        prop.Journal_Entry_Index__c=20;
        prop.Journal_Batch_Index__c=200;
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevelGenJVC';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnitGenJVC';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        insert unt;
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
        Deposit__c dep = new Deposit__c();
        dep.name='--System Generated--';
        dep.Lease__c = ls.id;
        dep.Lease_Unit__c  = lu.id; 
        dep.Deposit_Amount__c = 500;
        dep.Currency_Code__c = label.default_Currency;
        dep.Deposit_Type__c = 'Security';
        dep.Deposit_Date__c = system.today();
        insert dep;  
        
        Payment_Voucher__c pv = new Payment_Voucher__c();
        pv.Deposit__c = dep.Id;
        pv.Refund_Mode__c = dep.Refund_Mode__c;
        pv.Currency_Code__c = dep.Currency_Code__c;
        pv.Amount__c = -100;
        pv.Lease__c = dep.Lease__c;            
        pv.Exchange_Rate__c = 1400;
        pv.Transaction_Type__c = 'Deposit';
        pv.Refund_Mode__c = 'Cash';
        insert pv;
        
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestChargeGenJVC';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.charge_type__c='Advance Rental';  
        lc.Commercial_Tax_Apply__c = true;
        insert lc;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        rentRoll.Billing_Type__c='Monthly';
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
        
        Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
        rrd.Unit__c = rs.Unit__c;
        rrd.Status__c = 'Pending';
        rrd.Lease_Charge__c = rs.Lease_Charge__c;
        rrd.Start_Date__c = rs.Start_Date__c;
        rrd.End_Date__c = rs.End_Date__c;
        rrd.Rent_Roll__c = rs.Rent_Roll__c;
        rrd.Approved__c = rs.Approved__c;
        insert rrd;                
        
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'In-Tenancy';
        rs1.Lease_Charge__c = lc.Id;
        rs1.Start_Date__c = system.today();
        rs1.End_Date__c = system.today();
        rs1.Rent_Roll__c = rentRoll.Id;
        rs1.Approved__c = true;
        insert rs1;
        
        Rent_Roll_Detail__c rrd1 = new Rent_Roll_Detail__c();
        rrd1.Unit__c = rs1.Unit__c;
        rrd1.Status__c = 'Pending';
        rrd1.Lease_Charge__c = rs1.Lease_Charge__c;
        rrd1.Start_Date__c = rs1.Start_Date__c;
        rrd1.End_Date__c = rs1.End_Date__c;
        rrd1.Rent_Roll__c = rs1.Rent_Roll__c;
        rrd1.Approved__c = rs1.Approved__c;
        rrd1.Comments__c = 'Testing GenerateJournalVouchercontroller';
        insert rrd1;
       
        Invoice__c inv=new Invoice__c();
        inv.name='TestGenJVC';
        inv.Rent_Roll__c = rentRoll.Id;
        inv.Property_name__c=rentRoll.Property__c;
        inv.Jv_status__c='Pending';
        inv.Currency_Code__c = label.Default_Currency;
        inv.Invoice_Date__c=system.Today();//.addDays(10);
        insert inv;

        Invoice_Line_Item__c il = new Invoice_Line_Item__c();
        il.Invoice__c = inv.id;
        il.Lease_Charge__c=lc.id;
        il.Due_Days__c=15;
        il.Currency_Code__c = label.Default_Currency;
        il.start_date__c=System.today();
        il.End_Date__c=System.today().addMonths(1);
        il.Amount__c=2000;
        insert il;
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        cr.Name = 'Test';
        cr.Property__c = prop.Id;
        cr.Tenant__c = acc.Id;
        cr.Remarks__c = 'Testing';
        cr.Payment_Mode__c = 'Cash';
        cr.Payment_Date__c = system.today();
        cr.Payment_Currency__c = label.Default_Currency;
        insert cr;
        
        Cash_Detail__c cd =new Cash_Detail__c();
        cd.Amount_Paid__c = 10;
        cd.Cash_Receipt__c = cr.Id;
        cd.Invoice__c = inv.Id;
        cd.Payment_Mode__c = 'Cash';
        cd.Remarks__c = 'Testing';
        insert cd;
        
        Fiscal_Year__c fy=new Fiscal_Year__c();
        fy.Company__c=acc.id;
        fy.Start_Date__c=system.today();
        fy.End_Date__c=system.today().addMonths(12);
        insert fy;
        
         fp=new Fiscal_Period__c();
        fp.Fiscal_Year__c=fy.id;
        fp.Start_Date__c=system.today();
        insert fp;
        
        COA_Group__c coGrp=new COA_Group__c();
        coGrp.Group_Description__c='Test data in coa group object';
        insert coGrp;
        
        COA_Master__c coMaster=new COA_Master__c();
        coMaster.COA_Group__c=coGrp.id;
        coMaster.Currency_Code__c = label.Default_Currency;
        insert coMaster;
        
        COA_Master_FY_Balance__c coaMasFyBal = new COA_Master_FY_Balance__c();
        coaMasFyBal.COA_Master__c = coMaster.id; 
        coaMasFyBal.Fiscal_Year__c = fy.id;
        insert coaMasFyBal;
        
        COA_Balance__c coBal=new COA_Balance__c();
        coBal.Company__c=acc.id;
        coBal.Fiscal_Period__c=fp.id;
        coBal.COA_Master__c=coMaster.id;
        coBal.COA_Master_FY_Balance__c = coaMasFyBal.id;
        insert coBal;
        
        jeLog=new JE_Logic__c();
        jeLog.Charge_Type__c='Advance Rental';
        jeLog.Transaction__c='Invoice';
        jeLog.Company__c=acc.id;
        jeLog.Document_Currency__c=label.Default_Currency;
        jeLog.JV_Type__c='Invoice (Normal)';
        insert jeLog;
        
        jeConfig=new JE_Configuration__c();
        jeConfig.COA_Master__c=coMaster.id;
        jeConfig.JE_Logic__c=jeLog.id;
        jeConfig.Journal_Amount__c='Tax Amount';
        jeConfig.JV_Run__c='Run 2';
        jeConfig.Transaction_Type__c='Dr';
        jeConfig.Summarization__c='Y';
        insert jeConfig;
        
    }
    @isTest 
    static void testpageReference(){
        init();
        //------------End oF test data Insertion--------------------------
        
        Test.startTest();
        GenerateJournalVoucherController cntr=new GenerateJournalVoucherController();
        cntr.getMonthList();
        cntr.getYearList();
        cntr.getBillingTypes();
        cntr.getCurrencyCode();
        //-------------Setting Up dates parameters--------------------------------
        cntr.month= System.today().month();
        cntr.year=System.today().year(); 
        cntr.rentRoll.Property__c = prop.Id;
        cntr.rentRoll.Billing_Type__c = 'Monthly';
        cntr.sltdCurrCodeInv = label.Default_Currency;
        cntr.searchInvoices();
        cntr.generateJournalvoucher();
        
        cntr.selectedFPInv = fp.Id;
        
        
        //-------------------Setting InvoiceModel Boolean variable to true------------------
        for(GenerateJournalVoucherController.InvoiceModel invMod:cntr.InvModList)
            invMod.isChek=TRUE;
        cntr.generateJournalvoucher();
        
        //---------------changing value of JV_Run in JE_Configuration__c object--------------
        jeConfig.JV_Run__c='Standard';
        update jeConfig;
        cntr.generateJournalvoucher();
        
        //---------------changing value of Summarization in JE_Configuration__c object--------------
        jeConfig.Summarization__c='N';
        update jeConfig;
        cntr.generateJournalvoucher();
        
        //---------------------------changing value of Transaction in JE_Configuration__c object for else--------
        jeConfig.Transaction_Type__c='Cr';
        update jeConfig;
        cntr.generateJournalvoucher();
        
        //------------changing value of JV_Run in JE_Configuration__c object again to check for else----------
        jeConfig.JV_Run__c='Run 2';
        update jeConfig;
        cntr.generateJournalvoucher();
         Test.stopTest();
    }    
    @isTest 
    static void testpageReferenceDeposit(){
        init();
        jeLog.Charge_Type__c=null;
        jeLog.Transaction__c='Deposit';
        jeLog.JV_Type__c='Security';
        update jeLog;
        
        jeConfig.Journal_Amount__c='Tax Amount';
        jeConfig.JV_Run__c='Run 2';
        jeConfig.Transaction_Type__c='Dr';
        jeConfig.Summarization__c='Y';
        
        update jeConfig;
        //------------End oF test data Insertion--------------------------
        
        Test.startTest();
        GenerateJournalVoucherController cntr=new GenerateJournalVoucherController();
        
        cntr.leaseObj.Property__c = prop.Id;
        cntr.depObj.Deposit_Type__c='Security';
        
        //-------------Setting Up dates parameters--------------------------------
        cntr.selectedFPDep = fp.Id;
        cntr.sltdCurrCodeDep = label.Default_Currency;
        
        cntr.monthDep = System.today().month();
        cntr.yearDep = System.today().year();
        
        cntr.searchDeposit();
        cntr.generateJournalVoucherDeposit();
        
        //-------------------Setting InvoiceModel Boolean variable to true------------------
        for(GenerateJournalVoucherController.DepositModel invMod:cntr.DepModList)
            invMod.isChek=TRUE;
        cntr.generateJournalVoucherDeposit();
        
        //---------------changing value of JV_Run in JE_Configuration__c object--------------
        jeConfig.JV_Run__c='Standard';
        update jeConfig;
        cntr.generateJournalVoucherDeposit();
        
        //---------------changing value of Summarization in JE_Configuration__c object--------------
        jeConfig.Summarization__c='N';
        update jeConfig;
        cntr.generateJournalVoucherDeposit();
        
        //---------------------------changing value of Transaction in JE_Configuration__c object for else--------
        jeConfig.Transaction_Type__c='Cr';
        update jeConfig;
        cntr.generateJournalVoucherDeposit();
        
        //------------changing value of JV_Run in JE_Configuration__c object again to check for else----------
        jeConfig.JV_Run__c='Run 2';
        update jeConfig;
        cntr.generateJournalVoucherDeposit();
         Test.stopTest();
         
    }
    @isTest 
    static void testpageReferencePaymentV(){
        init();
        jeLog.Charge_Type__c=null;
        jeLog.Transaction__c='Payment Voucher';
        jeLog.JV_Type__c='Deposit';
        jeLog.Payment_Mode__c = 'Cash';
        update jeLog;
        
        jeConfig.Journal_Amount__c='Tax Amount';
        jeConfig.JV_Run__c='Run 2';
        jeConfig.Transaction_Type__c='Dr';
        jeConfig.Summarization__c='Y';
        
        update jeConfig;
        //------------End oF test data Insertion--------------------------
        
        Test.startTest();
        GenerateJournalVoucherController cntr=new GenerateJournalVoucherController();
        
        cntr.leasePVObj.Property__c = prop.Id;
        cntr.pvObj.Refund_Mode__c = 'Cash'; 
        cntr.pvObj.Transaction_Type__c = 'Deposit';
        //-------------Setting Up dates parameters--------------------------------
        cntr.selectedFPPV = fp.Id;
        
        cntr.sltdCurrCodePV = label.Default_Currency;
        
        cntr.monthPV = System.today().month();
        cntr.yearPV = System.today().year();
        
        cntr.searchPV();
        cntr.generateJournalVoucherPV();
        
        //-------------------Setting InvoiceModel Boolean variable to true------------------
        for(GenerateJournalVoucherController.PVModel invMod:cntr.PVModList)
            invMod.isChek=TRUE;
        cntr.generateJournalVoucherPV();
        
        //---------------changing value of JV_Run in JE_Configuration__c object--------------
        jeConfig.JV_Run__c='Standard';
        update jeConfig;
        cntr.generateJournalVoucherPV();
        
        //---------------changing value of Summarization in JE_Configuration__c object--------------
        jeConfig.Summarization__c='N';
        update jeConfig;
        cntr.generateJournalVoucherPV();
        
        //---------------------------changing value of Transaction in JE_Configuration__c object for else--------
        jeConfig.Transaction_Type__c='Cr';
        update jeConfig;
        cntr.generateJournalVoucherPV();
        
        //------------changing value of JV_Run in JE_Configuration__c object again to check for else----------
        jeConfig.JV_Run__c='Run 2';
        update jeConfig;
        cntr.generateJournalVoucherPV();
         Test.stopTest();
         
    }
    @isTest 
    static void testpageReferenceCR(){
        init();
        Bank_Information__c bi1 = new Bank_Information__c();
        bi1.Currency_Code__c = label.Default_Currency;
        bi1.Property__c = prop.Id;
        insert bi1;
        
        jeLog.Charge_Type__c=null;
        jeLog.JV_Type__c=null;
        jeLog.Transaction__c='Cash Receipt';
        jeLog.Payment_Mode__c = 'Cash';
        jeLog.Bank_Name__c = bi1.Id;
        update jeLog;
        
        jeConfig.Journal_Amount__c='Tax Amount';
        jeConfig.JV_Run__c='Run 2';
        jeConfig.Transaction_Type__c='Dr';
        jeConfig.Summarization__c='Y';
        
        update jeConfig;
        
        //------------End oF test data Insertion--------------------------
        
        Test.startTest();
        GenerateJournalVoucherController cntr=new GenerateJournalVoucherController();
        
        cntr.crObj.Property__c = prop.Id;
        cntr.crObj.Payment_Mode__c = 'Cash'; 
        //-------------Setting Up dates parameters--------------------------------
        cntr.selectedFPCR = fp.Id;
        
        cntr.sltdCurrCodeCR = label.Default_Currency;
        
        cntr.monthCR = System.today().month();
        cntr.yearCR = System.today().year();
        
        cntr.searchCashReceipt();
        cntr.generateJournalVoucherCR();
        
        //-------------------Setting InvoiceModel Boolean variable to true------------------
        for(GenerateJournalVoucherController.CaseRecptModel invMod:cntr.CRModList)
            invMod.isChek=TRUE;
        cntr.generateJournalVoucherCR();
        
        //---------------changing value of JV_Run in JE_Configuration__c object--------------
        jeConfig.JV_Run__c='Standard';
        update jeConfig;
        cntr.generateJournalVoucherCR();
        
        //---------------changing value of Summarization in JE_Configuration__c object--------------
        jeConfig.Summarization__c='N';
        update jeConfig;
        cntr.generateJournalVoucherCR();
        
        //---------------------------changing value of Transaction in JE_Configuration__c object for else--------
        jeConfig.Transaction_Type__c='Cr';
        update jeConfig;
        cntr.generateJournalVoucherCR();
        
        //------------changing value of JV_Run in JE_Configuration__c object again to check for else----------
        jeConfig.JV_Run__c='Run 2';
        update jeConfig;
        cntr.generateJournalVoucherCR();
         Test.stopTest();
         
    }
}