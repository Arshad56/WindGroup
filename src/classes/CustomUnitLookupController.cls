/*
*    Name           :    Custom Unit Lookup controller 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Controller for customised lookup to select Unit.
*/
public class CustomUnitLookupController {
    public string unitSearchString{ get; set; }
    public List<Units__c> unitSearchResult{ get; set; }
    public units__c uni { get; set; }
    string prop;
    public Date sDate,eDate;
    public string ChargeMethod{get;set;}
    
    public CustomUnitLookupController(){
        prop=ApexPages.currentPage().getParameters().get('prop');
        sDate=date.parse(ApexPages.currentPage().getParameters().get('sDate'));
        eDate=date.parse(ApexPages.currentPage().getParameters().get('eDate'));
        system.debug('sdate-------------'+sdate);
        system.debug('edate-------------'+edate);
        if(ApexPages.currentPage().getParameters().get('ChargeMethod')!=null && ApexPages.currentPage().getParameters().get('ChargeMethod').trim().length()>0){
            ChargeMethod = ApexPages.currentPage().getParameters().get('ChargeMethod');
        }
        
        unitSearchString = System.currentPageReference().getParameters().get('lksrch');
        uni= new Units__c();
        uni.Space_Type__c = '';
        unitSearchResult = new List<Units__c>();
        if(unitSearchString != null && unitSearchString.containsAny('\'')){
            unitSearchString = String.escapeSingleQuotes(unitSearchString);
        }
        if(ChargeMethod!=null && ChargeMethod.trim().length()>0){
            uni.Charge_Method__c = chargeMethod;
        }
        
        runSearch();
    }
    
    private void runSearch(){
        if(prop=='' || prop==NULL)
                ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please Select a Property'));
        else if(prop!=NULL){
            String str='SELECT name,Charge_Method__c,level__r.name,active__c,Start_Date__c,End_Date__c,Space_type__c,(select Unit__c from lease_units__r where (lease_Start_Date__c <=:sDate AND lease_End_Date__c >=:sDate) OR (lease_Start_Date__c <=:eDate AND lease_End_Date__c >=:eDate) LIMIT 1) from units__c WHERE property__c=\''+prop+'\'' ;
            
            if(uni.space_Type__c !='' && uni.space_Type__c != NULL)
                str+=' AND space_Type__c=\''+uni.Space_Type__c+'\'';
                
         /*   List<String> charMeth; 
            if(uni.Charge_Method__c !='' && uni.Charge_Method__c != NULL){
                charMeth = uni.Charge_Method__c.split(';');
                if(uni.Charge_Method__c!='' && uni.Charge_Method__c!= NULL)
                    str+=' AND Charge_Method__c IN :charMeth ';    
            }*/
            
             if(uni.Charge_Method__c !='' && uni.Charge_Method__c != NULL){
                str+= ' AND Charge_Method__c INCLUDES (';
                for(String includeValue :uni.Charge_Method__c.split(';'))
                    str+= '\''+ includeValue + '\',';
                    
                str = str.removeEnd(',') +')';                
            }
            
            
            if(unitSearchString != '' && unitSearchString != NULL)
                str+=' AND name LIKE \'%'+unitSearchString+'%\'';
            
            str+='LIMIT 990';
            unitSearchResult=Database.query(str);
            unitSearchResult.sort();
            system.debug('unitSearchResult----------------------->'+unitSearchResult);
            if(unitSearchResult.size()==0  || unitSearchResult.size()<0)
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