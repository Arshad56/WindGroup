@isTest()
public class ResurveyController_Test {
    static Lease_Unit__c lu;
    static Lease__c ls;
    static Lease_Charges__c lc;
    static Rent_Schedules__c rs;
    static Applicable_Charges__c ac;
    static Units__c unt;
    static Id br1lcId;
    static Id br2lcId;
    static void init(){
        
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
         unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.NLA_SQF__c = 100;
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
        lc1.Type__c ='By Area';
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
        lc2.Type__c='By Area';
        lc2.charge_Rate__c = 5;
        lc2.Charge_Type__c = 'Advance Rental';
        //lc2.Currency_Code__c = Label.Default_Currency;
        lc2.Charge_Method__c = 'Daily Rate';
        lcList.add(lc2);
        lc2.Billing_Terms__c = 'Prorate';
        insert lcList;
        
       
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        List<Rent_Schedules__c> rsList = new List<Rent_Schedules__c>();
        rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'Rent Roll Generated';
        rs.Lease_Charge__c = lc.Id;
        rs.Base_Rent_LC__c = lc.Id;
        rs.Start_Date__c = system.today()+10;
        rs.End_Date__c = system.today().addMonths(1)-1;
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        rs.Lease_Unit__c = lu.Id;
        rsList.add(rs);
        
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'Rent Roll Generated';
        rs1.Lease_Charge__c = lc1.Id;
        rs1.Base_Rent_LC__c = lc1.Id;
        rs1.Start_Date__c = system.today();
        rs1.End_Date__c = system.today().addMonths(1)-10;
        rs1.Rent_Roll__c = rentRoll.Id;
        rs1.Approved__c = true;
        rs1.Lease_Unit__c = lu.Id;
        rsList.add(rs1);
        
        Rent_Schedules__c rs11 = new Rent_Schedules__c();
        rs11.Unit__c = unt.Id;
        rs11.Status__c = 'Rent Roll Generated';
        rs11.Lease_Charge__c = lc1.Id;
        rs11.Base_Rent_LC__c = lc1.Id;
        rs11.Start_Date__c = system.today().addMonths(1)-9;
        rs11.End_Date__c = system.today().addMonths(1)+10;
        rs11.Rent_Roll__c = rentRoll.Id;
        rs11.Approved__c = true;
        rs11.Lease_Unit__c = lu.Id;
        rsList.add(rs11);
        
        Rent_Schedules__c rs2 = new Rent_Schedules__c();
        rs2.Unit__c = unt.Id;
        rs2.Status__c = 'Rent Roll Generated';
        rs2.Lease_Charge__c = lc1.Id;
        rs2.Base_Rent_LC__c = lc1.Id;
        rs2.Start_Date__c = system.today().addYears(1)-30;
        rs2.End_Date__c = rs2.Start_Date__c+50;
        rs2.Rent_Roll__c = rentRoll.Id;
        rs2.Approved__c = true;
        rs2.Lease_Unit__c = lu1.Id;
        rsList.add(rs2);
        
        insert rsList;
        
         PopulateBaseRentRsController.pplBaseRent(lc.Id,'Advance Rental'); 
        
         PopulateBaseRentRsController.pplBaseRent(lc1.Id,'Advance Rental'); 
        
         PopulateBaseRentRsController.pplBaseRent(lc2.Id,'Advance Rental'); 
        
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
        lc.Currency_Code__c = label.Base_Foreign_Currency;
        lc.Charge_Method__c = 'Daily Rate';
        lc.Billing_Terms__c = 'Prorate';
        insert lc;
        
        
    }
    static testMethod void RunTest() {
        init();
        List<Rent_Schedules__c> listRs = new List<Rent_Schedules__c>();
        for(Rent_Schedules__c rs: [select Id,Status__c,Type__c,Base_Rent_RS_1__c,Base_Rent_RS_2__c from Rent_Schedules__c]){
            rs.Status__c = 'Rent Roll Generated';
            listRs.add(rs);
        }
        update listRs;
        Apexpages.currentPage().getParameters().put('unitId',unt.Id);
        Test.startTest();
        ResurveyController rc = new ResurveyController();      
        
        rc.refresh();
        
        rc.unitOnUI.NLA_SQF__c = 200;
        rc.unitOnUI.Start_Date__c = System.today();
        
        rc.next();
        rc.search();
        rc.back();
        
        Apexpages.currentPage().getParameters().put('luId',[select Id from Lease_Unit__c limit 1].Id);
        Apexpages.currentPage().getParameters().put('toAddRow',1+'');
        Apexpages.currentPage().getParameters().put('toDelRow',1+'');
         rc.search();
        rc.addRow();
        
        rc.delRow();
        rc.generate();
        
        Test.stopTest();
    }
}