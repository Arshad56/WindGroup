public class AddToLOICompController {
    //This function is used to check Expression of interest unit and property
    @AuraEnabled
    public static String checkExpressionIntUnit(String recordId){
        String msg = '';
        List<Expression_of_Interest__c> expIntList = [SELECT Id,Property_Name__c,Unit_No__c,Account_Name__c 
                                                      FROM Expression_of_Interest__c WHERE  Id =: recordId];
        
        if(expIntList.size() > 0 ){
            Expression_of_Interest__c expInt = expIntList.get(0);
            
            if(expInt.Property_Name__c == null || expInt.Unit_No__c == null){
                msg = 'Error: Property and Unit are mandatory.';
                return msg;
            }else{
                msg = 'propid='+expInt.Property_Name__c+'&unitId='+expInt.Unit_No__c;
            	
                if(expInt.Account_Name__c != null)
                    msg += '&tenantId='+expInt.Account_Name__c ;
                return msg;
            }
        }
        return msg;
    }
}