@isTest(seeAllData=false)
public with sharing class UpdateLeasePlanBooking_Test {
    static Property__c prop;
   static Units__c unt;
   static Lease_Unit__c luTest;
    static void init(){
         prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        
        unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(1);
        unt.Charge_Method__c = 'Daily Rate';
        insert unt;
        
        Units__c unt1 = new Units__c();
        unt1.Property__c = prop.Id;
        unt1.Level__c = lvl.Id;
        unt1.Name = 'TestUnit';
        unt1.Active__c = true;
        unt1.Start_Date__c = system.today().addYears(1)+1;
        unt1.End_Date__c = system.today().addYears(2);
        unt1.Charge_Method__c = 'Daily Rate';
        insert unt1;
        
        
        
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = unt.Id;
        lp.Start_Date__c = unt.Start_Date__c;
        lp.End_Date__c = Date.newInstance(unt.Start_Date__c.year(),unt.Start_Date__c.month(),Date.DaysInMonth(unt.Start_Date__c.Year(),unt.Start_Date__c.Month()));
        for(Date dts=unt.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
            
            if(dts.Day() > 0 && dts.Day() < 7){
                lp.put('Status_'+dts.Day()+'__c','Committed');
            }else if(dts.Day() > 7 && dts.Day() < 15){
                lp.put('Status_'+dts.Day()+'__c','Vacant');
            }else if(dts.Day() > 17 && dts.Day() < 25){
                lp.put('Status_'+dts.Day()+'__c','LOI');
            }
        }
        insert lp;
         
        Lease_Plan__c lp1 = new Lease_Plan__c();
        lp1.Unit__c = unt1.Id;
        lp1.Start_Date__c = unt.Start_Date__c;
        lp1.End_Date__c = Date.newInstance(unt.Start_Date__c.year(),unt.Start_Date__c.month(),Date.DaysInMonth(unt.Start_Date__c.Year(),unt.Start_Date__c.Month()));
        for(Date dts=unt.Start_Date__c;dts<=lp1.End_Date__c; dts = dts+1){
            lp1.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
            
            if(dts.Day() > 0 && dts.Day() < 7){
                lp1.put('Status_'+dts.Day()+'__c','Committed');
            }else if(dts.Day() > 7 && dts.Day() < 15){
                lp1.put('Status_'+dts.Day()+'__c','Vacant');
            }else if(dts.Day() > 17 && dts.Day() < 25){
                lp1.put('Status_'+dts.Day()+'__c','LOI');
            }
        }
        insert lp1;
                        
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
        lu.Lease_Start_Date__c = unt.Start_Date__c;
        lu.Lease_End_Date__c = unt.Start_Date__c+1;
        insert lu;
        
        
        luTest = new Lease_Unit__c();
        luTest.Lease_Agreement_No__c = ls.Id;
        luTest.Unit__c = unt1.Id;
        luTest.Lease_Start_Date__c = unt1.Start_Date__c;
        luTest.Lease_End_Date__c = unt1.Start_Date__c+1;
        
        
        Lease_Charges__c lc = new Lease_Charges__c();
        lc.Name = 'TestCharge';
        lc.Active__c = true;
        lc.Start_Date__c = system.today();
        lc.End_Date__c = system.today().addYears(1);
        lc.Lease_Unit__c = lu.Id;
        lc.Billing_Frequency__c='Monthly';
        lc.Type__c='By Area';
        lc.Charge_Type__c = 'Rent';
        lc.Commercial_Tax_Apply__c = true;
        insert lc;
        
        Contact con = new Contact();
        con.email = 'Test@gmail.com';
        con.lastName = 'Test';
        con.Region__c = 'Asia';
        con.AccountId =  acc.Id;
        insert con;
        
        Expression_of_Interest__c eoi = new Expression_of_Interest__c();
        eoi.Property_Name__c = prop.Id;
        eoi.Unit_No__c = unt.Id;
        eoi.Enquiry_Date__c = System.today();
        eoi.Commencement_Date__c = unt.Start_Date__c + 20;
        eoi.Expiry_Date__c = unt.Start_Date__c + 50;
        eoi.Account_Name__c = acc.Id;
        eoi.Contact_Name__c = con.Id;
        insert eoi;
        
        eoi = new Expression_of_Interest__c ();
        eoi.Property_Name__c = prop.Id;
        eoi.Unit_No__c = unt1.Id;
        eoi.Enquiry_Date__c = System.today();
        eoi.Commencement_Date__c = unt1.Start_Date__c + 20;
        eoi.Expiry_Date__c = unt1.Start_Date__c + 50;
        eoi.Account_Name__c = acc.Id;
        eoi.Contact_Name__c = con.Id;
        insert eoi;
    }
    static testMethod void Test(){
        init();
         Test.startTest();
         unt.Charge_Method__c = 'Monthly Rate - L';
         update unt;
         
          Test.stopTest();
     }
}