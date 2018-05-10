/*
*    Name             :     FullInvoiceReceiptControllerTest
*    Author           :     Mohd Anas
*    Date             :     5th July 2017
*    Description      :     Unit Test Class for Controller to full invoice receipt
*/

@isTest
public class FullInvoiceReceiptControllerTest{
    @isTest
    public static void fullInvoiceReceiptMethod(){
        
        //------------------------Data Insert Block------------------------------
        Purchase_Order__c po = new Purchase_order__c();
        po.Status__c = 'Draft';
        po.PO_Line_Validation_Bypass__c = false;
        insert po;
        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Purchase_Order__c=po.Id;
        insert pa;
        
        COA_FY_Balance__c coaBal = new COA_FY_Balance__c();
        insert coaBal;
        
        PO_Line_Item__c PoliItem = new PO_Line_Item__c();
        PoliItem.Purchase_order__c  =po.id;
        PoliItem.Quantity__c = 5;
        poliItem.Amount__c = 200;
        PoliItem.COA_FY_Balance__c=coaBal.Id;
        poliItem.Product_Type__c = 'Equipment';
        insert PoliItem;
        
        po.PO_Line_Validation_Bypass__c = true;
        po.Status__c = 'Issued';
        update po;
        
        Goods_Receipt__c gr = new Goods_Receipt__c();
        gr.Purchase_Order__c = po.id;
        insert gr;
        
        GR_Line_Item__c grLineItem = new GR_Line_Item__c();
        grLineItem.Goods_Receipt__c = gr.id;
        grLineItem.PO_Line_Item__c = PoliItem.id;
        grLineItem.Quantity__c = 2;
        grLineItem.Amount__c = 200;
        insert grLineItem;
        
        po.PO_Line_Validation_Bypass__c = false;
        update po;
        
        //------------------------End Data Insert Block------------------------------
        
        FullInvoiceReceiptController cntr0 = new FullInvoiceReceiptController();
        
        //------------------------Passing page parameter------------------------------
        Test.setCurrentPageReference(new pageReference('Page.GenerateFullInvoiceReciept'));
        System.currentPageReference().getParameters().put('poId', po.id);      
        
        //------------------------Checking when PO Balance in not zero------------------------------
        FullInvoiceReceiptController cntr1 = new FullInvoiceReceiptController();
        
        //------------------------Updating PO Balance to zero and inserting an invoice---------------
        Invoice_receipt__c inv = new Invoice_Receipt__c();
        inv.Purchase_Order__c = po.id;
        insert inv; 
        
        po.PO_Line_Validation_Bypass__c = True;
        update po;
        
        grLineItem.Quantity__c = 5;
        update grLineItem;
        
        po.PO_Line_Validation_Bypass__c = false;
        update po;
        
        FullInvoiceReceiptController cntr = new FullInvoiceReceiptController();
        cntr.errorLock = false;
        cntr.saveFullInvoice();
        
        po.PO_Line_Validation_Bypass__c = true;
        update po;        
        cntr.saveFullInvoice();
        
        cntr.errorLock = True;
        cntr.saveFullInvoice();
    }
}