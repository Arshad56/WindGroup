@isTest
private class ChangeLeaseStartDate_Test {
            
    Public static Id leaseUnitId = null;
    Public static boolean isNegativeTestCase = false;
	
	@isTest
	private static void testNormalChgLeaseStartDate() {        
        getChangeLeaseStartDateExtension(system.today().addMonths(1), null, null, false);
	}
    
    @isTest
	private static void testChgLeaseStartDateByDifferentLeaseUnitLeaseEndDate() { 
        getChangeLeaseStartDateExtension(system.today().addMonths(1), null, system.today().addDays(15), true);
    }
     
    @isTest
	private static void testValidationEmptyLeaseStartDate() {    
      getChangeLeaseStartDateExtension(null, null, null, false);
      System.assert(getApexPageErrorMsg('Please Select Lease Start Date.'));         
    }
    
    @isTest
	private static void testValidationGenerateRentSchedule() {
        isNegativeTestCase = true;
        ChangeLeaseStartDateController clscontroller = new ChangeLeaseStartDateController();
        List <Lease__c> oldleaseList = [select Id, Lease_Start_Date__c, Lease_End_Date__c from Lease__c where Id =:createLeaseTestData().Id];
        List <Lease__c> newleaseList = new List<Lease__c>();
        
        for(Lease__c lease: oldleaseList){           
            lease.Lease_Start_Date__c = system.today().addMonths(1);
			lease.Change_Lease_Start_Date__c =true;
        } 
     
        try{
            update oldleaseList;
            isNegativeTestCase = false;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Invoice or Transaction is created, changing of Lease Start Date is not allowed'))? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
	private static void testValidationEditLeaseStartDate() {
        ChangeLeaseStartDateController clscontroller = new ChangeLeaseStartDateController();
        List <Lease__c> oldleaseList = [select Id, Lease_Start_Date__c, Lease_End_Date__c from Lease__c where Id =:createLeaseTestData().Id];
        
        for(Lease__c lease: oldleaseList){           
            lease.Lease_Start_Date__c = system.today().addMonths(1); 
        }     
        try{
           update oldleaseList; 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please click on the Change Lease Start Date button for Lease Start Date modification.'))? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
	private static void testValidationUpdateLeaseStartDate() {
        try{
             getChangeLeaseStartDateExtension(system.today().addMonths(15), null, null, true);
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('###Change Lease Start Date Exception Occured:'))? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
    }  
    
    private static void getChangeLeaseStartDateExtension(Date leaseStartDate, Date leaseUnitStartDate, Date leaseUnitEndDate, boolean getLeaseUnit){   
         Lease__c leaseTestData = createLeaseTestData();
         if(getLeaseUnit){
            List <Lease_Unit__c> leaseUnitList = [select Id, Lease_Start_Date__c, Lease_End_Date__c from Lease_Unit__c where Id =:leaseUnitId];

            if(leaseUnitStartDate != null)
                leaseUnitList.get(0).Lease_Start_Date__c = leaseUnitStartDate;
            if(leaseUnitEndDate != null)
                leaseUnitList.get(0).Lease_End_Date__c = leaseUnitEndDate;
            update leaseUnitList;
              
         }

        PageReference pageRef = Page.ChangeLeaseStartDate;
        pageRef.getParameters().put('selectedLease', String.valueOf(leaseTestData.Id));
        pageRef.getParameters().put('tenureMth', String.valueOf(leaseTestData.Lease_Tenure_Mths__c));
        pageRef.getParameters().put('tenureDay', String.valueOf(leaseTestData.Lease_Tenure_Days__c));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(leaseTestData);
        ChangeLeaseStartDate_Extension changeDateExt = new ChangeLeaseStartDate_Extension(sc);
        changeDateExt.lease.Lease_Start_Date__c = leaseStartDate; 
        changeDateExt.checkData();
    }
    
    private static boolean getApexPageErrorMsg(String text)
    {
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean messageFound = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains(text)){ messageFound = true; break;}
        }
      return messageFound;
    }
    
    private static Lease__c createLeaseTestData(){
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        
        
        Property__c prop = new Property__c();
        prop.Name = 'TestTenant';
        prop.short_code__c='TT';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addMonths(3);
        unt.Charge_Method__c = 'Monthly Rate - CL';
        insert unt;
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c;
        lp.End_Date__c = Date.newInstance(unt.Start_Date__c.year(),unt.Start_Date__c.month(),Date.DaysInMonth(unt.Start_Date__c.Year(),unt.Start_Date__c.Month()));
        for(Date dts=unt.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
        }
        insert lp;
        
        
        Lease__c ls = new Lease__c();
        ls.Tenant__c = acc.Id;
        ls.Lease_Start_Date__c = system.today();
        ls.Lease_Tenure_Mths__c = 2;
        ls.Lease_Tenure_Days__c = '0';
        ls.Lease_Status__c = 'New';
        ls.GTO_Billed__c = 'By Lease Unit';
        ls.Property__c = prop.Id;
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu.Lease_Unit_Status__c = 'New';
        lu.Unit__c = unt.Id;
        insert lu;
        
        leaseUnitId = lu.Id;
  
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = lu.Lease_Start_Date__c;
        lc.End_Date__c = lu.Lease_End_Date__c;
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.charge_type__c='Advance Rental'; 
        lc.Charge_Rate__c = 4.15;
        lc.Commercial_Tax_Apply__c = true;
        insert lc;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        rentRoll.Billing_Type__c='Monthly';
        insert rentRoll;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
		rs.Lease_Unit__c = lu.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        if(isNegativeTestCase){
            Rent_Roll_Detail__c rrd = new Rent_Roll_Detail__c();
            rrd.Unit__c = rs.Unit__c;
            rrd.Lease_Unit__c = lu.Id;
            rrd.Status__c = 'Pending';
            rrd.Lease_Charge__c = rs.Lease_Charge__c;
            rrd.Start_Date__c = rs.Start_Date__c;
            rrd.End_Date__c = rs.End_Date__c;
            rrd.Rent_Roll__c = rs.Rent_Roll__c;
            rrd.Approved__c = rs.Approved__c;
            insert rrd;   
        
            rs.Rent_Roll_Detail__c = rrd.Id;
            update rs;
        }
      
        return ls;
    }
}