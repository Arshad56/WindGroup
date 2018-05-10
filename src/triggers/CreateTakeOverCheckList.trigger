trigger CreateTakeOverCheckList on Units__c (after update) {

    Set<Id> propIds = new Set<Id>();
    Set<Id> conIds = new Set<Id>();
    Set<Id> unitIds = new Set<Id>();
    for(Units__c unt:Trigger.New){
        if(unt.Generate_CheckList__c && unt.Generate_CheckList__c!=Trigger.OldMap.get(unt.id).Generate_CheckList__c){
            propIds.add(unt.Property__c);
            unitIds.add(unt.Id);
            if(unt.Authorised_Person__c!=null){
                conIds.add(unt.Authorised_Person__c);
            }
            
            if(unt.Person_In_Charge__c!=null){
                conIds.add(unt.Person_In_Charge__c);
            }
            
            //added by myat oct-25-2016
            if(unt.Authorised_Person_2__c!=null){
                conIds.add(unt.Authorised_Person_2__c);
            }
            
            if(unt.Person_In_Charge_2__c!=null){
                conIds.add(unt.Person_In_Charge_2__c);
            }
        }
    }
   
    if(propIds.size()>0){
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        if(conIds.size()>0){
            conMap = new Map<Id,Contact>([Select id,Name,Email,Phone,Title,NRIC__c from Contact where id in:conIds]);
        }
        
        Map<Id,List<Conditions__c>> unitToConditionMap = new Map<Id,List<Conditions__c>>();
        for(Conditions__c cd:[Select id,Unit__c,Condition__c,Description__c,Issue_Types__c,Item_Type__c,Number__c,Parent_Condition__c,S_N__c from COnditions__c where Unit__c in:unitIds]){
            List<Conditions__c> tempList = new List<Conditions__c>();
            if(unitToConditionMap.containsKey(cd.Unit__c)){
                tempList.addAll(unitToConditionMap.get(cd.Unit__c));
            }
            tempList.add(cd);
            unitToConditionMap.put(cd.Unit__c,tempList);
        }
        
        //Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,(Select id,Name,Type__c,Description__c,(Select id,Name,Checklist_Master__c,Checklist_Status__c,Condition__c,Description__c,Issue_Types__c,Number__c,SN__c,(select id,Checklist_Master_Item__c,Condition__c,Label_Description__c,Language__c,Short_Label__c from Checklist_Labels__r) from Checklist_Master_Item__r) from Checklist_Templates__r where Type__c='Takeover') from Property__c where id in:propIds]);
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,(Select id,Name,Type__c,Description__c,Mobile_Module__c from Checklist_Templates__r where  Type__c='Takeover') from Property__c where id in:propIds]);
        Set<Id> chklstMasterIds = new Set<Id>();
        for(Property__c pr:propMap.values()){ 
            for(Checklist_Master__c cm:pr.Checklist_Templates__r){
                chklstMasterIds.add(cm.Id);
            }
        }
        System.debug('propMap-->'+propMap);
        List<Checklist_Master_Item__c> chklstItmList = [Select id,Name,Checklist_Master__c,Checklist_Status__c,Condition__c,Description__c,Item_Type__c,Issue_Types__c,Number__c,SN__c,(select id,Checklist_Master_Item__c,Condition__c,Label_Description__c,Language__c,Short_Label__c from Checklist_Labels__r) from Checklist_Master_Item__c where Checklist_Master__c in:chklstMasterIds];
        System.debug('chklstItmList-->'+chklstItmList);
        
        Map<Id,List<Checklist_Master_Item__c>> masterToItmMap = new Map<Id,List<Checklist_Master_Item__c>>();
        for(Checklist_Master_Item__c cmi:chklstItmList){
            List<Checklist_Master_Item__c> tempList = new List<Checklist_Master_Item__c>();
            if(masterToItmMap.containsKey(cmi.Checklist_Master__c)){
                tempList.addAll(masterToItmMap.get(cmi.Checklist_Master__c));
            }
            tempList.add(cmi);
            masterToItmMap.put(cmi.Checklist_Master__c,tempList);
        }
        System.debug('masterToItmMap-->'+masterToItmMap);
        List<CheckListWrapper> chklstWrapList = new List<CheckListWrapper>();
        List<Conditions__c> conditions = new List<Conditions__c>();
        for(Units__c unt:Trigger.New){
            if(unt.Generate_CheckList__c && unt.Generate_CheckList__c!=Trigger.OldMap.get(unt.id).Generate_CheckList__c){
                If(propMap.containsKey(unt.Property__c)){
                    Property__c prop = propMap.get(unt.Property__c);
                    if(prop.Checklist_Templates__r.size()>0){
                        for(Checklist_Master__c cm:prop.Checklist_Templates__r){
                            
                            System.debug('cm.Id-->'+cm.Id);
                            
                            CheckListWrapper clw = new CheckListWrapper();
                            clw.chkLst.Checklist_Master__c = cm.Id;
                            clw.chkLst.Mobile_Module__c = cm.Mobile_Module__c;
                            clw.chkLst.Description__c = cm.Description__c;
                            clw.chkLst.Type__c = cm.Type__c;
                            clw.ChkLst.Unit__c = unt.Id;
                            clw.chkLst.AP__c = unt.Authorised_Person__c;
                            clw.chkLst.PIC__c = unt.Person_In_Charge__c;
                            clw.chkLst.AP_2__c = unt.Authorised_Person_2__c;
                            clw.chkLst.PIC_2__c = unt.Person_In_Charge_2__c;
                            clw.chkLst.Target_Date__c = unt.Takeover_Date__c;
                            
                            if(conMap.containskey(unt.Authorised_Person__c)){
                                contact con = conMap.get(unt.Authorised_Person__c);
                                clw.chkLst.AP_Name__c = con.Name;
                                clw.chkLst.AP_Email__c = con.Email;
                                clw.chkLst.AP_Phone__c = con.Phone;
                                clw.chkLst.AP_Position__c = con.Title;
                                clw.chkLst.AP_NRIC__c = con.NRIC__c;
                            }
                            
                            if(conMap.containskey(unt.Person_In_Charge__c)){
                                contact con = conMap.get(unt.Person_In_Charge__c);
                                clw.chkLst.PIC_Name__c = con.Name;
                                clw.chkLst.PIC_Email__c = con.Email;
                                clw.chkLst.PIC_Phone__c = con.Phone;
                                clw.chkLst.PIC_Position__c = con.Title;
                                clw.chkLst.PIC_NRIC__c = con.NRIC__c;
                            }
                            
                            //added by myat oct-25-2016
                            if(conMap.containskey(unt.Authorised_Person_2__c)){
                                contact con = conMap.get(unt.Authorised_Person_2__c);
                                clw.chkLst.AP_2_Name__c = con.Name;
                                clw.chkLst.AP_2_Email__c = con.Email;
                                clw.chkLst.AP_2_Phone__c = con.Phone;
                                clw.chkLst.AP_2_Position__c = con.Title;
                                clw.chkLst.AP_2_NRIC__c = con.NRIC__c;
                            }
                            
                            if(conMap.containskey(unt.Person_In_Charge_2__c)){
                                contact con = conMap.get(unt.Person_In_Charge_2__c);
                                clw.chkLst.PIC_2_Name__c = con.Name;
                                clw.chkLst.PIC_2_Email__c = con.Email;
                                clw.chkLst.PIC_2_Phone__c = con.Phone;
                                clw.chkLst.PIC_2_Position__c = con.Title;
                                clw.chkLst.PIC_2_NRIC__c = con.NRIC__c;
                            }
                            System.debug('masterToItmMap.containsKey(cm.Id)-->'+masterToItmMap.containsKey(cm.Id));
                            if(unitToConditionMap.containsKey(unt.Id)){
                                for(Conditions__c cd:unitToConditionMap.get(unt.Id)){
                                    ChecklistItemWrapper cliWrap = new ChecklistItemWrapper();
                                    cliWrap.chkLstItm.Condition__c = cd.Condition__c;
                                    cliWrap.chkLstItm.Description__c = cd.Description__c;
                                    cliwrap.chkLstItm.Item_Type__c = cd.Item_Type__c;
                                    cliWrap.chkLstItm.Issue_Types__c = cd.Issue_Types__c;                                    
                                    cliWrap.chkLstItm.Number__c = cd.Number__c;
                                    cliWrap.chkLstItm.SN__c = (cd.S_N__c!=null?String.valueOf(cd.S_N__c):'');
                                    cliwrap.cond = cd;
                                    
                                    clw.chkLstItems.add(cliWrap);
                                }
                            }else if(masterToItmMap.containsKey(cm.Id)){
                                for(Checklist_Master_Item__c cmi:masterToItmMap.get(cm.Id)){
                                    ChecklistItemWrapper cliWrap = new ChecklistItemWrapper();
                                    cliWrap.chkLstItm.Condition__c = cmi.Condition__c;
                                    cliWrap.chkLstItm.Description__c = cmi.Description__c;
                                    cliwrap.chkLstItm.Item_Type__c = cmi.Item_Type__c;
                                    cliWrap.chkLstItm.Issue_Types__c = cmi.Issue_Types__c;                                    
                                    cliWrap.chkLstItm.Number__c = cmi.Number__c;
                                    cliWrap.chkLstItm.SN__c = (cmi.SN__c!=null?String.valueOf(cmi.SN__c):'');
                                    
                                    Conditions__c cd = new Conditions__c();
                                    cd.Condition__c = cmi.Condition__c;
                                    cd.Description__c = cmi.Description__c;
                                    cd.Number__c = cmi.Number__c;
                                    cd.S_N__c = Decimal.valueOf(cmi.SN__c);
                                    cd.Unit__c = unt.Id;
                                    conditions.add(cd);
                                    
                                    cliwrap.cond = cd;
                                    
                                    
                                    if(cmi.Checklist_Labels__r.size()>0){
                                        for(Translations__c tr:cmi.Checklist_Labels__r){
                                            Translations__c newTrans = new Translations__c();
                                            newTrans.Condition__c = tr.Condition__c;
                                            newTrans.Label_Description__c = tr.Label_Description__c;
                                            newTrans.Language__c = tr.Language__c;                                    
                                            cliWrap.transList.add(newTrans);
                                        }
                                    }
                                    clw.chkLstItems.add(cliWrap);
                                }
                            }
                            chklstWrapList.add(clw);
                        }
                    }
                }
            }
        }
        
        if(chklstWrapList.size()>0){
            List<Checklist__c> chklstList = new List<Checklist__c>();
            for(CheckListWrapper clw:chklstWrapList){
                chklstList.add(clw.chkLst);
            }
            if(chklstList.size()>0){
                insert chklstList;
            }
            
            if(conditions.size()>0){
                insert conditions;
            }
            
            List<Checklist_Item__c> chklstItemList = new List<Checklist_Item__c>();
            for(CheckListWrapper clw:chklstWrapList){
                if(clw.chkLst.Id!=null){
                    for(ChecklistItemWrapper cliWrap:clw.chkLstItems){
                        cliWrap.chkLstItm.Checklist__c = clw.chkLst.Id;
                        if(cliWrap.cond.Id!=null){
                            cliWrap.chkLstItm.Handover_Condition__c = cliWrap.cond.Id;
                        }
                        chklstItemList.add(cliwrap.chkLstItm);
                    }
                }
            }
            if(chklstItemList.size()>0){
                insert chklstItemList;
            }
            
            List<Translations__c> translations = new List<Translations__c>();
            for(CheckListWrapper clw:chklstWrapList){
                if(clw.chkLst.Id!=null){
                    for(ChecklistItemWrapper cliWrap:clw.chkLstItems){
                        if(cliWrap.chkLstItm.Id!=null){
                            for(Translations__c tr:cliWrap.transList){
                                tr.Checklist_Item__c = cliWrap.chkLstItm.Id;
                                translations.add(tr);
                            }
                        }
                    }
                }
            }
            
            if(translations.size()>0){
                insert translations;
            }
        }
    }
    
    class CheckListWrapper{
        Checklist__c chkLst;
        List<ChecklistItemWrapper> chkLstItems;
        CheckListWrapper(){
            chkLst = new CheckList__c();
            chkLstItems = new List<ChecklistItemWrapper>();
        }
    }
    
    class ChecklistItemWrapper{
        Checklist_Item__c chkLstItm;
        Conditions__c cond;
        List<Translations__c> transList;
        ChecklistItemWrapper(){
            chkLstItm = new Checklist_Item__c();
            cond = new Conditions__c();
            transList = new List<Translations__c>();
        }
    }
}