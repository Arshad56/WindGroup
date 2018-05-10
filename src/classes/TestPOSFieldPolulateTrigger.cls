@isTest
Class TestPOSFieldPolulateTrigger{
    static Rent_Schedules__c rs;
    static Lease_POS__c lp;
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
        insert lu;
        
        lp = new Lease_POS__c();
        lp.name = '--system generated--';
        lp.Lease_Unit__c = lu.Id;
        lp.Start_Date__c = system.today();
        lp.End_Date__c = system.today().addYears(3);
        lp.Status__c = 'Active';
        insert lp;
        
        
        Lease_Charges__c lc1 = new Lease_Charges__c();
        lc1.Name = 'Commercial Tax';
        lc1.Start_Date__c = system.today();
        lc1.End_Date__c = system.today().addYears(1);
        lc1.Lease_Unit__c = lu.Id;
        lc1.Type__c='Meter units';
        lc1.Charge_Type__c = 'GTO Rent';
        lc1.charge_Rate__c = 5;
        lc1.Generate_Rent_Schedule__c = true;
        insert lc1;
        
        rs = new Rent_Schedules__c();
        rs.Unit__c = unt.Id;
        rs.Status__c = 'In-Tenancy';
        rs.Lease_Charge__c = lc1.Id;
        rs.Start_Date__c = system.today();
        rs.End_Date__c = system.today().addMonths(2);
        rs.Approved__c = true;
        rs.Status__c='In-Tenancy';
        insert rs;
        
        Exchange_Rate__c excLocal = new Exchange_Rate__c();
        excLocal.Conversion_Rate__c = 1;
        excLocal.Currency_Code__c = label.Default_Currency;
        excLocal.Applicable_Function__c ='Finance';
        excLocal.Start_Date_Time__c = system.now();
        insert excLocal;
        
        Exchange_Rate__c excForeign = new Exchange_Rate__c();
        excForeign.Conversion_Rate__c = 1;
        excForeign.Currency_Code__c = label.Base_Foreign_Currency;
        excForeign.Applicable_Function__c ='Finance';
        excForeign.Start_Date_Time__c = system.now();
        insert excForeign;
        
    }
    static testMethod void runInsertPOS1() {
        init();
        
        Test.startTest();
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.From_Date__c = system.today()+1;
        pt.To_Date__c = system.today()+4;
        pt.POS_Id__c = 'null-POS-000001';
        pt.Rent_Schedule__c = rs.Id;
        insert pt;
        Test.stopTest();
    }
     static testMethod void runInsertPOS2() {
        init();
        
        Test.startTest();
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.Manual__c = true;
        pt.Rent_Schedule__c = rs.Id;
        try{
            insert pt;
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('From Date'), 'message=' + message);
        }
        try{
            pt.To_Date__c = system.today();
            pt.From_Date__c = system.today() + 5;
            if(pt.id == null){
                insert pt;
            }else{
                update pt;
            }
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('From Date'), 'message=' + message);
        }
        try{
            pt.From_Date__c = rs.Start_Date__c - 15;
            pt.To_Date__c = rs.Start_Date__c + 10;
            if(pt.id == null){
                insert pt;
            }else{
                update pt;
            }
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('From Date'), 'message=' + message);
        }
        try{
            pt.From_Date__c = rs.Start_Date__c + 1;
            pt.To_Date__c = rs.Start_Date__c - 15;
            if(pt.id == null){
                insert pt;
            }else{
                update pt;
            }
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('From Date'), 'message=' + message);
        }
        Test.stopTest();
    }
    static testMethod void runInsertPOS3() {
        init();
        
        Test.startTest();
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.Manual__c = true;
        
        //pt.POS_Id__c = 'null-POS-000001';
        pt.Rent_Schedule__c = rs.Id;
        pt.From_Date__c = system.today();
        pt.To_Date__c = system.today() + 5;
        insert pt;
        Test.stopTest();
    }
    static testMethod void runInsertPOS4() {
        init();
        
        Test.startTest();
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.From_Date__c = system.today()+10;
        pt.To_Date__c = system.today()+25;
        pt.POS_Id__c = 'null-POS-000001';
        pt.Rent_Schedule__c = rs.Id;
        insert pt;
        
        pt = new POS_Transaction__c();
        pt.From_Date__c = system.today()+26;
        pt.To_Date__c = system.today()+45;
        pt.POS_Id__c = 'null-POS-000001';
        pt.Rent_Schedule__c = rs.Id;
        insert pt;
        
        try{
             pt = new POS_Transaction__c();
            pt.From_Date__c = system.today()+26;
            pt.To_Date__c = system.today()+45;
            pt.POS_Id__c = 'null-POS-000001';
            pt.Rent_Schedule__c = rs.Id;
            insert pt;
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('POS Transaction for identified Rent Schedule already exist'), 'message=' + message);
        }
        Test.stopTest();
    }
    static testMethod void runInsertPOS5() {
        init();
        
        Test.startTest();
        POS_Transaction__c pt = new POS_Transaction__c();
        pt.From_Date__c = system.today()+1;
        pt.To_Date__c = system.today()+4;
        pt.POS_Id__c = 'null-POS-000001';
        pt.Rent_Schedule__c = rs.Id;
        pt.Manual__c = true;
        insert pt;
        Test.stopTest();
    }
}