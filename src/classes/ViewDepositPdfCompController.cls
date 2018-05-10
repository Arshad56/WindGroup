public class ViewDepositPdfCompController {
    
    @AuraEnabled 
    public static string checkStatus(string recordId){
        string infoMsg = 'Success';
        List<Deposit__c> depoList = [SELECT Id, Deposit_Generated__c, (SELECT Id FROM Attachments ORDER BY CreatedDate DESC)
                                     FROM Deposit__c 
                                     WHERE Id =:recordId];
        if(depoList.size() > 0){
            Deposit__c deposit = depoList.get(0);
            if(!deposit.Deposit_Generated__c){
                infoMsg = 'Info: Attachment Not found, Please make sure Attachment is generated. ';
                return infoMsg;
            }
            else if(deposit.Attachments.size() == 0){
                infoMsg = 'Info: Attachment Not found, Please make sure Attachment is generated.';
                return infoMsg;
            }
            infoMsg = ''+deposit.Attachments.get(0).Id;
        }
        return infoMsg;
    }
    
}