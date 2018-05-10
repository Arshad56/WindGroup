@isTest
Class TestCreateHandoverFitoutCheckList{
    
    static TestMethod void Test(){
        
        
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Checklist_Master__c cm = new Checklist_Master__c();
        cm.Property__c = prop.Id;
        cm.Description__c = 'Testing';
        cm.Type__c = 'Handover';
        insert cm;
        
        Checklist_Master_Item__c cmi = new Checklist_Master_Item__c();
        cmi.Checklist_Master__c = cm.Id;
        cmi.Checklist_Status__c = 'Active';
        cmi.Condition__c = 'New';
        cmi.Issue_Types__c = 'Water Spots';
        cmi.Item_Type__c = 'Wall';
        cmi.Number__c = '1';
        //cmi.SN__c = '1';
        insert cmi;
        
        Checklist_Master__c cm1 = new Checklist_Master__c();
        cm1.Property__c = prop.Id;
        cm1.Description__c = 'Testing';
        cm1.Type__c = 'Takeover (Shop)';
        insert cm1;
        
        Checklist_Master_Item__c cmi1 = new Checklist_Master_Item__c();
        cmi1.Checklist_Master__c = cm1.Id;
        cmi1.Checklist_Status__c = 'Active';
        cmi1.Condition__c = 'New';
        cmi1.Issue_Types__c = 'Water Spots';
        cmi1.Item_Type__c = 'Wall';
        cmi1.Number__c = '1';
        insert cmi1;
        
        Translations__c tl = new Translations__c();
        tl.Checklist_Master__c = cm.Id;
        tl.Checklist_Master_Item__c = cmi.Id;
        insert tl;
        
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
        
        contact con1 = new COntact();
        con1.LastName = 'Ap';
        insert con1;
        
        contact con2 = new COntact();
        con2.LastName = 'Pc';
        insert con2;
        
        Lease_Unit__c lu = new Lease_Unit__c();
        lu.Authorised_Person__c = con1.Id;
        lu.Person_In_Charge__c = con2.Id;
        lu.Lease_Agreement_No__c = ls.Id;
        lu.Unit__c = unt.Id;
        insert lu;
        
        lu.Generate_CheckList__c  = true;
        lu.Generate_Takeover_Shop_CheckList__c = true;
        update lu;
    }
}