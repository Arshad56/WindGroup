@isTest
Class TestCreateTakeOverCheckList{
    
    static TestMethod void Test(){
        
        
        Property__c prop = new Property__c();
        prop.Name = 'TestProperty';
        insert prop;
        
        Checklist_Master__c cm = new Checklist_Master__c();
        cm.Property__c = prop.Id;
        cm.Description__c = 'Testing';
        cm.Type__c = 'Takeover';
        insert cm;
        
        Checklist_Master_Item__c cmi = new Checklist_Master_Item__c();
        cmi.Checklist_Master__c = cm.Id;
        cmi.Checklist_Status__c = 'Active';
        cmi.Condition__c = 'New';
        cmi.Issue_Types__c = 'Water Spots';
        cmi.Item_Type__c = 'Wall';
        cmi.Number__c = '1';
        cmi.SN__c = '1';
        insert cmi;
        
        Translations__c tl = new Translations__c();
        tl.Checklist_Master__c = cm.Id;
        tl.Checklist_Master_Item__c = cmi.Id;
        insert tl;
        
        Level__c lvl = new Level__c();
        lvl.Name = 'TestLevel';
        lvl.Property__c = prop.Id;
        insert lvl;
        
        List<Contact> conList = new List<Contact>();
        contact con1 = new COntact();
        con1.LastName = 'Ap1';
        conList.add(con1);
        
        contact con2 = new COntact();
        con2.LastName = 'Pc1';
        conList.add(con2);
        
        contact con3 = new COntact();
        con3.LastName = 'Ap2';
        conList.add(con3);
        
        contact con4 = new COntact();
        con4.LastName = 'Pc2';
        conList.add(con4);
        
        insert conList;
        
        Units__c unt = new Units__c();
        unt.Property__c = prop.Id;
        unt.Level__c = lvl.Id;
        unt.Name = 'TestUnit';
        unt.Active__c = true;
        unt.Start_Date__c = system.today();
        unt.End_Date__c = system.today().addYears(2);
        unt.Authorised_Person__c = con1.Id;
        unt.Authorised_Person_2__c = con3.Id;
        unt.Person_In_Charge__c = con2.Id;
        unt.Person_In_Charge_2__c = con4.Id;
        insert unt;
        
        unt.Generate_CheckList__c = true;
        update unt;
        
        List<Checklist_Item__c> chkLstItmList = [Select id from Checklist_Item__c limit 1];
        if(chkLstItmList.size()>0){
            Conditions__c cd = new Conditions__c();
            cd.Unit__c = unt.Id;
            cd.S_N__c = 1;
            cd.Number__c = '1';
            cd.Item_Type__c = 'Wall';
            insert cd;
            
            chkLstItmList[0].Handover_Condition__c = cd.Id;
            update chkLstItmList[0];
        }
        
    }
}