trigger CreateHandoverFitoutCheckList on Lease_Unit__c(after update){
 
    Set<Id> propIds = new Set<Id>();
    Set<Id> conIds = new Set<Id>();
    Set<Id> unitIds = new Set<Id>();
    for(Lease_Unit__c lu:Trigger.New){
        if(lu.Generate_CheckList__c && lu.Generate_CheckList__c!=Trigger.OldMap.get(lu.id).Generate_CheckList__c){
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
        Map<Id,Units__c> unitMap = new Map<Id,Units__c>([Select id,Property__c,Authorised_Person__c,Person_In_Charge__c,(Select id,Condition__c,Description__c,Issue_Types__c,Item_Type__c,Number__c,Parent_Condition__c,S_N__c from Conditions__r) from Units__c where id in:unitIds]);
        for(Units__c unt:unitMap.values()){
            propIds.add(unt.Property__c);
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        if(conIds.size()>0){
            conMap = new Map<Id,Contact>([Select id,Name,Email,Phone,Title,NRIC__c from Contact where id in:conIds]);
        }
        
        Map<Id,Property__c> propMap = new Map<Id,Property__c>();
        
        propMap = new Map<Id,Property__c>([Select id,(Select id,Name,Type__c,Description__c,Mobile_Module__c from Checklist_Templates__r where Type__c='Handover') from Property__c where id in:propIds]);
        
        Set<Id> chklstMasterIds = new Set<Id>();
        for(Property__c pr:propMap.values()){
            for(Checklist_Master__c cm:pr.Checklist_Templates__r){
                chklstMasterIds.add(cm.Id);
            }
        }
                
        List<CheckListWrapper> chklstWrapList = new List<CheckListWrapper>();
        List<Conditions__c> conditions = new List<Conditions__c>();
        for(Lease_Unit__c lu:Trigger.New){
            if(lu.Generate_CheckList__c && lu.Generate_CheckList__c!=Trigger.OldMap.get(lu.id).Generate_CheckList__c){
                if(lu.Unit__c!=null && unitMap.containsKey(lu.Unit__c)){
                    units__c unt = unitMap.get(lu.Unit__c);
                    If(propMap.containsKey(unt.Property__c)){
                        Property__c prop = propMap.get(unt.Property__c);
                        if(prop.Checklist_Templates__r.size()>0){
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
                                
                                if(unt.Conditions__r.size()>0){
                                    for(Conditions__c cd:unt.Conditions__r){
                                        Checklist_Item__c cli = new Checklist_Item__c();
                                        cli.Condition__c = cd.Condition__c;
                                        cli.Description__c = cd.Description__c;
                                        cli.Item_Type__c = cd.Item_Type__c;
                                        cli.Issue_Types__c = cd.Issue_Types__c;
                                        cli.Number__c = cd.Number__c;
                                        cli.SN__c = (cd.S_N__c!=null?String.valueOf(cd.S_N__c):'');
                                        cli.Handover_Condition__c= cd.Id;
                                        clw.chkLstItms.add(cli);
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