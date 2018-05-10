@isTest
public class PurchaseOrderLineItmTriggerTest {
    
    Static testmethod void testAmount(){
        Purchase_Order__c po = new Purchase_Order__c();
        po.PO_Start_Date__c = system.today();
        po.Status__c = 'Draft';
        po.PO_End_Date__c = system.today()-3;
        po.Currency_Code__c = label.Base_Foreign_Currency;
        insert po;
        
        Purchase_Order__c po1 = new Purchase_Order__c();
        po1.PO_Start_Date__c = system.today();
        po1.Status__c = 'Draft';
        po1.PO_End_Date__c = system.today()-3;
        po1.Currency_Code__c = label.Base_Foreign_Currency;
        insert po1;
        
        COA_FY_Balance__c coy = new COA_FY_Balance__c();
        coy.Budget_Amount__c = 2000;
        insert coy;
        
        
        COA_FY_Balance__c coy1 = new COA_FY_Balance__c();
        coy1.Budget_Amount__c = 2000;
        insert coy1;
        
        PO_Line_Item__c pol = new PO_Line_Item__c();
        pol.Budget_Line__c = 'Hardware Maintenance';
        pol.Quantity__c = 1000;
        pol.Amount__c = 1000;
        pol.COA_FY_Balance__c = coy.id;
        pol.Purchase_Order__c =po.id;
        pol.Product_Type__c = 'Equipment';
        insert pol;
        
        pol.Amount__c = 2000;
        pol.Quantity__c = 100;
        pol.COA_FY_Balance__c = coy1.id;
        //pol.Purchase_Order__c = po1.Id;
        update pol;
    }
}