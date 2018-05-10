/*
 * Name               :       AccountStatementPDF Controller Test Class
 * Author             :       Mohd Anas
 * Date               :       23/3/2017
 * Description        :       Unit Test class for account statementPDF controller.
*/
@isTest
public class AccountStatementPDFCntrlTest{
    static testMethod void testgetDepoInvList() {
        //-----------------------Data Block--------------------
        List<Account> acList=new List<Account>();
            Account ac=new Account();
            ac.Name='abcd';
            ac.BillingStreet='s123';
            acList.add(ac);
        
            Account ac2=new Account();
            ac2.Name='abcd';
            ac2.BillingStreet='s123';
            acList.add(ac2);
        
            insert acList;
            Account tenant=acList.get(0);
        
        Property__c prop=new Property__c();
        prop.Bank_Account_Number__c='12345678';
        prop.Address__c='vgfhsdgfdsfhdgfhdcbhdgv';
        prop.Annual_Budgeted_Revenue__c=600000;
        prop.Annual_Committed_Revenue__c=7000000;
        prop.Bank_Address__c='jchjshdfcshdghdgc';
        prop.Bank_Name__c='SBI';
        prop.Base_Currency__c=Label.Base_Foreign_Currency;
        prop.Beneficiary_Name__c='jsfddsgdf';
        prop.Branch_Name__c='jcjdhjshfs';
        prop.logo__c='http://www.abc.net.au/news/image/3627068-3x2-340x227.jpg';   
        insert prop;
        
        Lease__c ls = new Lease__c();
        ls.name ='abc';
        ls.Late_Payment_Interest__c = 3;
        ls.Lease_Start_Date__c = system.today();
        ls.Tenant__c= ac.id;
        ls.Property__c = prop.id;
        ls.Lease_Tenure_Mths__c = 4;
        ls.Lease_Tenure_Days__c='17';
        insert ls;
        
        Rent_Roll__c rr = new Rent_Roll__c();
        rr.property__c= prop.id;
        rr.Name = 'abc';
        rr.Billing_Type__c='Rent';
        insert rr;
        
        Invoice__c inv = new Invoice__c();
        inv.Name = 'abc';
        inv.Voided__c = false;
        inv.Status__c = 'Paid';
        inv.Property_Name__c =prop.id;
        inv.Lease__c =ls.id;
        inv.Tenant_Name__c = ac.id;
        inv.Rent_Roll__c=rr.id;
        inv.Total_Amount_Local__c=2000;
        inv.Invoice_Date__c=system.today();
        insert inv;
        
        
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
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.id;
        lu.Unit__c = unt.id;
        insert lu; 

        Deposit__c dep=new Deposit__c();
        dep.name='abcd';
        dep.status__c='Outstanding';
        dep.Lease_Unit__c=lu.id;
        dep.Amount_Paid__c=2000.00;
        dep.Deposit_Amount__c=400000;
        dep.Deposit_Type__c='Renovation';
        dep.Currency_code__c=Label.Base_Foreign_Currency;
        dep.Exchange_Rate__c=12;
        dep.Deposit_Amount_local__c=2000;
        dep.Deposit_Amount_Foreign__c=3000;
        dep.Description__c='chsgdhdchhdgdhhcgh';
        insert dep;
                
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Lease_Unit__c = lu.id;
        lc.Charge_Type__c ='service';
        lc.Name = 'abc';
        lc.Billing_Frequency__c ='Monthly';
        lc.Billing_Terms__c ='prorate';
        lc.Due_Month_Formula__c ='-6';
        lc.Type__c ='GTO';
        insert lc;
        
        Invoice_Line_Item__c il = new Invoice_Line_Item__c();
        il.Invoice__c = inv.id;
        il.Invoice_old__c = inv.id;
        il.Lease_Charge__c=lc.id;
        il.Due_Days__c=15;
        il.start_date__c=System.today();
        il.End_Date__c=System.today().addMonths(1);
        insert il;
        
       
        
        Cash_Receipt__c cr = new Cash_Receipt__c();
        cr.Payment_Currency__c =Label.Default_Currency;
        cr.Payment_Mode__c = 'Cash';
        cr.Payment_Date__c =system.today();
        cr.Property__c = prop.id;
        cr.Tenant__c = ac.id;
        insert cr;
        
        
        Cash_Detail__c cd = new Cash_Detail__c();
        cd.Amount_Paid__c =100;
        cd.Cash_Receipt__c = cr.id;
        cd.Void__c = false;
        cd.Invoice__c = inv.id;
        
        Cash_Detail__c cd2 = new Cash_Detail__c();
        cd2.Amount_Paid__c =100;
        cd2.Cash_Receipt__c = cr.id;
        cd2.Void__c = false;
        cd2.Currency_Code__c=Label.Base_Foreign_Currency;
        cd2.Deposit__c = dep.id;
        
        List<Cash_Detail__c> cdList=new List<Cash_Detail__C>();
        cdList.add(cd);
        cdList.add(cd2);
        
        insert cdList;
        
        
        
        Test.setCurrentPageReference(new PageReference('Page.AccountStatementPDF'));
        System.currentPageReference().getParameters().put('pId',prop.id);
        System.currentPageReference().getParameters().put('tId',ac.id);
       
        
        
        AccountStatementPDFCntrl accpdf = new AccountStatementPDFCntrl();
        accpdf.pro = prop;
        accpdf.tenant = ac;
        accpdf.getDepoInvList();
        
        //-----------------------------Changing Billing type in Rent roll to Monthly-----------------
        rr.Billing_Type__c='Monthly';
        Test.startTest();
        update rr;
        accpdf.getDepoInvList();  
        
        //-----------------------------Changing Billing type in Rent roll to Debit Note-----------------
        rr.Billing_Type__c='Debit Note';
        
        update rr;
        accpdf.getDepoInvList();
        
        //-----------------------------Changing Billing type in Rent roll to Credit Note-----------------
        rr.Billing_Type__c='Credit Note';
        update rr;
        accpdf.getDepoInvList();
        
        //-----------------------------Changing Billing type in Rent roll to Ad-Hoc Invoice-----------------
        rr.Billing_Type__c='Ad-Hoc Invoice';
        update rr;
        accpdf.getDepoInvList();
        
        //-----------------------------Changing Billing type in Rent roll to Late Charge-----------------
        rr.Billing_Type__c='Late Charge';
        update rr;
        accpdf.getDepoInvList();
        Test.stopTest();
    }
}