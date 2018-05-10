@isTest(seeAllData=false)
public with sharing class PreTerminate_Test {
    static Property__c prop;
    static Account acc;
    static Lease_Unit__c lu;
    static Lease__c ls;
    static Lease_Charges__c lc;
    static Lease_Charges__c lcChild;
    static void init(){
        prop = new Property__c();
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
        unt.NLA_SQF__c = 200;
        unt.Active__c = true;
        unt.Start_Date__c = system.today().addDays(-10);
        unt.End_Date__c = system.today().addYears(2);
        unt.Charge_Method__c = 'Monthly Rate - CL';
        insert unt;
        
        acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;
        
        
        ls = new Lease__c(); 
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id;
        ls.Lease_Start_Date__c =  System.today().addDays(-10);
        ls.Lease_Tenure_Days__c = ''+31;
        insert ls;
        
        lu = new Lease_Unit__c();
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.Lease_End_Date__c =  System.today().addDays(30);
        insert lu;
        
        Lease_POS__c lp = new Lease_POS__c();
        lp.Name = '--system generated--';
        lp.Generate_POS_ID__c = 'Yes';
        lp.Lease_Unit__c = lu.Id;
        lp.Start_Date__c = System.today();
        lp.End_Date__c = System.today().addDays(30);
        insert lp;
        
        lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Commercial_Tax_Apply__c = true;
        
        insert lc;
        
        lcChild = new Lease_Charges__c();
        lcChild.Name = 'TestCharge11';
        lcChild.Active__c = true;
        lcChild.Start_Date__c = system.today();
        lcChild.End_Date__c = system.today().addYears(1);
        lcChild.Lease_Unit__c = lu.Id;
        lcChild.Billing_Frequency__c='Monthly';
        lcChild.Type__c='By Area';
        lcChild.Commercial_Tax_Apply__c = true;
        lcChild.Parent_Lease_Charge__c= lc.Id;
        
        Rent_Roll__c rentRoll = new Rent_Roll__c();
        rentRoll.Property__c = prop.Id;               
        rentRoll.Total_Amount__c = 100;
        insert rentRoll;
        
        Rent_Schedules__c rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Lease_Unit__c = lu.Id;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
        
        rs = new Rent_Schedules__c();
        //rs.Name = unt.Name;
        rs.Lease_Unit__c = lu.Id;
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc.Id;
        rs.Start_Date__c = lc.End_Date__c.addMonths(1);
        rs.End_Date__c = rs.Start_Date__c.addMonths(1);
        rs.Rent_Roll__c = rentRoll.Id;
        rs.Approved__c = true;
        insert rs;
    }   
    static TestMethod void Test1(){
        init();
        Test.startTest();
        PageReference pageRef = Page.PreTerminateLU;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('selectedLeaseUnits', lu.Id);
        pageRef.getParameters().put('endDate', '10/12/2012');
        ApexPages.StandardController sc = new ApexPages.StandardController(lu);
        PreTerminateLU_Extension testPreTerm = new PreTerminateLU_Extension(sc);
        try{
            testPreTerm.checkDate();
        }catch(Exception e){
            System.debug('Exception occured');
        }
        testPreTerm.lu.Reason_for_Termination__c = 'terminateion reason test';
        testPreTerm.selectedLU = lu.Id;
        testPreTerm.checkDate();
        
        testPreTerm.lu.Lease_End_Date__c = System.today().addDays(35);
        try{
            testPreTerm.checkDate();
        }catch(Exception e){
            System.debug('Exception occured');
        }
        
        testPreTerm.lu.Lease_End_Date__c = null;
        try{
            testPreTerm.checkDate();
        }catch(Exception e){
            System.debug('Exception occured');
        }
        Test.stopTest();        
    }
    static TestMethod void Test2(){
        init(); 
        Test.startTest();
        PageReference pageRef = Page.PreTerminateLease;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('endDate', '10/12/2017');
        pageRef.getParameters().put('selectedLease', ls.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ls);
        PreTerminateLease_Extension testPreTerm = new PreTerminateLease_Extension(sc);
        testPreTerm.EndDate =  system.today().addDays(20);
        try{
            testPreTerm.checkDate();
        }catch(Exception e){
            System.debug('Exception occured');
        }
        testPreTerm.leaseOnUI.Reason_for_Termination__c = 'terminateion reason test';
        try{
            testPreTerm.checkDate();
        }catch(Exception e){
            System.debug('Exception occured');
        }
        testPreTerm.selectedLease = ls.Id;
        testPreTerm.checkDate();
        Test.stopTest(); 
    }
    static TestMethod void Test3(){
        init();
        Test.startTest();
        PageReference pageRef = Page.PreTerminateLC;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('selectedLeaseCharges', lc.Id);
        pageRef.getParameters().put('endDate', '10/8/2017');
        ApexPages.StandardController sc = new ApexPages.StandardController(lc);
        PreTerminateLC_Extension testPreTerm = new PreTerminateLC_Extension(sc);
        testPreTerm.selectedLeaseCharge = lc.Id;
        //testPreTerm.leaseCharge.End_Date__c = lc.End_Date__c.addDays(-10); 
        testPreTerm.checkDate();
        testPreTerm.termError = false;
        testPreTerm.displayPopup = false;
        testPreTerm.dtString = '';
         testPreTerm.erroOnLoad  = false;
        testPreTerm.EndDate = System.today(); 
        Test.stopTest();        
    }
    static TestMethod void Test4(){
        init();
        Test.startTest();
        PreTerminateLC_Extension testPreTerm;
        try {
            PageReference pageRef = Page.PreTerminateLC;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('selectedLeaseCharges', lc.Id);
            pageRef.getParameters().put('endDate', '10/8/2017');
            ApexPages.StandardController sc = new ApexPages.StandardController(lc);
            testPreTerm = new PreTerminateLC_Extension(sc);
            testPreTerm.selectedLeaseCharge = lc.Id;
            //testPreTerm.leaseCharge.End_Date__c = lc.End_Date__c.addDays(-10); 
            testPreTerm.leaseCharge.End_Date__c = null;
            testPreTerm.checkDate();
        }catch(Exception e){
             String message = e.getMessage();
             //system.assert(message.contains('Argument cannot be null'), 'message=' + message);
             //system.assert(message.contains('de-reference a null object'), 'message=' + message);
             system.assert(message.contains('Termination Date'), 'message=' + message);
        }
        try{
            testPreTerm.leaseCharge.End_Date__c = lc.Start_Date__c;
            testPreTerm.checkDate();
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('Termination Date'), 'message=' + message);
        }
        try{
            testPreTerm.leaseCharge.End_Date__c = lc.End_Date__c+10;
            testPreTerm.checkDate();
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('Termination Date'), 'message=' + message);
        }   
        
        Test.stopTest();        
    }
    static TestMethod void Test5(){
        init();
        
        
        lcChild.Pre_Termination__c = false;
        insert lcChild;
    
        Test.startTest();
        PreTerminateLC_Extension testPreTerm;
        try{
            
            PageReference pageRef = Page.PreTerminateLC;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('selectedLeaseCharges', lc.Id);
            pageRef.getParameters().put('endDate', '10/8/2017');
            ApexPages.StandardController sc = new ApexPages.StandardController(lc);
            testPreTerm = new PreTerminateLC_Extension(sc);
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('Terminate'), 'message=' + message);
        }
        Test.stopTest();
    }
}