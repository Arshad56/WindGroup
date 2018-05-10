@isTest
Class TestGenerateRentRollController{
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
        lc.Commercial_Tax_Apply__c = false;
        insert lc;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Approved__c = false;
        rs.Billing_Date__c = system.today();
        rs.Amount__c = 100;
        rs.Currency_Code__c = Label.Default_Currency;
        rs.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name=:label.RentScheduleRentRecordType][0].Id;
        insert rs;
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'In-Tenancy';
        rs1.Lease_Charge__c = lc.Id;
        rs1.Start_Date__c = system.today().addMonths(1)+1;
        rs1.End_Date__c = system.today().addMonths(2);
        rs1.Approved__c = false;
        rs1.Billing_Date__c = system.today();
        rs1.Amount__c = 50;
        rs1.Currency_Code__c = Label.Default_Currency;
        rs1.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name=:label.RentScheduleMonthlyRecordType][0].Id;
        insert rs1;
        
        Test.StartTest();
        GenerateRentRollController grr = new GenerateRentRollController();
        grr.rentRoll.Comm_Tax_Applicable__c = 'No';
        grr.getbatchList();
        grr.getMonthList();
        grr.getYearList();
        grr.rentRoll.Property__c = prop.Id;
        grr.batch = Label.RentScheduleRentRecordType;
        grr.search();
        grr.selectAll = true;
        grr.selectAllToApprove();
        grr.refresh();
        grr.selectAll = true;
        grr.selectAllToApprove();
        grr.approve();
        grr.getchargeTypeList();
        
        GenerateRentRollController grr1 = new GenerateRentRollController();
        grr1.rentRoll.Comm_Tax_Applicable__c = 'No';
        grr1.getbatchList();
        grr1.getMonthList();
        grr1.getYearList();
        grr1.rentRoll.Property__c = prop.Id;
        grr1.batch = Label.RentScheduleMonthlyRecordType;
        grr1.search();
        grr1.selectAll = true;
        grr1.selectAllToApprove();
        grr1.refresh();
        grr1.selectAll = true;
        grr1.selectAllToApprove();
        grr1.approve();
        Test.stopTest();
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
        lc.charge_Type__c = 'GTO Rent';
        insert lc;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Approved__c = false;
        rs.Billing_Date__c = system.today();
        rs.Amount__c = 100;
        rs.Currency_Code__c = Label.Base_Foreign_Currency;
        rs.Transaction_Status__c = 'Applicable - Imported';
        rs.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name=:label.RentScheduleRentRecordType][0].Id;
        insert rs;
        Rent_Schedules__c rs1 = new Rent_Schedules__c();
        rs1.Unit__c = unt.Id;
        rs1.Status__c = 'In-Tenancy';
        rs1.Lease_Charge__c = lc.Id;
        rs1.Start_Date__c = system.today().addMonths(1)+1;
        rs1.End_Date__c = system.today().addMonths(2);
        rs1.Approved__c = false;
        rs1.Billing_Date__c = system.today();
        rs1.Currency_Code__c = Label.Base_Foreign_Currency;
        rs1.Amount__c = 50;
        rs1.Transaction_Status__c = 'Applicable - Imported';
        rs1.recordTypeId = [Select id from RecordType where sobjectType='Rent_Schedules__c' and name=:label.RentScheduleMonthlyRecordType][0].Id;
        insert rs1;
        
        Exchange_Rate__c er = new Exchange_Rate__c();
        er.Currency_Code__c = Label.Base_Foreign_Currency;
        er.Conversion_Rate__c = 1400;
        er.Start_Date_Time__c = system.now();
        er.Applicable_Function__c = 'Operations';
        insert er;
        
        Test.StartTest();
        GenerateRentRollController grr = new GenerateRentRollController();
        grr.rentRoll.Comm_Tax_Applicable__c = 'Yes';
        grr.getbatchList();
        grr.getMonthList();
        grr.getYearList();
        grr.rentRoll.Property__c = prop.Id;
        grr.rentRoll.Currency_Code__c = Label.Base_Foreign_Currency;
        grr.batch = 'GTO Rent';
        grr.currencyCodeChange();
        grr.updateConversionRate();
        grr.search();
        
        grr.doNext();
        grr.doPrevious();
        grr.moveLast();
        grr.moveFirst();
        
        grr.selectAll = true;
        grr.selectAllToApprove();
        grr.refreshExRate();
        grr.selectAll = true;
        grr.selectAllToApprove();
        grr.refresh();
        grr.selectAll = true;
        grr.selectAllToApprove();
        grr.approve();
        grr.getchargeTypeList();
        
        try{
            grr.gtorentRoll.Currency_Code__c = label.Default_Currency;
            grr.gtoRentRoll.Property__c = prop.Id;
            grr.searchGTO();
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}