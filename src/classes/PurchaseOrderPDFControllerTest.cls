/*
* Name             :       PurchaseOrderPDFControllerTest
* Author           :       Prabhakar Joshi
* Date             :       05 July 2017
* Description      :       Test class for PurchaseOrderPDFController.
*/

@isTest
public class PurchaseOrderPDFControllerTest {
@isTest
    static void test1(){
        Account ac1=new Account();
        ac1.Name='testAc1';
        insert ac1;
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Draft';
        po.PO_End_Date__c=date.today()+30;
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        po.Generate_PO_PDF__c=false;
        po.Vendor_Name__c=ac1.id;
        insert po;
        
        COA_FY_Balance__c cb=new COA_FY_Balance__c();
        cb.Budget_Amount__c=3000;
        insert cb;
        
        PO_Line_Item__c pol=new PO_Line_Item__c();
        pol.Amount__c=2000;
        pol.COA_FY_Balance__c=cb.Id;
        pol.Purchase_Order__c=po.Id;
        pol.Budget_Line__c='Hardware Maintenance';
        pol.Product_Type__c = 'Equipment';
        pol.Quantity__c=1;
        
        insert pol;
        
        PageReference pageRef = Page.PurchaseOrderPDF;
        pageRef.getParameters().put('id',po.Id);
        Test.setCurrentPage(pageRef);
        PurchaseOrderPDFController obj=new PurchaseOrderPDFController();
    }
}