@isTest
Class TestTransaction_linkWithRentSchedules{
	static Rent_Schedules__c RS1;
	static Rent_Schedules__c RS2;
	static Rent_Schedules__c RS3;
	static Rent_Schedules__c RS4;
	static Rent_Schedules__c RS5;
	static Units__c unt;
	static Lease_Unit__c lu;
	static set<Id>  lcId;
	static void init(){
		Utility.doGTO = false;
		Property__c pty = new Property__c();
	    pty.Name = 'Testing Mall';
	    pty.Short_Code__c = 'TM';
	    insert pty;
	    
	    List<Applicable_Charges__c> lstAC = new List<Applicable_Charges__c>();
	    Applicable_Charges__c ac1 = new Applicable_Charges__c();
	    ac1.Name = 'MEPE (CT Meter)';
	    ac1.Billing_Frequency__c = 'Monthly';
	    ac1.Billing_Days__c = '1';
	    ac1.Charge_Type__c = 'Gov Meter';
	    ac1.Property__c = pty.Id;
	    ac1.Charge_Rate__c = 125;
	    ac1.Type__c = 'Meter Units';
	    ac1.Billing_Days__c ='1';
        ac1.Billing_Terms__c = 'Non-prorate';
        ac1.Charge_Start_Day__c = '1';
	    lstAC.add(ac1);
	    
	    
	    Applicable_Charges__c ac2 = new Applicable_Charges__c();
	    ac2.Name = 'Water (110)';
	    ac2.Billing_Frequency__c = 'Monthly';
	    ac2.Billing_Days__c = '1';
	    ac2.Charge_Type__c = 'Water';
	    ac2.Charge_Rate__c = 110;
	    ac2.Property__c = pty.Id;
	    ac2.Type__c = 'Meter Units';
	    ac2.Billing_Days__c ='1';
        ac2.Billing_Terms__c = 'Non-prorate';
        ac2.Charge_Start_Day__c = '1';
	    lstAC.add(ac2);
	
	    
	    Applicable_Charges__c ac3 = new Applicable_Charges__c();
	    ac3.Name = 'Phone (Local)';
	    ac3.Billing_Frequency__c = 'Monthly';
	    ac3.Billing_Days__c = '1';
	    ac3.Charge_Type__c = 'Local';
	    ac3.Charge_Rate__c = 15;
	    ac3.Property__c = pty.Id;
	    ac3.Type__c = 'Meter Units';
	    ac3.Billing_Days__c ='1';
        ac3.Billing_Terms__c = 'Non-prorate';
        ac3.Charge_Start_Day__c = '1';
	    lstAC.add(ac3);
	    
	    Applicable_Charges__c ac4 = new Applicable_Charges__c();
	    ac4.Name = 'Gas';
	    ac4.Billing_Frequency__c = 'Monthly';
	    ac4.Billing_Days__c = '1';
	    ac4.Charge_Type__c = 'Gas';
	    ac4.Charge_Rate__c = 10;
	    ac4.Property__c = pty.Id;
	    ac4.Type__c = 'Meter Units';
	    ac4.Billing_Days__c ='1';
        ac4.Billing_Terms__c = 'Non-prorate';
        ac4.Charge_Start_Day__c = '1';
	    lstAC.add(ac4);
	    
	    Applicable_Charges__c ac5 = new Applicable_Charges__c();
	    ac5.Name = 'Gas';
	    ac5.Billing_Frequency__c = 'Monthly';
	    ac5.Billing_Days__c = '1';
	    ac5.Charge_Type__c = 'GTO Rent';
	    ac5.Charge_Rate__c = 10;
	    ac5.Property__c = pty.Id;
	    ac5.Type__c = 'GTO (Sum)';
	    ac5.Billing_Days__c ='1';
        ac5.Billing_Terms__c = 'Non-prorate';
        ac5.Charge_Start_Day__c = '1';
	    lstAC.add(ac5);
	    
	    Applicable_Charges__c ac6 = new Applicable_Charges__c();
	    ac6.Name = 'Gas';
	    ac6.Billing_Frequency__c = 'Monthly';
	    ac6.Billing_Days__c = '1';
	    ac6.Charge_Type__c = 'Gov Meter';
	    ac6.Charge_Rate__c = 10;
	    ac6.Property__c = pty.Id;
	    ac6.Type__c = 'Meter Units';
	    ac6.Billing_Days__c ='1';
        ac6.Billing_Terms__c = 'Non-prorate';
        ac6.Charge_Start_Day__c = '1';
	    lstAC.add(ac6);
	    
	    insert lstAC;
	    

	    
	    Level__c lvl = new Level__c();
	    Lvl.Name = 'Level 1';
	    lvl.Property__c = pty.Id;
	    insert lvl;
	    
	    unt = new Units__c();
	    unt.Name = '01-001';
	    unt.Level__c = lvl.Id;
	    unt.Property__c = pty.Id;
	    unt.NLA_SQF__c = 100;
	    unt.Start_Date__c = system.today();
	    unt.End_Date__c = unt.Start_Date__c.addMonths(120);
	    unt.Gas_Meter_No__c = 'gm-1234';
	    unt.Water_Meter_No__c = 'wm-1234';
	    unt.Phone_Extension_No__c = 'px-1234';
	    unt.Active__c	 = true;
	    unt.Charge_Method__c = 'Monthly Rate - L';
	    insert unt;
	     Lease__c lea = new Lease__c();
	    lea.Name = 'TM-LA-201611-000001';
	    lea.Lease_Start_Date__c = system.today();
	    lea.Lease_Tenure_Mths__c = 12;
	    lea.Lease_Tenure_Days__c = '0';
	    insert lea;
	    
	    lu = new Lease_Unit__c();
	    lu.Lease_Agreement_No__c = lea.Id;
	    lu.unit__c = unt.Id;
	    lu.Rent_Free_Start_Date__c = system.today();
	    lu.Rent_Free_End_Date__c = system.Today().addMonths(30);
	    insert lu;
	    
	    Lease_POS__c lp = new Lease_POS__c();
	    lp.Name = '--system generated--';
	    lp.Lease_Unit__c = lu.Id;
	    lp.Start_Date__c =  date.newInstance(2016, 11, 01);
	    lp.End_Date__c = lp.Start_Date__c.addYears(1);
	    insert lp;
	    
	    system.debug('lu ==> ' + lu);
	    
	    List<Lease_Charges__c> lstLC = new List<Lease_Charges__c>();
	    lcId = new set<Id>();
	    map<String, Id> mapLC = new map<String,Id>();
	    for(Lease_Charges__c lc:[SELECT Id, Name,Generate_Rent_Schedule__c,Charge_Type__c FROM Lease_Charges__c WHERE  Lease_Unit__c =: lu.Id])
	    {
	        lc.Generate_Rent_Schedule__c = true;
	        lc.Active__c = true;
	        lstLC.add(lc);
	        lcId.add(lc.Id);
	        mapLC.put(lc.Charge_Type__c, lc.Id);
	    }
	    
	    update lstLC; 
	    
	    List<Rent_Schedules__c> lstRSU = new List<Rent_Schedules__c>();
	    RS1 = new Rent_Schedules__c();
	    RS1.Start_Date__c = date.newInstance(2016, 11, 01);
	    RS1.End_Date__c = RS1.Start_Date__c.addDays(60);
	    //RS1.Charge_Type__c = 'Gas';
	    RS1.Lease_Unit__c = lu.Id;
	    RS1.Lease_Charge__c = mapLC.get('Gas');
	    RS1.PropertyLU__c = pty.Id;
	    RS1.Unit__c = unt.Id;
	    RS1.Electric_Meter_Number__c = 'em-1234';
	   // RS1.Phone_Extension_No__c = 'px-1234';
	    RS1.Status__c='In-Tenancy';
	    lstRSU.add(RS1); 
	    
	    RS2 = new Rent_Schedules__c();
	    RS2.Start_Date__c = date.newInstance(2016, 11, 01);
	    RS2.End_Date__c = RS2.Start_Date__c.addDays(60);
	    //RS2.Charge_Type__c = 'Water';
	    RS2.Lease_Charge__c = mapLC.get('Water');
	    RS2.Lease_Unit__c = lu.Id;
	    RS2.PropertyLU__c = pty.Id;
	    RS2.Electric_Meter_Number__c = 'em-1234';
	    //RS2.Phone_Extension_No__c = 'px-1234';
	    RS2.Unit__c = unt.Id;    
	    RS2.Status__c='In-Tenancy';
	    lstRSU.add(RS2); 
	    
	    RS3 = new Rent_Schedules__c();
	    RS3.Start_Date__c = date.newInstance(2016, 11, 01);
	    RS3.End_Date__c = RS3.Start_Date__c.addDays(27);
	    //RS3.Charge_Type__c = 'Gov Meter';
	    RS3.Lease_Charge__c = mapLC.get('Gov Meter');
	    RS3.Lease_Unit__c = lu.Id;
	    RS3.Electric_Meter_Number__c = 'em-1234;em-13334';
	    RS3.PropertyLU__c = pty.Id;
	    RS3.Unit__c = unt.Id;
	    RS3.Status__c='In-Tenancy';
	    lstRSU.add(RS3); 
	    
	    RS4 = new Rent_Schedules__c();
	    RS4.Start_Date__c = date.newInstance(2016, 11, 01);
	    RS4.End_Date__c = RS4.Start_Date__c.addDays(27);
	    //RS4.Charge_Type__c = 'Local';
	    RS4.Lease_Charge__c = mapLC.get('Gov Meter');
	    RS4.Lease_Unit__c = lu.Id;
	    RS4.PropertyLU__c = pty.Id;
	    RS4.Unit__c = unt.Id;
	    RS4.Electric_Meter_Number__c = 'em-1234;em-13334';
	    RS4.Status__c='In-Tenancy';
	    lstRSU.add(RS4);
	    
	    RS5 = new Rent_Schedules__c();
	    RS5.Start_Date__c = date.newInstance(2016, 11, 01);
	    RS5.End_Date__c = RS4.Start_Date__c.addDays(27);
	    //RS4.Charge_Type__c = 'Local';
	    RS5.Lease_Charge__c = mapLC.get('GTO Rent');
	    RS5.Lease_Unit__c = lu.Id;
	    RS5.PropertyLU__c = pty.Id;
	    RS5.Unit__c = unt.Id;
	    RS5.Electric_Meter_Number__c = 'em-1234;em-13334';
	    RS5.Status__c='In-Tenancy';
	    lstRSU.add(RS5);
	    
	    insert lstRSU;
	    
	}
    static TestMethod void TestEleTrans(){
	    init();
	    Test.startTest();
	    Electric_Meter__c em = new Electric_Meter__c();
	    em.Unit__c = unt.Id;
	    em.Meter_No__c = 'em-1234';
	    em.Meter_Type__c = 'Gov Meter';
	    em.Power_Factor__c = 1;
	    em.Line_Loss__c = 10;
	    insert em;
	   
	    List<Rent_Schedules__c> lstRS = [SELECT id, Name, Lease_Charge__c, Charge_Type__c, Start_Date__c, End_Date__c FROM Rent_Schedules__c WHERE Lease_Unit__c =: lu.Id or Lease_Charge__c IN : lcId];
	    system.debug('lstRS ==> ' + lstRS);
	
	    Electric_Transaction__c eTrax = new Electric_Transaction__c();
	    eTrax.Meter_No__c = 'em-1234';
	    eTrax.Start_Unit__c = 100;
	    eTrax.End_Unit__c = 200;
	    eTrax.Property_Short_Code__c = 'TM';
	    eTrax.From_Date__c = date.newInstance(2016, 10, 26);
	    eTrax.To_Date__c = eTrax.From_Date__c.addDays(20);
	    eTrax.Meter_Type__c = 'Gov Meter';
	    eTrax.Rent_Schedule__c = RS4.Id;    
	    insert eTrax;  
	    
	    eTrax = new Electric_Transaction__c();
	    eTrax.Meter_No__c = 'em-1234';
	    eTrax.Start_Unit__c = 100;
	    eTrax.End_Unit__c = 200;
	    eTrax.Property_Short_Code__c = 'TM';
	    eTrax.From_Date__c = date.newInstance(2016, 11, 17);
	    eTrax.To_Date__c = eTrax.From_Date__c.addDays(5);
	    eTrax.Meter_Type__c = 'Gov Meter';
	    eTrax.Rent_Schedule__c = RS4.Id;    
	    insert eTrax;
	    
	    eTrax = new Electric_Transaction__c();
	    eTrax.Manual__c = true;
	    eTrax.Start_Unit__c = 100;
	    eTrax.End_Unit__c = 200;
	    eTrax.Property_Short_Code__c = 'TM';
	    eTrax.From_Date__c = date.newInstance(2016, 10, 26);
	    eTrax.To_Date__c = eTrax.From_Date__c.addDays(24);
	    eTrax.Meter_Type__c = 'Gov Meter';
	    eTrax.Rent_Schedule__c = RS4.Id;    
	    insert eTrax;
	    
	    delete eTrax;
    	Test.stopTest();
    }
    static TestMethod void TestPosTrans(){
    	init();
    	
    	Test.startTest();
    	
    	Phone_Transaction__c pTrax = new Phone_Transaction__c();
	    pTrax.Extension_No__c = 'px-1234';
	    pTrax.Start_Unit__c = 100;
	    pTrax.End_Unit__c = 200;
	    pTrax.Property_Short_Code__c = 'TM';
	    pTrax.From_Date__c = date.newInstance(2016, 11, 01);
	    pTrax.Rent_Schedule__c = RS3.Id;
	    pTrax.Call_Type__c = 'Local';
	    pTrax.To_Date__c = pTrax.From_Date__c.addDays(24);
	    insert pTrax;
	    
    	POS_Transaction__c poTrax = new POS_Transaction__c();
	    poTrax.POS_Id__c = 'pos1234';
	    poTrax.Manual__c = true;    
	    poTrax.Property_Short_Code__c = 'TM';
	    poTrax.From_Date__c = date.newInstance(2016, 11, 01);
	    poTrax.Rent_Schedule__c = RS2.Id;
	    poTrax.To_Date__c = pTrax.From_Date__c.addDays(24);
	    insert poTrax;
	    Test.stopTest();
    }
    static TestMethod void TestPhoneTrans(){
    	init();
    	Test.startTest();
    	
    	Phone_Transaction__c pTrax = new Phone_Transaction__c();
	    pTrax.Extension_No__c = 'px-1234';
	    pTrax.Start_Unit__c = 100;
	    pTrax.End_Unit__c = 200;
	    pTrax.Property_Short_Code__c = 'TM';
	    pTrax.From_Date__c = date.newInstance(2016, 10, 26);
	    pTrax.Rent_Schedule__c = RS3.Id;
	    pTrax.Call_Type__c = 'Local';
	    pTrax.To_Date__c = pTrax.From_Date__c.addDays(20);
	    insert pTrax;
	    
	    pTrax = new Phone_Transaction__c();
	    pTrax.Extension_No__c = 'px-1234';
	    pTrax.Start_Unit__c = 100;
	    pTrax.End_Unit__c = 200;
	    pTrax.Property_Short_Code__c = 'TM';
	    pTrax.From_Date__c = date.newInstance(2016, 11, 17);
	    pTrax.Rent_Schedule__c = RS3.Id;
	    pTrax.Call_Type__c = 'Local';
	    pTrax.To_Date__c = pTrax.From_Date__c.addDays(5);
	    insert pTrax;
	    
	     pTrax = new Phone_Transaction__c();
	    pTrax.Extension_No__c = 'px-1234';
	    pTrax.Start_Unit__c = 100;
	    pTrax.End_Unit__c = 200;
	    pTrax.Property_Short_Code__c = 'TM';
	    pTrax.From_Date__c = date.newInstance(2016, 11, 01);
	    pTrax.Rent_Schedule__c = RS3.Id;
	    pTrax.Manual__c = true;
	    pTrax.To_Date__c = pTrax.From_Date__c.addDays(24);
	    insert pTrax;
	    
	    delete pTrax;
    	Test.stopTest();
    }
    static TestMethod void TestGasTrans(){
    	init();
    	Test.startTest();
    	
    	
	    
    	Gas_Transaction__c  gTrax = new Gas_Transaction__c();
	    gTrax.Meter_No__c = 'gm-1234';
	    gTrax.Start_Unit__c = 100;
	    gTrax.End_Unit__c = 200;
	    gTrax.Property_Short_Code__c = 'TM';
	    gTrax.From_Date__c = date.newInstance(2016, 10, 26);
	    gTrax.Rent_Schedule__c = RS1.Id;
	    gTrax.To_Date__c = gTrax.From_Date__c.addDays(20);
	    insert gTrax;
	    
	    gTrax = new Gas_Transaction__c();
	    gTrax.Meter_No__c = 'gm-1234';
	    gTrax.Start_Unit__c = 100;
	    gTrax.End_Unit__c = 200;
	    gTrax.Property_Short_Code__c = 'TM';
	    gTrax.From_Date__c = date.newInstance(2016, 11, 17);
	    gTrax.Rent_Schedule__c = RS1.Id;
	    gTrax.To_Date__c = gTrax.From_Date__c.addDays(5);
	    insert gTrax;
	    
	      gTrax = new Gas_Transaction__c();
	    gTrax.Meter_No__c = 'gm-1234';
	    gTrax.Start_Unit__c = 100;
	    gTrax.Manual__c = true;
	    gTrax.Property_Short_Code__c = 'TM';
	    gTrax.From_Date__c = date.newInstance(2016, 11, 01);
	    gTrax.Rent_Schedule__c = RS1.Id;
	    gTrax.To_Date__c = gTrax.From_Date__c.addDays(24);
	    insert gTrax;
	    
	    delete gTrax;
    	Test.stopTest();
    	
    }
    static TestMethod void TestWaterTrans(){
    	init();
    	Test.startTest();
    	
    	Water_Transaction__c wTrax = new Water_Transaction__c();
	    wTrax.Meter_No__c = 'wm-1234';
	    wTrax.Start_Unit__c = 100;
	    wTrax.End_Unit__c = 200;
	    wTrax.Property_Short_Code__c = 'TM';
	    wTrax.From_Date__c = date.newInstance(2016, 10, 26);
	    wTrax.Rent_Schedule__c = RS2.Id;
	    wTrax.To_Date__c = wTrax.From_Date__c.addDays(20);
	    insert wTrax;
	    
	    wTrax = new Water_Transaction__c();
	    wTrax.Meter_No__c = 'wm-1234';
	    wTrax.Start_Unit__c = 100;
	    wTrax.End_Unit__c = 200;
	    wTrax.Property_Short_Code__c = 'TM';
	    wTrax.From_Date__c = date.newInstance(2016, 11, 17);
	    wTrax.Rent_Schedule__c = RS2.Id;
	    wTrax.To_Date__c = wTrax.From_Date__c.addDays(5);
	    insert wTrax;
	    
	     wTrax = new Water_Transaction__c();
	    wTrax.Manual__c = true;
	    wTrax.Start_Unit__c = 100;
	    wTrax.End_Unit__c = 200;
	    wTrax.Property_Short_Code__c = 'TM';
	    wTrax.From_Date__c = date.newInstance(2016, 11, 01);
	    wTrax.Rent_Schedule__c = RS2.Id;
	    wTrax.To_Date__c = wTrax.From_Date__c.addDays(24);
	    insert wTrax;
	    
	     
	    delete wTrax;
	    
    	Test.stopTest();
    	 
    }
    static TestMethod void TestCheckListTrans(){
    	init();
    	Test.startTest();
    	
    	Checklist_Master__c chkM = new Checklist_Master__c();
	    chkM.Type__c = 'Takeover';
	    insert chkM;
	    
	    Checklist__c ckl = new Checklist__c();
	    ckl.Unit__c = unt.Id;
	    ckl.Checklist_Master__c = chkM.Id;
	    ckl.Target_Date__c = system.today();
	    
	    insert ckl;    
	    
	    ckl.Target_Date__c = system.today().addDays(1);
	    
	    update ckl;
	    
	    
	    Checklist_Item__c chkitem = new Checklist_Item__c();
	    chkitem.Checklist__c = ckl.Id;
	    
	    insert chkitem;
	    
	    chkitem.Remarks__c = 'test';
	    update chkitem; 
	    
	    Checklist_Remarks__c chRM = new Checklist_Remarks__c();
	    chRM.Checklist_Item__c = chkitem.Id;
	    insert chRM;
	    
	    chRM.Remarks__c = 'test';
	    update chRM;
	    
	    delete chRM;
	    delete chkitem;
	    delete ckl; 
	    
    	Test.stopTest();
    	
    }
}