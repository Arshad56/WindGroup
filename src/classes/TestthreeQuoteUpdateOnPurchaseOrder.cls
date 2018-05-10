@isTest
public class TestthreeQuoteUpdateOnPurchaseOrder{
    
    public static TestMethod void Test(){
        Purchase_Order__c po = new Purchase_Order__c();
        po.PO_Start_Date__c = System.today();
        po.Po_End_Date__c = system.today()+20;
        po.Status__c = 'Draft';
        insert po;
        
        Account acc = new Account();
        acc.name = 'TestAccount';
        insert acc;
        
        Quote__c qo1 = new Quote__c();
        qo1.PO_No__c= po.id;
        qo1.vendor_name__c = acc.id;
        insert qo1;
        
        Attachment att = new Attachment();
        att.Name = 'Test';
        att.parentId = qo1.Id;
        att.body = blob.valueOf('Test');
        insert att;
    }
}