/*
*    Name          :        LoiCloning Controller
*    Author        :        Mohd Anas    
*    Date          :        12th May 2017
*    Description   :        Controller to Clone LOI, LOI Unit,LOI Charges, Deposit, Checklist, CheckList Items
*/

public class LoiCloningController{

    public LOI__c loi{ get; set; }
    public LOI__c newLoi{ get; set; }
    public List<loiUnitWrapper> wrapUnit{ get; set; }
    public LOI__c originalLoi{ get; set; }
    
       
    public LoiCloningController(){
        loi = new LOI__c();
        loi.id=ApexPages.CurrentPage().getParameters().get('loiId');
        init();
    }
    
    
    private void init(){
        //------------------------------------------
        String str = allFieldsString(loi);
        str+=' WHERE id=\''+loi.id+'\'';
        originalLoi= Database.query(str);
        
        //-------------------------------------------
        
        Loi_Unit__c loiUnit = new Loi_Unit__c();
        str=allFieldsString(loiUnit);
        str+=' WHERE LOI_Agreement_No__c =\''+loi.id+'\'';
        //originalLoiUnit = Database.query(str);
        
        wrapunit = new List<loiUnitWrapper>();
        for(LOI_Unit__c uniList: Database.query(str)){
            wrapUnit.add(new loiUnitWrapper(uniList));
        }
         
    }
       
   //-----------------------------------------------Cloning Process----------------------------------------------------- 
   //------------------------------------------------------------------------------------------------------------------- 
    public pageReference cloneLoi(){
       
        String str;
        List<LOi_Charges__c> originalCharges;
        List<Deposit__c> originalDeposit;
        List<CheckList__c> originalChecklist;
        List<Checklist_item__c> ckListItemList;
        Set<id> loiUnitIdSet = new Set<id>();
        
        
        for(loiUnitWrapper wp: wrapunit){
            if(wp.isSelected)
                loiUnitIdSet.add(wp.uni.id);
        }
       
        //--------------------------------------------
        LOI_Charges__c loiCharges  = new LOI_Charges__c();
        str=allFieldsString(loiCharges);
        str+=' WHERE LOI_Unit__c in :loiUnitIdSet';
        originalCharges = Database.query(str);
        
        //-------------------------------------------- 
        Deposit__c dep = new Deposit__c();
        str=allFieldsString(dep);
        str+=' WHERE LOI_Unit__c in :loiUnitIdSet OR LOI__c = \''+loi.id+'\'';
        originalDeposit = Database.query(str);
        
        //------------------------------------------------------
        Checklist__c chekList = new CheckList__c();
        str=allFieldsString(chekList);
        str+=' WHERE Loi_Unit__c in :loiUnitIdSet';
        originalChecklist = Database.query(str);
        Set<id> originalChecklistId = new Set<id>();
        for(checklist__c cklist : originalChecklist)
            originalChecklistid.add(cklist.id);
        
        
        //----------------------------------------------------
        
        Checklist_item__c ckListItems = new Checklist_item__c();
        str=allFieldsString(ckListItems);
        str+=' WHERE CheckList__c in :originalCheckListid';
        ckListItemList = Database.query(str);
        
        Savepoint sp = Database.setSavepoint();
        try{
            //---------------------------------Naming LOI, LOI UNIT and DEPOSIT-----------------------------
            Integer currentMonth = system.today().month();   
            Integer currentYear = system.today().Year();
            Integer  loiIndex = 0;
            Integer  loiUnitIndex = 0;
            Integer DepIndex = 0;
            property__c pro=[Select LOI_Unit_Index__c,LOI_Index__c,Deposit_Index__c,short_code__c from property__c where id = :originalLoi.Property__c];
                System.debug('pro-->'+pro);
            if(pro.LOI_Index__c != null)
                loiIndex = Integer.valueOf(''+pro.LOI_Index__c);
            
            if(pro.LOI_Unit_Index__c != null)
                loiUnitIndex = Integer.valueOf(''+pro.LOI_Unit_Index__c);
            
            if(pro.Deposit_Index__c!= null)
                depIndex= Integer.valueOf(''+pro.Deposit_Index__c);
                
            pro.LOI_Index__c = ++loiIndex;

            
            string indxVal = addZeroIndex(loiIndex);
            string loiUnitindxVal;
            string depIndxVal;    
            String loiname = pro.Short_Code__c+'-LOI-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+indxVal;
            String loiUnitname;    
            String depName;    
               
        
            //-------------------------------------------Cloning LOI-------------------------------------------
            newLoi=originalLoi.clone(false);
            newLoi.name=loiname;//LOI Name SetUp---------------------------------------------------------
            system.debug(newLoi);
               
            insert newLoi;
                         
            //-------------------------------------------Cloning LOI Units-------------------------------------------
            if(newLoi.id != NULL){
                Loi_Unit__c loiUnit = new Loi_Unit__c();
                Map<id,Loi_Unit__c> oldUnitMapWithCloneUnit = new Map<id,Loi_Unit__c>();
                List<Loi_Unit__c> unitListToInsert= new List<Loi_Unit__c>();
                 
                for(loiUnitWrapper oldUni: wrapunit){
                    
                    if(!oldUnitMapWithCloneUnit.containsKey(oldUni.uni.id) && oldUni.isSelected == TRUE){
                        
                        pro.LOI_Unit_Index__c = ++loiUnitIndex;
                        loiUnitindxVal = addZeroIndex(loiUnitIndex);
                        loiUnitname = pro.Short_Code__c+'-LOIU-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+loiUnitindxVal;
                        
                        loiUnit = oldUni.uni.clone(false);
                        loiUnit.Name=loiUnitname;//loiUnitName---------------------------------------------------------
                        loiUnit.LOI_Agreement_No__c = newLoi.id;
                        oldUnitMapWithCloneUnit.put(oldUni.uni.id,loiUnit);
                        unitListToInsert.add(loiUnit);
                    }
                                        
                }
                if(unitListToInsert.size()>0)
                    insert unitListToInsert;
                           
               //-------------------------------------------Cloning LOI Unit Charges-------------------------------------------
                loiCharges  = new LOI_Charges__c();
                List<LOI_Charges__c> newLoiChargesList = new List<LOI_Charges__c>();
                
                for(LOI_Charges__c oldCharges : originalCharges){
                       loiCharges = oldCharges.clone(false);
                       if(oldUnitMapWithCloneUnit.containsKey(oldCharges.LOI_Unit__c)){
                           LOI_Unit__c tempNewInsertedUnitId=oldUnitMapWithCloneUnit.get(oldCharges.LOI_Unit__c);
                           loiCharges.LOI_Unit__c=tempNewInsertedUnitId.id;
                       }
                       newLoiChargesList.add(loiCharges);
                }
                if(newLoiChargesList.size()>0)
                    insert newLoiChargesList;
                          
               
                //-------------------------------------------Cloning Deposit-------------------------------------------   
                
                
                List<Deposit__c> newLoiUnitDepositList = new List<Deposit__c>();
                for(Deposit__c oldDeposit : originalDeposit){
                       pro.Deposit_Index__c=++depIndex;
                       depIndxVal= addZeroIndex(depIndex);
                       depName=pro.Short_Code__c+'-DI-'+currentYear+(currentMonth<10?'0'+currentMonth:''+currentMonth)+'-'+depIndxVal;
                       dep = oldDeposit.clone(false);
                       if(oldUnitMapWithCloneUnit.containsKey(oldDeposit.LOI_Unit__c)){
                           LOI_Unit__c tempNewInsertedUnitId=oldUnitMapWithCloneUnit.get(oldDeposit.LOI_Unit__c);                   
                       
                           dep.LOI_Unit__c=tempNewInsertedUnitId.id;
                           dep.name=depName;//depositnamesetup---------------------------------------------------------
                       
                       }
                      
                      if(oldDeposit.LOI__c != NULL){
                          dep.LOI__c=newLoi.id;
                          dep.name=depName;//depositnamesetup---------------------------------------------------------
                      }
                      
                       newLoiUnitDepositList.add(dep);
                }
                if(newLoiUnitDepositList.size()>0)
                    insert newLoiUnitDepositList; 
                
                
                            
                //-------------------------------------------Cloning checklists-------------------------------------------
                List<checklist__c> newChecklist = new List<Checklist__c>();
                Map<id,Checklist__c> cheklistMap = new Map<id,Checklist__c>();
                for(Checklist__c cklist : originalChecklist){
                    if(oldUnitMapWithCloneUnit.containsKey(ckList.Loi_Unit__c)){
                        Loi_Unit__c tempLoiUnitobj = oldUnitMapWithCloneUnit.get(ckList.Loi_Unit__c);
                        Checklist__c newcklistObj = cklist.clone(false);
                        newcklistObj.Loi_Unit__c=tempLoiUnitObj.id;
                        cheklistMap.put(cklist.id,newckListObj);
                        newChecklist.add(newcklistObj);
                    }
                }
                if(newChecklist.size()>0)
                    insert newChecklist;
                    
                //-------------------------------------------Cloning checklist item-------------------------------------------
                List<Checklist_item__c> newCheckListItem = new List<Checklist_Item__c>();
                for(Checklist_item__c cklistItem : ckListItemList){
                    If(cheklistMap.containsKey(cklistItem.Checklist__c)){
                        Checklist__c tempCklistObj = cheklistMap.get(cklistItem.Checklist__c);
                        Checklist_item__c tempcklistItemObj = cklistItem.clone(false);
                        tempcklistItemObj.Checklist__c = tempCklistObj.id;
                        newCheckListItem.add(tempcklistItemObj);
                    }
                }
                if(newCheckListItem.size()>0)
                    insert newCheckListItem;
            }
            
             update pro;
        }
        catch(Exception e ){
            System.debug(e);
            Database.rollback(sp);
            return NULL;
        }
        return new pageReference('/'+newloi.id);
    }
     
     
    //-------------------------Function that returns QUERY string with all field separated by comma by supplying SObject Name-------------------------------------
    private string allFieldsString(Sobject obj){
        String commaSeparated='';
        Schema.SObjectType objType = obj.getSObjectType();
        Map<string,Schema.SobjectField> fieldMap = Schema.getGlobalDescribe().get(string.valueOf(objType)).getDescribe().fields.getMap();
        
        for(String fieldName : fieldMap.keySet()){
            if(commaSeparated == NULL || commaSeparated == '')
                commaSeparated=fieldName;
            else
                commaSeparated+=','+fieldName; 
        }
        if(commaSeparated != NULL || commaSeparated != '')
            commaSeparated='SELECT '+commaSeparated+' From '+objType;
            
        return commaSeparated;
    }
    
    
     
    //------------------------------------Creating zeros string for names---------------------------------------------
    private string addZeroIndex(Integer indexVal){
        Integer indexSize = string.valueOf(indexVal).length();
        String zeroVal = '';
        for(integer i =1;i<=6-indexSize;i++){
            zeroVal += '0';
        }
        return zeroVal+indexVal;
    }
    
    
    //----------------------------UNIT WRAPPER USED FOR SELECTION--------------------------------------------------
    private class loiUnitWrapper{
        public Boolean isSelected{ get; set; }
        public Loi_Unit__c Uni{ get; set; }
        public loiUnitWrapper(Loi_Unit__c u){
            isSelected=FALSE;
            uni = u;
        }
    }
}