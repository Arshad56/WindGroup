public class NewLOICompController {
	//This function is used to check Expression of interest unit and property
    @AuraEnabled
    public static String checkExpressionIntUnit(String recordId){
        String msg = '';
        List<Expression_of_Interest__c> expIntList = [SELECT Id,Property_Name__c,Unit_No__c,Account_Name__c,Contact_Name__c,Commencement_Date__c,
                                                      Expiry_Date__c
                                                      FROM Expression_of_Interest__c WHERE  Id =: recordId];
        
        if(expIntList.size() > 0 ){
            Expression_of_Interest__c expInt = expIntList.get(0);
            
            if(expInt.Account_Name__c == null || expInt.Contact_Name__c == null || expInt.Property_Name__c == null
               || expInt.Commencement_Date__c == null || expInt.Expiry_Date__c == null || expInt.Unit_No__c == null){
                msg = 'Error: Property, Unit, Tenant, Contact, commencement date and expiry date are mandatory fields.';
                return msg;
            }else{
                String sDate = expInt.Commencement_Date__c.year() +'-'+ expInt.Commencement_Date__c.month() +'-'+ expInt.Commencement_Date__c.day();
                String eDate = expInt.Expiry_Date__c.year() +'-'+ expInt.Expiry_Date__c.month() +'-'+ expInt.Expiry_Date__c.day();
                
                msg = 'accId='+expInt.Account_Name__c+'&conId='+expInt.Contact_Name__c+'&propId='+expInt.Property_Name__c+'&unitId='+expInt.Unit_No__c;
            	msg += '&sDate='+sDate+'&eDate='+eDate;
              
                return msg;
            }
        }
        return msg;
    }
}