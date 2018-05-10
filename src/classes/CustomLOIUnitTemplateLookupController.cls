public class CustomLOIUnitTemplateLookupController {
public string loiUnitSearch{get;set;}
    public List<LOI_Unit_Template__c> loiUnitResult{get;set;}
    string UnitId;
    string propId;
    public string unitChargeMethod{get;set;}
    Date loiStartDate;
    Date loiEndDate;
    public CustomLOIUnitTemplateLookupController(){
        UnitId=ApexPages.currentPage().getParameters().get('untId');
        propId=ApexPages.currentPage().getParameters().get('prop');
        loiUnitSearch = System.currentPageReference().getParameters().get('lksrch');
        if(loiUnitSearch != null && loiUnitSearch.containsAny('\'')){
            loiUnitSearch = String.escapeSingleQuotes(loiUnitSearch);
        }
        
        if(ApexPages.currentPage().getParameters().get('loiStart')!=null){
            List<string> tempList = ApexPages.currentPage().getParameters().get('loiStart').split('-');
            loiStartDate = date.newInstance(Integer.valueOf(tempList[0]),Integer.valueOf(tempList[1]),Integer.valueOf(tempList[2]));
        }
        
        if(ApexPages.currentPage().getParameters().get('loiEnd')!=null){
            List<string> tempList = ApexPages.currentPage().getParameters().get('loiEnd').split('-');
            loiEndDate = date.newInstance(Integer.valueOf(tempList[0]),Integer.valueOf(tempList[1]),Integer.valueOf(tempList[2]));
        }
        
        runSearch();
        
    }
    
    private void runSearch(){
      if(UnitId==null || propId==NULL)
           ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please Select a Unit and Property first'));
      else if(UnitId!=NULL && propId!=NULL){
            List<Units__c> unitList = [Select id,charge_Method__c from Units__c where id=:unitId];
            if(unitList.size()>0){
                unitChargeMethod = unitList[0].Charge_Method__c;
                String str='SELECT name,Unit__r.name,LOI_Unit_Template_Name__c,Property_Lookup__r.name,Trade_Category__c,Sub_Trade_Category__c,Start_Date__c,End_Date__c,Charge_Method__c,Space_Type__c from LOI_Unit_Template__c WHERE active__c=TRUE AND (Unit__c=\''+unitId+'\' OR Property_Lookup__c =\''+propId+'\') ' ;
                if(loiStartDate!=null && loiEndDate!=null){
                    //str += 'and Start_Date__c>=:loiStartDate and Start_Date__c<=:loiEndDate';
                    str += 'and Start_Date__c<=:loiStartDate and Start_Date__c<=:loiEndDate';
                }
                if(unitChargeMethod!=null){
                    if(unitChargeMethod.contains('Monthly Rate - L')){
                        str+=' and Space_Type__c!=\'Ad Panel\' and Space_Type__c!=\'Promo Space\'';
                    }else if(unitChargeMethod.contains('Monthly Rate - CL') || unitChargeMethod.contains('Daily Rate')){
                        str+=' and (Space_Type__c=\'Ad Panel\' or Space_Type__c=\'Promo Space\')';
                    }
                }
                if(loiUnitSearch!='' && loiUnitSearch!=NULL)
                    str+=' AND name LIKE \'%'+loiUnitSearch+'%\'';
                str+=' LIMIT 990';
                //system.debug(str);
                loiUnitResult=Database.query(str);
            }
            
            if(loiUnitResult.size()==0  || loiUnitResult.size()<0)
                ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'No records Found'));
        }
    }
    
    public pageReference search(){
        runSearch();
        return null;
    }
    public string getFormTag(){
        return ApexPages.currentPage().getParameters().get('frm');
    }
    public string getTextBox(){
        return Apexpages.currentPage().getParameters().get('txt');
    }
}