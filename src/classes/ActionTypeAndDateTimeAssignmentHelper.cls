public class ActionTypeAndDateTimeAssignmentHelper
{
    public static void ProcessActionTypeDateTime(List<Sobject> recordToProcess)
    {
    try{
        for(Sobject sobjRec : recordToProcess)
        {
            system.debug('Utility.lastUpdatedFromAwsIntegration-->'+Utility.lastUpdatedFromAwsIntegration);
            if(Utility.lastUpdatedFromAwsIntegration =='SF')
            {
                sobjRec.put('Last_Updated_From__c', 'SF');
                sobjRec.put('Last_Update_Date_Time__c', System.now());
                sobjRec.put('Backend_Last_Updated_DateTime__c', System.now());
            }    
            else
            {
                system.debug('Last_Update_Date_Time__c--->'+sobjRec.get('Last_Update_Date_Time__c'));
                system.debug('Backend_Last_Updated_DateTime__c--->'+sobjRec.get('Backend_Last_Updated_DateTime__c'));
                if(sobjRec.get('Last_Update_Date_Time__c')==null || sobjRec.get('Backend_Last_Updated_DateTime__c')==null)
                {
                    sobjRec.put('Last_Updated_From__c', Utility.lastUpdatedFromAwsIntegration);
                    if(sobjRec.get('Backend_Last_Updated_DateTime__c')==null)
                    {
                        sobjRec.put('Last_Update_Date_Time__c', System.now());
                        sobjRec.put('Backend_Last_Updated_DateTime__c', System.now());
                    }
                    else
                    sobjRec.put('Last_Update_Date_Time__c', sobjRec.get('Backend_Last_Updated_DateTime__c'));
                }
                else 
                {
                    if(Datetime.Valueof(sobjRec.get('Backend_Last_Updated_DateTime__c'))>=Datetime.Valueof(sobjRec.get('Last_Update_Date_Time__c')))
                    {
                        sobjRec.put('Last_Updated_From__c', Utility.lastUpdatedFromAwsIntegration);
                        sobjRec.put('Last_Update_Date_Time__c', sobjRec.get('Backend_Last_Updated_DateTime__c'));
                    }
                    else
                    {
                        sobjRec.addError('This is record stopped to update to avoid overriding of Salesforce latest updates by '+Utility.lastUpdatedFromAwsIntegration+'. Please note this is not error or exception. This message to stop the update of the record');
                    }
                }    
            }
        }
       }catch(Exception e){} 
        
    }
}