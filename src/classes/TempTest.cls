@isTest
public class TempTest {
    static Lease_Unit__c lu;
    static Lease__c ls;
    static Lease_Charges__c lc;
    static Rent_Schedules__c rs;
    static Applicable_Charges__c ac;
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
        unt.Charge_Method__c = 'Monthly Rate - L';
        insert unt;
        
        ac = new Applicable_Charges__c();
        ac.Name = 'MEPE (CT Meter)';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Type__c = 'Gov Meter';
        ac.Property__c = prop.Id;
        ac.Charge_Rate__c = 125; 
        ac.Currency_Code__c  = Label.Default_Currency;
        ac.Type__c = 'Meter Units';
        ac.Charge_Method__c = 'Monthly Rate - L';
        insert ac;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.GTO_Billed__c = 'By Lease Unit';
        ls.Property__c = prop.Id;
        insert ls;
        List<Lease_Unit__c> luList = new List<Lease_Unit__c>();
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_Start_Date__c = system.today()-1;
        lu.Lease_End_Date__c = system.today().addYears(1);
        luList.add( lu);
         
        Lease_Unit__c lu1 = new Lease_Unit__c();
        lu1.Lease_Agreement_No__c = ls.Id;
        lu1.Unit__c = unt.Id;
        lu1.Lease_Start_Date__c = system.today().addYears(1)+1;
        lu1.Lease_End_Date__c = system.today().addYears(2);
        luList.add( lu1);
        insert luList;
        
        List<Lease_Charges__c> lcList = new List<Lease_Charges__c>();
        
        lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today()-1;
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='GTO (Higher)';
        lc.Commercial_Tax_Apply__c = true;
        lc.Charge_Type__c = 'GTO Rent';
        lc.Charge__c = ac.Id;
        //lc.Currency_Code__c = label.Base_Foreign_Currency;
        lc.Charge_Method__c = 'Daily Rate';
        lc.Billing_Terms__c = 'Prorate';
        lcList.add(lc);
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1)-10;
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='GTO';
        lc1.charge_Rate__c = 5;
        lc1.Charge_Type__c = 'Advance Rental';
        //lc1.Currency_Code__c = Label.Default_Currency;
        lc1.Charge_Method__c = 'Daily Rate';
        lc1.Billing_Terms__c = 'Prorate';
        lcList.add(lc1);
        
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'Commercial Tax';
        lc2.Start_Date__c = lc1.End_Date__c +1;
        lc2.End_Date__c = lc1.End_Date__c.addYears(1);
        lc2.Lease_Unit__c = lu.Id;
        lc2.Type__c='GTO';
        lc2.charge_Rate__c = 5;
        lc2.Charge_Type__c = 'Advance Rental';
        //lc2.Currency_Code__c = Label.Default_Currency;
        lc2.Charge_Method__c = 'Daily Rate';
        lcList.add(lc2);
        lc.Billing_Terms__c = 'Non-prorate';
        insert lcList;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;                
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        List<Rent_Schedules__c> rsList = new List<Rent_Schedules__c>();
        rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Base_Rent_LC__c = lc.Id;
        rs.Start_Date__c = Date.newInstance(2016, 4, 17);
        rs.End_Date__c = Date.newInstance(2016, 5, 14);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        rs.Lease_Unit__c = lu.Id;
        rsList.add(rs);
        
        insert rsList;
        
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.From_Date__c = system.today()+1;
        pt.To_Date__c = system.today()+4;
        pt.POS_Id__c = 'null-POS-0001';
        pt.Rent_Schedule__c = rs.Id;
        insert pt;
    }
    static void initByL(){
      init();
      
      ls.GTO_Billed__c = 'By Lease (Lease Unit)';
        update ls;
        
        update rs;
        //Test.stopTest();
    }
    static testMethod void runInserRSByLease1() {
      Utility.doGTO = false;
        initByL();
        
        ls.GTO_Billed__c = 'By Lease Unit';
        update ls;
        
        Utility.doGTO = true;
        Test.startTest();
        
        update rs;
        
        Test.stopTest();
    }
}