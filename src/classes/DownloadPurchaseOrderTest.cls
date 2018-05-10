/*
*    Name             :     DownloadPurchaseOrderTest
*    Author           :     Mohd Anas
*    Date             :     5th July 2017 
*    Description      :     Unit test class for DownloadPurchaseOrder future class
*/
@isTest
public class DownloadPurchaseOrderTest {
    @isTest
    public static void downloadPurchaseOrderMethod(){
         
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
        grLineItem.Quantity__c = 5;
        grLineItem.Amount__c = 200;
        insert grLineItem;
        
        po.PO_Line_Validation_Bypass__c = false;
        update po;
        
        
        //------------------------End Data Insert Block------------------------------
        
        Set<id> poIdSet = new Set<Id>();
        poIdSet.add(po.id);
        
        DownloadPurchaseOrder.generatePDFAsAttachment(poIdSet);
        
        
        Attachment att = new Attachment();
        att.name = 'test Attachment';
        att.Body = blob.valueOf('test data');
        att.ParentId = po.id;
        insert att;
        DownloadPurchaseOrder.generatePDFAsAttachment(poIdSet);
        
    }
}