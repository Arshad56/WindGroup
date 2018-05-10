public with sharing class NotifyEmailHelper {
     public static void NotifyTheseRec(String notify,Set<Id> ids){
        if(notify == 'Finance')
            NotifyFinance_Helper.NotifyFinanceUsers(ids);
        if(notify == 'Billing')
            NotifyBilling_Helper.NotifyBillingUsers(ids); 
    }  
}