trigger CreateTakeoverShopCheckList on Lease_Unit__c(after update){
    Set<Id> propIds = new Set<Id>();
    Set<Id> conIds = new Set<Id>();
    Set<Id> unitIds = new Set<Id>();
    Set<Id> luIds = new Set<Id>();
    for(Lease_Unit__c lu:Trigger.New){
        if(lu.Generate_Takeover_Shop_CheckList__c && lu.Generate_Takeover_Shop_CheckList__c!=Trigger.OldMap.get(lu.id).Generate_Takeover_Shop_CheckList__c){
            luIds.add(lu.Id);
            if(lu.Unit__c!=null){
                unitIds.add(lu.Unit__c);
            }
            if(lu.Authorised_Person__c!=null){
                conIds.add(lu.Authorised_Person__c);
            }
            if(lu.Person_In_Charge__c!=null){
                conIds.add(lu.Person_In_Charge__c);
            }
        }
    }
    
    if(unitIds.size()>0){
        Map<Id,Checklist__c> luToHandoverMap = new Map<Id,Checklist__c>();
        List<Checklist__c> handoverCheckLists = [Select id,Lease_Unit__c,(Select id,Condition__c,Description__c,Item_Type__c,Issue_Types__c,Number__c,SN__c,Handover_Condition__c from Checklist_Items__r) from Checklist__c where Lease_Unit__c in:luIds and Type__c like '%Handover%' order by lastmodifiedDate Desc];
        for(Checklist__c chk:handoverCheckLists){
            if(!luToHandoverMap.containsKey(chk.Lease_Unit__c)){
                luToHandoverMap.put(chk.Lease_Unit__c,chk);
            }
        }
        
        Map<Id,Units__c> unitMap = new Map<Id,Units__c>([Select id,Property__c,Authorised_Person__c,Person_In_Charge__c from Units__c where id in:unitIds]);
        for(Units__c unt:unitMap.values()){
            propIds.add(unt.Property__c);
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        if(conIds.size()>0){
            conMap = new Map<Id,Contact>([Select id,Name,Email,Phone,Title,NRIC__c from Contact where id in:conIds]);
        }
        
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,(Select id,Name,Type__c,Description__c,Mobile_Module__c from Checklist_Templates__r where Type__c='Takeover (Shop)') from Property__c where id in:propIds]);
        
        List<CheckListWrapper> chklstWrapList = new List<CheckListWrapper>();
        for(Lease_Unit__c lu:Trigger.New){
            if(lu.Generate_Takeover_Shop_CheckList__c && lu.Generate_Takeover_Shop_CheckList__c!=Trigger.OldMap.get(lu.id).Generate_Takeover_Shop_CheckList__c){
                if(lu.Unit__c!=null && unitMap.containsKey(lu.Unit__c)){
                    units__c unt = unitMap.get(lu.Unit__c);
                    If(propMap.containsKey(unt.Property__c)){
                        system.debug('===check3');
                        Property__c prop = propMap.get(unt.Property__c);
                        if(prop.Checklist_Templates__r.size()>0){
                            system.debug('===check4');
                            for(Checklist_Master__c cm:prop.Checklist_Templates__r){
                                CheckListWrapper clw = new CheckListWrapper();
                                clw.chkLst.Checklist_Master__c = cm.Id;
                                clw.chkLst.Mobile_Module__c = cm.Mobile_Module__c;
                                clw.chkLst.Description__c = cm.Description__c;
                                clw.chkLst.Type__c = cm.Type__c;
                                clw.ChkLst.Unit__c = unt.Id;
                                clw.ChkLst.Lease_Unit__c = lu.Id;
                                clw.chkLst.AP__c = lu.Authorised_Person__c;
                                clw.chkLst.PIC__c = lu.Person_In_Charge__c;
                                clw.chkLst.Target_Date__c = lu.Handover_Date__c;
                                
                                
                                if(conMap.containskey(lu.Authorised_Person__c)){
                                    contact con = conMap.get(lu.Authorised_Person__c);
                                    clw.chkLst.AP_Name__c = con.Name;
                                    clw.chkLst.AP_Email__c = con.Email;
                                    clw.chkLst.AP_Phone__c = con.Phone;
                                    clw.chkLst.AP_Position__c = con.Title;
                                    clw.chkLst.AP_NRIC__c = con.NRIC__c;
                                    
                                }
                                
                                if(conMap.containskey(lu.Person_In_Charge__c)){
                                    contact con = conMap.get(lu.Person_In_Charge__c);
                                    clw.chkLst.PIC_Name__c = con.Name;
                                    clw.chkLst.PIC_Email__c = con.Email;
                                    clw.chkLst.PIC_Phone__c = con.Phone;
                                    clw.chkLst.PIC_Position__c = con.Title;
                                    clw.chkLst.PIC_NRIC__c = con.NRIC__c;
                                }
                                
                                if(luToHandoverMap.containsKey(lu.Id)){
                                    if(luToHandoverMap.get(lu.Id).Checklist_Items__r.size()>0){
                                        for(Checklist_Item__c handoverCLI :luToHandoverMap.get(lu.Id).Checklist_Items__r){
                                            Checklist_Item__c cli = handoverCLI.clone(false,false,false,false);
                                            clw.chkLstItms.add(cli);
                                        }
                                    }
                                }
                                chklstWrapList.add(clw);
                            }
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
                        
            List<Checklist_Item__c> chklstItemList = new List<Checklist_Item__c>();
            for(CheckListWrapper clw:chklstWrapList){
                if(clw.chkLst.Id!=null){
                    for(Checklist_Item__c cli:clw.chkLstItms){
                        cli.Checklist__c = clw.chkLst.Id;
                        chklstItemList.add(cli);
                    }
                }
            }
            if(chklstItemList.size()>0){
                insert chklstItemList;
            }
        }        
    }
    
    class CheckListWrapper{
        Checklist__c chkLst;
        List<Checklist_Item__c> chkLstItms;
        CheckListWrapper(){
            chkLst = new CheckList__c();
            chkLstItms = new List<Checklist_Item__c>();
        }
    }
}