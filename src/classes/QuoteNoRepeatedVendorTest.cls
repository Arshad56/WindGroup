/*
 *  Name         : QuoteNoRepeatedVendorTest
 *  Author       : Mohd Anas
 *  Created Date : 10th July 2017 
 *  Description  : The unit test class for Trigger QuoteNoRepeatedVendor
*/
@isTest
public class QuoteNoRepeatedVendorTest{
    @isTest
    public static void quoteNoRepeatedVendorMethod(){
        Purchase_Order__c po = new Purchase_Order__c();
        po.PO_Start_Date__c = System.today();
        po.Po_End_Date__c = system.today()+20;
        po.Status__c = 'Draft';
        insert po;
        
        Account acc = new Account();
        acc.name = 'TestAccount';
        insert acc;
        
        List<Quote__c> qList = new List<Quote__c>();
        Quote__c qo1 = new Quote__c();
        qo1.PO_No__c= po.id;
        qo1.vendor_name__c = acc.id;
        insert qo1;
        
        Quote__c qo2 = new Quote__c();
        qo2.PO_No__c= po.id;
        qo2.vendor_name__c = acc.id;
        
        
        try{
            insert qo2;
            system.assert(FALSE,'Quote with this vendor already exists');
        }
        catch(DMLException e){
            System.assert(TRUE,'Trigger Test Failed');
        }    
    }
}