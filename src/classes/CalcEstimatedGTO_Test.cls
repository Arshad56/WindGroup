/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CalcEstimatedGTO_Test {
	private static String GTOHIGHERTYPE = 'GTO (Higher)';
	private static String GTOTYPE = 'GTO';
	private static String GTOSUMTYPE = 'GTO (Sum)';
	
	// constant variables for GTO Billed field in Lease__c
	private static final String GTOBYLEASEUNIT = 'By Lease Unit';
	private static final String GTOBYLEASELEASEUNIT = 'By Lease (Lease Unit)';
	private static final String GTOBYLEASESUMMARY = 'By Lease (Summary)';
	
	// Constant variables for Currency Code
	private static final String MMKCURRENCYCODE = Label.Default_Currency;
	private static final String USDCURRENCYCODE = Label.Base_Foreign_Currency;
	
    @isTest static void TestEstGTOAmountWithTierAndCumulative() {
        // TO DO: implement unit test
        Rent_Schedules__c gtoRS = createRSTestData(true, true, 5000, GTOHIGHERTYPE, null);
        Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_GTO_Amount__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_GTO_Amount__c, 6878.03);
    }
    
    @isTest static void TestEstGTOAmountWithTierAndwithoutCumulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, false, 5000, GTOHIGHERTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_GTO_Amount__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_GTO_Amount__c, 5878.03);
    }
    
    @isTest static void TestEstGTOAmountWithoutTierAndCumulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(false, false, 5000, GTOHIGHERTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_GTO_Amount__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_GTO_Amount__c, 7347.54);
    }
    
    @isTest static void TestEstGTOSumTypeWOCapWTierAndCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, true, 5000, GTOSUMTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 11878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 11878.03);
        System.assertEquals(result.Estimated_GTO_Rent__c, 6878.03);
    }
    
    @isTest static void TestEstGTOSumTypeWOCapWTierAndWOCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, false, 5000, GTOSUMTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 10878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 10878.03);
        System.assertEquals(result.Estimated_GTO_Rent__c, 5878.03);
    }
    
    @isTest static void TestEstGTOSumTypeWOCapWOTierAndWOCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(false, false, 5000, GTOSUMTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 12347.54);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 12347.54);
        System.assertEquals(result.Estimated_GTO_Rent__c, 7347.54);
    }
    
    @isTest static void TestEstGTOHigherTypeWOCapWTierAndCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, true, 5000, GTOHIGHERTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 6878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 6878.03);
        System.assertEquals(result.Estimated_GTO_Rent__c, 1878.03);
    }
    
    @isTest static void TestEstGTOHigherTypeWOCapWTierAndWOCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, false, 5000, GTOHIGHERTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 5878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 5878.03);
        System.assertEquals(result.Estimated_GTO_Rent__c, 878.03);
    }
    
    @isTest static void TestEstGTOHigherTypeWOCapWOTierAndWOCummulative(){
    	Rent_Schedules__c gtoRS = createRSTestData(false, false, 5000, GTOHIGHERTYPE, null);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 7347.54);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 7347.54);
        System.assertEquals(result.Estimated_GTO_Rent__c, 2347.54);
    }
    
    @isTest static void TestEstGTOAboveCap(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, true, 5000, GTOHIGHERTYPE, 12);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 6878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 6000);
        System.assertEquals(result.Estimated_GTO_Rent__c, 1000);
    }
    
    @isTest static void TestEstGTOBelowCap(){
    	Rent_Schedules__c gtoRS = createRSTestData(true, true, 5000, GTOHIGHERTYPE, 15);
    	Test.startTest();
        insert gtoRS;
        gtoRS.Total_Estimated_GTO__c = 50000000;
        update gtoRS;
        Test.stopTest();
        Rent_Schedules__c result = [Select Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRS.Id];
        System.assertEquals(result.Estimated_Gross_Rent__c, 6878.03);
        System.assertEquals(result.Estimated_Gross_Rent_Cap__c, 6878.03);
        System.assertEquals(result.Estimated_GTO_Rent__c, 1878.03);
    }
    
    
    @isTest static void TestEstGTOByLeaseSummaryWOTier(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASESUMMARY, false, false, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Estimated_GTO_Amount__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        System.assertEquals(26451.14, result.get(0).Estimated_Gross_Rent__c);
        System.assertEquals(26451.14, result.get(0).Estimated_Gross_Rent_Cap__c);
        System.assertEquals(15757.34, result.get(0).Estimated_GTO_Rent__c);
    }
    
    @isTest static void TestEstGTOByLeaseSummaryWTierWOCummulative(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASESUMMARY, true, false, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Estimated_GTO_Amount__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        System.assertEquals(21160.91, result.get(0).Estimated_Gross_Rent__c);
        System.assertEquals(21160.91, result.get(0).Estimated_Gross_Rent_Cap__c);
        System.assertEquals(10467.11, result.get(0).Estimated_GTO_Rent__c);
    }
    
    @isTest static void TestEstGTOByLeaseSummaryWTierWCummulative(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASESUMMARY, true, true, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Estimated_GTO_Amount__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        System.assertEquals(22160.91, result.get(0).Estimated_Gross_Rent__c);
        System.assertEquals(22160.91, result.get(0).Estimated_Gross_Rent_Cap__c);
        System.assertEquals(11467.11, result.get(0).Estimated_GTO_Rent__c);
    }
    
    
    @isTest static void TestEstGTOByLeaseLuWOTier(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASELEASEUNIT, false, false, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Id, Unit__r.Name, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        Integer checkCounter = 0;
        for(Rent_Schedules__c rs : result){
        	if(rs.Unit__r.Name.equals('TestUnit01')){
        		System.assertEquals(26451.14, result.get(0).Estimated_Gross_Rent__c);
		        System.assertEquals(26451.14, result.get(0).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(6060.27, result.get(0).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit02')){
        		System.assertEquals(26451.14, result.get(1).Estimated_Gross_Rent__c);
		        System.assertEquals(26451.14, result.get(1).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(4848.53, result.get(1).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit03')){
        		System.assertEquals(26451.14, result.get(2).Estimated_Gross_Rent__c);
		        System.assertEquals(26451.14, result.get(2).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(4848.53, result.get(2).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else{
        		System.assert(false);
        	}
        }
        if(checkCounter<gtoRsList.size()){
        	System.assert(false);
        }
    }
    
    @isTest static void TestEstGTOByLeaseLuWTierWOCummulative(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASELEASEUNIT, true, false, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Unit__r.Name, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        Integer checkCounter = 0;
        for(Rent_Schedules__c rs : result){
        	if(rs.Unit__r.Name.equals('TestUnit01')){
        		System.assertEquals(21160.91, result.get(0).Estimated_Gross_Rent__c);
		        System.assertEquals(21160.91, result.get(0).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(4025.65, result.get(0).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit02')){
        		System.assertEquals(21160.91, result.get(1).Estimated_Gross_Rent__c);
		        System.assertEquals(21160.91, result.get(1).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3220.73, result.get(1).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit03')){
        		System.assertEquals(21160.91, result.get(2).Estimated_Gross_Rent__c);
		        System.assertEquals(21160.91, result.get(2).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3220.73, result.get(2).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else{
        		System.assert(false);
        	}
        }
        if(checkCounter<gtoRsList.size()){
        	System.assert(false);
        }
    }
    
    @isTest static void TestEstGTOByLeaseLuWTierWCummulative(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASELEASEUNIT, true, true, GTOHIGHERTYPE, null);
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Unit__r.Name, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        Integer checkCounter = 0;
        for(Rent_Schedules__c rs : result){
        	if(rs.Unit__r.Name.equals('TestUnit01')){
        		System.assertEquals(22160.91, result.get(0).Estimated_Gross_Rent__c, 'Expected: ' + 21160.91 + ' Actual: ' + result.get(0).Estimated_Gross_Rent__c);
		        System.assertEquals(22160.91, result.get(0).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(4410.25, result.get(0).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit02')){
        		System.assertEquals(22160.91, result.get(1).Estimated_Gross_Rent__c);
		        System.assertEquals(22160.91, result.get(1).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3528.43, result.get(1).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit03')){
        		System.assertEquals(22160.91, result.get(2).Estimated_Gross_Rent__c);
		        System.assertEquals(22160.91, result.get(2).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3528.43, result.get(2).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else{
        		System.assert(false);
        	}
        }
        if(checkCounter<gtoRsList.size()){
        	System.assert(false);
        }
    }
    
    @isTest static void TestEstGTOByLeaseSummaryAboveCap(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASESUMMARY, true, true, GTOSUMTYPE, new List<decimal> {20});
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Estimated_GTO_Amount__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        System.assertEquals(32854.71, result.get(0).Estimated_Gross_Rent__c);
        System.assertEquals(14258.40, result.get(0).Estimated_Gross_Rent_Cap__c);
        System.assertEquals(3564.60, result.get(0).Estimated_GTO_Rent__c);
    }
    
    
    @isTest static void TestEstGTOByLeaseLuAboveCap(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASELEASEUNIT, true, true, GTOSUMTYPE, new List<decimal> {15, 25, 10});
        gtoRsList.get(0).Total_Estimated_GTO__c = 180000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Unit__r.Name, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        Integer checkCounter = 0;
        for(Rent_Schedules__c rs : result){
        	if(rs.Unit__r.Name.equals('TestUnit01')){
        		System.assertEquals(32854.71, result.get(0).Estimated_Gross_Rent__c);
		        System.assertEquals(11790.6, result.get(0).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(421.83, result.get(0).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit02')){
        		System.assertEquals(32854.71, result.get(1).Estimated_Gross_Rent__c);
		        System.assertEquals(11790.6, result.get(1).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(337.49, result.get(1).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit03')){
        		System.assertEquals(32854.71, result.get(2).Estimated_Gross_Rent__c);
		        System.assertEquals(11790.6, result.get(2).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(337.49, result.get(2).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else{
        		System.assert(false);
        	}
        }
        if(checkCounter<gtoRsList.size()){
        	System.assert(false);
        }
    }
    
    @isTest static void TestEstGTOByLeaseSummaryBelowCap(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASESUMMARY, true, true, GTOSUMTYPE, new List<decimal> {100});
        gtoRsList.get(0).Total_Estimated_GTO__c = 90000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Estimated_GTO_Amount__c, Total_Estimated_GTO__c, Total_Estimated_GTO_Converted__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        System.assertEquals(22274.26, result.get(0).Estimated_Gross_Rent__c);
        System.assertEquals(22274.26, result.get(0).Estimated_Gross_Rent_Cap__c);
        System.assertEquals(11580.46, result.get(0).Estimated_GTO_Rent__c);
    }
    
    @isTest static void TestEstGTOByLeaseLuBelowCap(){
    	List<Rent_Schedules__c> gtoRsList = createLeaseAssociatedRSTestData(GTOBYLEASELEASEUNIT, true, true, GTOSUMTYPE, new List<decimal> {50,45,40});
        gtoRsList.get(0).Total_Estimated_GTO__c = 90000000;
        insert gtoRsList;
        Test.stopTest();
        List<Id> gtoRsId = new List<Id>();
        for(Rent_Schedules__c rs: gtoRsList){
        	gtoRsId.add(rs.Id);
        }
        List<Rent_Schedules__c> result = [Select Unit__r.Name, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c FROM Rent_Schedules__c WHERE Id = : gtoRsId];
        Integer checkCounter = 0;
        for(Rent_Schedules__c rs : result){
        	if(rs.Unit__r.Name.equals('TestUnit01')){
        		System.assertEquals(22274.26, result.get(0).Estimated_Gross_Rent__c);
		        System.assertEquals(22274.26, result.get(0).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(4453.84, result.get(0).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit02')){
        		System.assertEquals(22274.26, result.get(1).Estimated_Gross_Rent__c);
		        System.assertEquals(22274.26, result.get(1).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3563.31, result.get(1).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else if(rs.Unit__r.Name.equals('TestUnit03')){
        		System.assertEquals(22274.26, result.get(2).Estimated_Gross_Rent__c);
		        System.assertEquals(22274.26, result.get(2).Estimated_Gross_Rent_Cap__c);
		        System.assertEquals(3563.31, result.get(2).Estimated_GTO_Rent__c);
		        checkCounter++;
        	}
        	else{
        		System.assert(false);
        	}
        }
        if(checkCounter<gtoRsList.size()){
        	System.assert(false);
        }
    }
    
    private static Rent_Schedules__c createRSTestData(Boolean tier, Boolean cumulative, decimal baseRentAmt, String GTOLcType, decimal capValue){
    	
    	Date startDate = Date.newInstance(2017, 1, 1);
    	Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
    	Date lastDayOfMonth = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
        
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
        unt.NLA_SQF__c = 500;
        unt.Charge_Method__c = 'Monthly Rate - L';
        unt.Active__c = true;
        unt.Start_Date__c = startDate;
        unt.End_Date__c = startDate.addYears(2);
        insert unt;
        
        Lease__c ls = new Lease__c();
        ls.RecordTypeId = [select Id from RecordType where Name = 'LA' and SobjectType = 'Lease__c'].Id;
        ls.Tenant__c = acc.Id;
        ls.Lease_Start_Date__c = startDate;
        ls.Lease_Tenure_Mths__c = 12;
        ls.Property__c = prop.Id;
        ls.GTO_Billed__c = 'By Lease Unit';
        insert ls;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu.Unit__c = unt.Id;
        insert lu;
  
  		// create base rent lease charge
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'Base Rent';
        lc.Active__c = true;
        lc.Start_Date__c = lu.Lease_Start_Date__c;
        lc.End_Date__c = lu.Lease_End_Date__c;
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Frequency__c = 'Quarterly';
        lc.Type__c='By Area';
        lc.Charge_Type__c='Advance Rental'; 
        lc.Charge_Rate__c = 10.00;
        lc.Currency_Code__c = USDCURRENCYCODE;
        lc.Exchange_Rate__c = 1361;
        lc.Commercial_Tax_Apply__c = true;
        lc.Billing_Terms__c = 'Non-prorate';
        //lc.Charge_Start_Day__c = null;
        insert lc;
        
        // create GTO rent lease charge
        Lease_Charges__c gtoLC = new Lease_Charges__c();
        gtoLC.Name = 'GTO Rent';
        gtoLC.Active__c = true;
        gtoLC.Start_Date__c = lu.Lease_Start_Date__c;
        gtoLC.End_Date__c = lu.Lease_End_Date__c;
        gtoLC.Lease_Unit__c = lu.Id;
        gtoLC.Billing_Frequency__c='Monthly';
        gtoLC.Frequency__c = 'Quarterly';
        gtoLC.Type__c= GTOLcType;
        gtoLC.Charge_Type__c='GTO Rent'; 
        gtoLC.Charge_Rate__c = 20;
        gtoLC.Currency_Code__c = USDCURRENCYCODE;
        gtoLC.Exchange_Rate__c = 1361;
        gtoLC.Cumulative_for_each_Tier__c = cumulative;
        gtoLC.Tiered_Limit__c = tier;
        gtoLC.Tiered_Lower_Limit__c = 0;
        gtoLC.Tier_1_Upper_Limit__c = 20000;
        gtoLC.Tier_1_Rate__c = 0.2;
        gtoLC.Tier_2_Upper_Limit__c = 30000;
        gtoLC.Tier_2_Rate__c = 0.18;
        gtoLC.Tier_3_Rate__c = 0.16;
        gtoLC.Billing_Terms__c = 'Prorate';
        //gtoLC.Charge_Start_Day__c = '0';
        gtoLC.Commercial_Tax_Apply__c = true;
        insert gtoLC;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
		rs.Lease_Unit__c = lu.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = startDate;
        rs.End_Date__c = lastDayOfMonth;
        rs.Approved__c = false;
        insert rs;
        
        Rent_Schedules__c gtoRS = new Rent_Schedules__c();
        gtoRS.Unit__c = unt.Id;
		gtoRS.Lease_Unit__c = lu.Id;
        gtoRS.Status__c = 'In-Tenancy';
        gtoRS.Lease_Charge__c = gtoLC.Id;
        gtoRS.Start_Date__c = startDate;
        gtoRS.End_Date__c = lastDayOfMonth;
        gtoRS.Converted_Base_Rent__c = baseRentAmt;
        gtoRS.Approved__c = false;
        gtoRS.Cap_Value__c = capValue;
        gtoRS.Currency_Code__c = gtoLC.Currency_Code__c;
        gtoRS.Exchange_Rate__c = gtoLC.Exchange_Rate__c;
        gtoRS.Calc_No_of_Days_Pro_Rated_2__c = 100;
        
        RSTrigger_Helper.RSmap = null;
        return gtoRS;
    }
    
    private static List<Rent_Schedules__c> createLeaseAssociatedRSTestData(String GtoBilledType, Boolean tier, Boolean cumulative,String GTOLcType, List<decimal> capValue){
    	
    	List<Rent_Schedules__c> gtoRsList = new List<Rent_Schedules__c>();
    	Date startDate = Date.newInstance(2017, 1, 15);
    	Date endDate = Date.newInstance(2018, 1, 14);
    	//Date secStartDate = Date.newInstance(2018, 1, 15);
    	//Date secEndDate = Date.newInstance(2019, 1, 14);
    	Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
    	Date lastDayOfMonth = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
    	List<Units__c> unitList = new List<Units__c>();
    	List<Rent_Schedules__c> brRsList = new List<Rent_Schedules__c>();
        
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
        
        Lease__c ls = new Lease__c();
        ls.RecordTypeId = [select Id from RecordType where Name = 'LA' and SobjectType = 'Lease__c'].Id;
        ls.Tenant__c = acc.Id;
        ls.Lease_Start_Date__c = startDate;
        ls.Lease_Tenure_Mths__c = 24;
        ls.Property__c = prop.Id;
        ls.GTO_Billed__c = GtoBilledType;
        insert ls;
        
        //first lease unit
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit01';
        unt.NLA_SQF__c = 500;
        unt.Charge_Method__c = 'Monthly Rate - L';
        unt.Active__c = true;
        unt.Start_Date__c = startDate;
        unt.End_Date__c = startDate.addYears(2);
        unitList.add(unt);
        
        Units__c unt2 = new Units__c();
        unt2.Property__c = prop.Id;
        unt2.Level__c = lvl.Id;
        unt2.Name = 'TestUnit02';
        unt2.NLA_SQF__c = 400;
        unt2.Charge_Method__c = 'Monthly Rate - L';
        unt2.Active__c = true;
        unt2.Start_Date__c = startDate;
        unt2.End_Date__c = startDate.addYears(2);
        unitList.add(unt2);
        
        Units__c unt3 = new Units__c();
        unt3.Property__c = prop.Id;
        unt3.Level__c = lvl.Id;
        unt3.Name = 'TestUnit03';
        unt3.NLA_SQF__c = 400;
        unt3.Charge_Method__c = 'Monthly Rate - L';
        unt3.Active__c = true;
        unt3.Start_Date__c = startDate;
        unt3.End_Date__c = startDate.addYears(2);
        unitList.add(unt3);
        
        insert unitList;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu.Unit__c = unt.Id;
        insert lu;
  
  		// create first base rent lease charge
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'Base Rent';
        lc.Active__c = true;
        lc.Start_Date__c = lu.Lease_Start_Date__c;
        lc.End_Date__c = endDate;
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Frequency__c = 'Quarterly';
        lc.Type__c='By Area';
        lc.Charge_Type__c='Advance Rental'; 
        lc.Charge_Rate__c = 15.00;
        lc.Currency_Code__c = USDCURRENCYCODE;
        lc.Exchange_Rate__c = 1361;
        lc.Commercial_Tax_Apply__c = true;
        lc.Billing_Terms__c = 'Non-prorate';
        //lc.Charge_Start_Day__c = null;
        insert lc;
        
        // create GTO rent lease charge
        Lease_Charges__c gtoLC = new Lease_Charges__c();
        gtoLC.Name = 'GTO Rent';
        gtoLC.Active__c = true;
        gtoLC.Start_Date__c = lu.Lease_Start_Date__c;
        gtoLC.End_Date__c = endDate;
        gtoLC.Lease_Unit__c = lu.Id;
        gtoLC.Billing_Frequency__c='Monthly';
        gtoLC.Frequency__c = 'Quarterly';
        gtoLC.Type__c= GTOLcType;
        gtoLC.Charge_Type__c='GTO Rent'; 
        gtoLC.Charge_Rate__c = 20;
        gtoLC.Currency_Code__c = USDCURRENCYCODE;
        gtoLC.Exchange_Rate__c = 1361;
        gtoLC.Cumulative_for_each_Tier__c = cumulative;
        gtoLC.Tiered_Limit__c = tier;
        gtoLC.Tiered_Lower_Limit__c = 0;
        gtoLC.Tier_1_Upper_Limit__c = 20000;
        gtoLC.Tier_1_Rate__c = 0.2;
        gtoLC.Tier_2_Upper_Limit__c = 30000;
        gtoLC.Tier_2_Rate__c = 0.18;
        gtoLC.Tier_3_Rate__c = 0.16;
        gtoLC.Commercial_Tax_Apply__c = true;
        gtoLC.Billing_Terms__c = 'Prorate';
        if(capValue != null){
        	gtoLC.Cap_Applicable__c = true;
        	gtoLC.GTO_Cap__c = capValue.get(0);
        }
        //gtoLC.Charge_Start_Day__c = '0';
        insert gtoLC;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
		rs.Lease_Unit__c = lu.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = startDate;
        rs.Currency_Code__c = lc.Currency_Code__c;
        rs.Amount_Foreign__c = 7500;
        rs.Amount_Local__c = 10207500;
        rs.Calculated_Amount_Foreign__c = 7500;
        rs.Calculated_Amount_Local__c = 10207500;
        rs.End_Date__c = Date.newInstance(startDate.year(), startDate.month() + 1, startDate.day() - 1);
        rs.Approved__c = false;
        brRsList.add(rs);
        
        Rent_Schedules__c gtoRS = new Rent_Schedules__c();
        gtoRS.Unit__c = unt.Id;
		gtoRS.Lease_Unit__c = lu.Id;
        gtoRS.Status__c = 'In-Tenancy';
        gtoRS.Lease_Charge__c = gtoLC.Id;
        gtoRS.Start_Date__c = startDate;
        gtoRS.End_Date__c = lastDayOfMonth;
        gtoRS.Approved__c = false;
        if(capValue == null){
        	gtoRS.Cap_Value__c = null;
        }
        else{
        	gtoRS.Cap_Value__c = capValue.get(0);
        }
        gtoRS.Currency_Code__c = gtoLC.Currency_Code__c;
        gtoRS.Exchange_Rate__c = gtoLC.Exchange_Rate__c;
        gtoRS.Calc_No_of_Days_Pro_Rated_2__c = 100;
        gtoRsList.add(gtoRS);
        //second lease unit
        
        Lease_Unit__c lu2 = new Lease_Unit__c();
        lu2.Lease_Agreement_No__c = ls.Id;
        lu2.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu2.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu2.Unit__c = unt2.Id;
        insert lu2;
  
  		// create first base rent lease charge
        Lease_Charges__c lc2 = new Lease_Charges__c();
        lc2.Name = 'Base Rent';
        lc2.Active__c = true;
        lc2.Start_Date__c = lu2.Lease_Start_Date__c;
        lc2.End_Date__c = endDate;
        lc2.Lease_Unit__c = lu2.Id;
        lc2.Billing_Frequency__c='Monthly';
        lc2.Frequency__c = 'Quarterly';
        lc2.Type__c='By Area';
        lc2.Charge_Type__c='Advance Rental'; 
        lc2.Charge_Rate__c = 15.00;
        lc2.Currency_Code__c = USDCURRENCYCODE;
        lc2.Exchange_Rate__c = 1361;
        lc2.Commercial_Tax_Apply__c = true;
        lc2.Billing_Terms__c = 'Non-prorate';
        //lc2.Charge_Start_Day__c = null;
        insert lc2;
        
        Rent_Schedules__c rs2 = new Rent_Schedules__c();
        rs2.Unit__c = unt2.Id;
		rs2.Lease_Unit__c = lu2.Id;
        rs2.Status__c = 'In-Tenancy';
        rs2.Lease_Charge__c = lc2.Id;
        rs2.Start_Date__c = startDate;
        rs2.End_Date__c = Date.newInstance(startDate.year(), startDate.month() + 1, startDate.day() - 1);
        rs2.Approved__c = false;
        rs2.Amount_Foreign__c = 6000;
        rs2.Amount_Local__c = 8166000;
        rs2.Calculated_Amount_Foreign__c = 6000;
        rs2.Calculated_Amount_Local__c = 8166000;
        brRsList.add(rs2);
        
        
        // create GTO rent lease charge
        Lease_Charges__c gtoLC2 = new Lease_Charges__c();
        gtoLC2.Name = 'GTO Rent';
        gtoLC2.Active__c = true;
        gtoLC2.Start_Date__c = lu2.Lease_Start_Date__c;
        gtoLC2.End_Date__c = endDate;
        gtoLC2.Lease_Unit__c = lu2.Id;
        gtoLC2.Billing_Frequency__c='Monthly';
        gtoLC2.Frequency__c = 'Quarterly';
        gtoLC2.Type__c= GTOLcType;
        gtoLC2.Charge_Type__c='GTO Rent'; 
        gtoLC2.Charge_Rate__c = 20;
        gtoLC2.Currency_Code__c = USDCURRENCYCODE;
        gtoLC2.Exchange_Rate__c = 1361;
        gtoLC2.Cumulative_for_each_Tier__c = cumulative;
        gtoLC2.Tiered_Limit__c = tier;
        gtoLC2.Tiered_Lower_Limit__c = 0;
        gtoLC2.Tier_1_Upper_Limit__c = 20000;
        gtoLC2.Tier_1_Rate__c = 0.2;
        gtoLC2.Tier_2_Upper_Limit__c = 30000;
        gtoLC2.Tier_2_Rate__c = 0.18;
        gtoLC2.Tier_3_Rate__c = 0.16;
        gtoLC2.Commercial_Tax_Apply__c = true;
        gtoLC2.Billing_Terms__c = 'Prorate';
        //gtoLC2.Charge_Start_Day__c = '0';
        insert gtoLC2;
        
        if(GtoBilledType.equals(GTOBYLEASELEASEUNIT)){
        	Rent_Schedules__c gtoRS2 = new Rent_Schedules__c();
	        gtoRS2.Unit__c = unt2.Id;
			gtoRS2.Lease_Unit__c = lu2.Id;
	        gtoRS2.Status__c = 'In-Tenancy';
	        gtoRS2.Lease_Charge__c = gtoLC2.Id;
	        gtoRS2.Start_Date__c = startDate;
	        gtoRS2.End_Date__c = lastDayOfMonth;
	        gtoRS2.Approved__c = false;
	        if(capValue == null){
	        	gtoRS2.Cap_Value__c = null;
	        }
	        else{
	        	gtoRS2.Cap_Value__c = capValue.get(1);
	        }
	        gtoRS2.Currency_Code__c = gtoLC2.Currency_Code__c;
	        gtoRS2.Exchange_Rate__c = gtoLC2.Exchange_Rate__c;
	        gtoRS2.Calc_No_of_Days_Pro_Rated_2__c = 100;
	        gtoRsList.add(gtoRS2);
        }

        //third lease unit
        
        Lease_Unit__c lu3 = new Lease_Unit__c();
        lu3.Lease_Agreement_No__c = ls.Id;
        lu3.Lease_Start_Date__c = ls.Lease_Start_Date__c;
        lu3.Lease_End_Date__c = ls.Lease_End_Date__c;
        lu3.Unit__c = unt3.Id;
        insert lu3;
  
  		// create first base rent lease charge
        Lease_Charges__c lc3 = new Lease_Charges__c();
        lc3.Name = 'Base Rent';
        lc3.Active__c = true;
        lc3.Start_Date__c = lu3.Lease_Start_Date__c;
        lc3.End_Date__c = endDate;
        lc3.Lease_Unit__c = lu3.Id;
        lc3.Billing_Frequency__c='Monthly';
        lc3.Frequency__c = 'Quarterly';
        lc3.Type__c='By Area';
        lc3.Charge_Type__c='Advance Rental'; 
        lc3.Charge_Rate__c = 15.00;
        lc3.Currency_Code__c = USDCURRENCYCODE;
        lc3.Exchange_Rate__c = 1361;
        lc3.Commercial_Tax_Apply__c = true;
        lc3.Billing_Terms__c = 'Non-prorate';
        //lc3.Charge_Start_Day__c = null;
        insert lc3;
        
        Rent_Schedules__c rs3 = new Rent_Schedules__c();
        rs3.Unit__c = unt3.Id;
		rs3.Lease_Unit__c = lu3.Id;
        rs3.Status__c = 'In-Tenancy';
        rs3.Lease_Charge__c = lc3.Id;
        rs3.Start_Date__c = startDate;
        rs3.End_Date__c = Date.newInstance(startDate.year(), startDate.month() + 1, startDate.day() - 1);
        rs3.Approved__c = false;
        rs3.Amount_Foreign__c = 6000;
        rs3.Amount_Local__c = 8166000;
        rs3.Calculated_Amount_Foreign__c = 6000;
        rs3.Calculated_Amount_Local__c = 8166000;
        brRsList.add(rs3);
        
        
        // create GTO rent lease charge
        Lease_Charges__c gtoLC3 = new Lease_Charges__c();
        gtoLC3.Name = 'GTO Rent';
        gtoLC3.Active__c = true;
        gtoLC3.Start_Date__c = lu3.Lease_Start_Date__c;
        gtoLC3.End_Date__c = endDate;
        gtoLC3.Lease_Unit__c = lu3.Id;
        gtoLC3.Billing_Frequency__c='Monthly';
        gtoLC3.Frequency__c = 'Quarterly';
        gtoLC3.Type__c= GTOLcType;
        gtoLC3.Charge_Type__c='GTO Rent'; 
        gtoLC3.Charge_Rate__c = 20;
        gtoLC3.Currency_Code__c = USDCURRENCYCODE;
        gtoLC3.Exchange_Rate__c = 1361;
        gtoLC3.Cumulative_for_each_Tier__c = cumulative;
        gtoLC3.Tiered_Limit__c = tier;
        gtoLC3.Tiered_Lower_Limit__c = 0;
        gtoLC3.Tier_1_Upper_Limit__c = 20000;
        gtoLC3.Tier_1_Rate__c = 0.2;
        gtoLC3.Tier_2_Upper_Limit__c = 30000;
        gtoLC3.Tier_2_Rate__c = 0.18;
        gtoLC3.Tier_3_Rate__c = 0.16;
        gtoLC3.Commercial_Tax_Apply__c = true;
        gtoLC3.Billing_Terms__c = 'Prorate';
        //gtoLC3.Charge_Start_Day__c = '0';
        insert gtoLC3;
        
        if(GtoBilledType.equals(GTOBYLEASELEASEUNIT)){
	        Rent_Schedules__c gtoRS3 = new Rent_Schedules__c();
	        gtoRS3.Unit__c = unt3.Id;
			gtoRS3.Lease_Unit__c = lu3.Id;
	        gtoRS3.Status__c = 'In-Tenancy';
	        gtoRS3.Lease_Charge__c = gtoLC3.Id;
	        gtoRS3.Start_Date__c = startDate;
	        gtoRS3.End_Date__c = lastDayOfMonth;
	        gtoRS3.Approved__c = false;
	        if(capValue == null){
	        	gtoRS3.Cap_Value__c = null;
	        }
	        else{
	        	gtoRS3.Cap_Value__c = capValue.get(2);
	        }
	        gtoRS3.Currency_Code__c = gtoLC3.Currency_Code__c;
	        gtoRS3.Exchange_Rate__c = gtoLC3.Exchange_Rate__c;
	        gtoRS3.Calc_No_of_Days_Pro_Rated_2__c = 100;
	        gtoRsList.add(gtoRS3);
        }
        
        Test.startTest();
        insert brRsList;
        RSTrigger_Helper.RSmap = null;
        return gtoRsList;
    }
}