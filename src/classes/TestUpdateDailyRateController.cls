@isTest
Class TestUpdateDailyRateController{
    static TestMethod void TestMonthly(){
        
        
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
		
		Lease_Plan__c lp = new Lease_Plan__c();
		lp.unit__c = unt.Id;
		lp.Status_1__c = 'Vacant';
		lp.Start_Date__c = system.today()+1;
		lp.End_Date__c = system.today().addMonths(1);
		insert lp;
		
		Apexpages.currentPage().getParameters().put('unitIds',unt.Id);
		Apexpages.currentPage().getParameters().put('month',''+system.today().month());
		Apexpages.currentPage().getParameters().put('year',''+system.today().year());
		UpdateDailyRateController dr = new UpdateDailyRateController();
		dr.startDate = lp.Start_Date__c;
		dr.endDate = lp.End_Date__c;
		dr.bulkUpdateBy = 'Absolute';
		dr.bulkUpdateValue = 5;
		dr.updateRate();
		dr.bulkUpdateBy = 'Incremental Change';
		dr.updateRate();
		dr.bulkUpdateBy = '% Rate Change';		
		dr.updateRate();
		
		List<SelectOption> monthList = dr.getMonthList();
		List<SelectOption> yearList = dr.getyearList();
    }
    static TestMethod void TestDaily(){
        
        
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
        unt.Charge_Method__c = 'Daily Rate';
        insert unt;
		
		Lease_Plan__c lp = new Lease_Plan__c();
		lp.unit__c = unt.Id;
		lp.Start_Date__c = system.today()+1;
		lp.Status_1__c = 'Vacant';
		lp.End_Date__c = system.today().addMonths(1);
		insert lp;
		
		Apexpages.currentPage().getParameters().put('unitIds',unt.Id);
		Apexpages.currentPage().getParameters().put('month',''+system.today().month());
		Apexpages.currentPage().getParameters().put('year',''+system.today().year());
		UpdateDailyRateController dr = new UpdateDailyRateController();
		dr.startDate = lp.Start_Date__c;
		dr.endDate = lp.End_Date__c;
		dr.bulkUpdateBy = 'Absolute';
		dr.bulkUpdateValue = 5;
		dr.updateRate();
		dr.bulkUpdateBy = 'Incremental Change';
		dr.updateRate();
		dr.bulkUpdateBy = '% Rate Change';		
		dr.updateRate();
    }
}