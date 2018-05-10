@isTest(seeAllData=false)
public with sharing class LoiPdfDocumentController_Test {
	static Property__c prop;
    static Units__c unt;
    static LOI_Unit__c lu;
    static LOI_Unit__c lu2;
    public static LOI__c ls;
     static void init(){
         prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        Applicable_Charges__c ac = new Applicable_Charges__c();
        ac.name='Test12';
        ac.Frequency__c='Monthly';
        ac.Billing_Frequency__c='Monthly';
        ac.Billing_Days__c='31';
        ac.Property__c=prop.id;
        ac.Charge_Type__c='Local';
        ac.Currency_Code__c=label.Base_Foreign_Currency;
        ac.Charge_Method__c='Monthly Rate - CL';
        ac.Type__c = 'Meter Units';
	    ac.Billing_Days__c ='1';
        ac.Billing_Terms__c = 'Non-prorate';
        //ac.Charge_Start_Day__c = '1';
        insert ac;
        
        unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Generate_Lease_Plans__c = true;
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Monthly Rate - CL';
        insert unt;
        
        Account acc = new Account();
        acc.Name = 'TestTenant';
        insert acc;LOI__c
        
         ls = new LOI__c();
        ls.Tenant__c = acc.Id;
        ls.Property__c = prop.Id; 
        ls.LOI_Start_Date__c = System.today(); 
        ls.LOI_Validity_Week__c = 'One Week';      
        insert ls;
        
        List<Deposit__c> listDep = new List<Deposit__c>();
		Deposit__c dep = new Deposit__c();
		dep.name='--System Generated--';
		dep.LOI__c  = ls.id; 
		dep.Deposit_Type__c = 'Fit-Out';
		listDep.add(dep);
		    
	    dep = new Deposit__c();
		dep.name='--System Generated--';
		dep.LOI__c  = ls.id; 
		dep.Deposit_Type__c = 'Security';
		listDep.add(dep);
		
		insert listDep;
		    
        lu = new LOI_Unit__c();
        lu.LOI_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        lu.LOI_Start_Date__c = unt.Start_Date__c+2;
        lu.LOI_End_Date__c = lu.LOI_Start_Date__c+3;
        lu.Update_LOI_Plans__c = true;
        
        insert lu;
        
        lu2 = new LOI_Unit__c();
        lu2.LOI_Agreement_No__c = ls.Id;
        lu2.Unit__c = unt.Id;
        lu2.LOI_Start_Date__c = lu.LOI_End_Date__c+30;
        lu2.LOI_End_Date__c = lu2.LOI_Start_Date__c+5;
        insert lu2;
        
        List<LOI_Charges__c> listLOI = new List<LOI_Charges__c>();
        LOI_Charges__c lc1=new LOI_Charges__c();
        lc1.Name='testLoiCharge';
        lc1.LOI_Unit__c=lu.Id;
        lc1.Type__c='Fixed';
        lc1.charge_Type__c = 'Service';
        lc1.Start_Date__c = lu.LOI_End_Date__c+30;
        lc1.End_Date__c = lu2.LOI_Start_Date__c+5;
        listLOI.add(lc1);
        
        LOI_Charges__c lc2=new LOI_Charges__c();
        lc2.Name='testLoiCharge';
        lc2.LOI_Unit__c=lu.Id;
        lc2.Type__c='Fixed';
        lc2.charge_Type__c = 'Advance Rental';
        lc2.Start_Date__c = lu.LOI_End_Date__c+30;
        lc2.End_Date__c = lu2.LOI_Start_Date__c+5;
        listLOI.add(lc2);
        
         lc2=new LOI_Charges__c();
        lc2.Name='testLoiCharge';
        lc2.LOI_Unit__c=lu.Id;
        lc2.Type__c='Fixed';
        lc2.charge_Type__c = 'GTO Rent';
        lc2.Type__c = 'GTO (Higher)';
        lc2.Tiered_Limit__c = true;
        lc2.Start_Date__c = lu.LOI_End_Date__c+30;
        lc2.End_Date__c = lu2.LOI_Start_Date__c+5;
        listLOI.add(lc2);
        
        lc2=new LOI_Charges__c();
        lc2.Name='testLoiCharge';
        lc2.LOI_Unit__c=lu.Id;
        lc2.Type__c='Fixed';
        lc2.charge_Type__c = 'GTO Rent';
        lc2.Type__c = 'GTO (Sum)';
        lc2.Tiered_Limit__c = true;
        lc2.Start_Date__c = lu.LOI_End_Date__c+30;
        lc2.End_Date__c = lu2.LOI_Start_Date__c+5;
        listLOI.add(lc2);
        insert listLOI;
        
        Checklist_Master__c chkM = new Checklist_Master__c();
	    chkM.Type__c = 'Takeover';
	    insert chkM;
	    
	    Checklist__c ckl = new Checklist__c();
	    ckl.Unit__c = unt.Id;
	    ckl.Checklist_Master__c = chkM.Id;
	    ckl.Target_Date__c = system.today();
	    ckl.Target_Date__c = system.today().addDays(1);
	    insert ckl;
	    
	    Checklist_Item__c chkitem = new Checklist_Item__c();
	    chkitem.Checklist__c = ckl.Id;
	    insert chkitem;
	    
	    Burmese_Text__c setting = new Burmese_Text__c();
		setting.Name = 'Request_ST_Index';
		setting.Property_Name__c = 'All';
		setting.Url__c = '';
		insert setting;
    }
     static testMethod void Test(){
         init();
         System.debug('lu11==>'+lu);
         
         Test.startTest();
         
         PageReference pref = Page.LOIPdf;
	     pref.getParameters().put('loiId',lu.LOI_Agreement_No__c );
	     Test.setCurrentPage(pref);
	    
	     ApexPages.StandardController con = new ApexPages.StandardController(lu);
	     LoiPdfDocumentController bdi = new LoiPdfDocumentController();
         
         Test.stopTest();
     }
     
     static testMethod void runPDFPage() {
    	init();
    	Test.startTest();
    	LoiDocumentGenerator.generateLoi(lu.LOI_Agreement_No__c);
    	string amo = ConvertCurrencyToWords.english_number(10);
    	amo = ConvertCurrencyToWords.english_number(1000);
    	amo = ConvertCurrencyToWords.english_number(10000);
    	amo = ConvertCurrencyToWords.english_number(100000);
    	amo = ConvertCurrencyToWords.english_number(1000000);
    	amo = ConvertCurrencyToWords.english_number(109900000);
    	amo = ConvertCurrencyToWords.english_number(1099758880);
		Test.stopTest();
    }
}