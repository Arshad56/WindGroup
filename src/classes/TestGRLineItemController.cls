@isTest
public class TestGRLineItemController{
    @isTest
    static void test1(){
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Draft';
        po.PO_End_Date__c=date.today()+30;
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        insert po;
        
        COA_FY_Balance__c cb=new COA_FY_Balance__c();
        cb.Budget_Amount__c=3000;
        insert cb;
        
        PO_Line_Item__c pol=new PO_Line_Item__c();
        pol.Amount__c=150;
        pol.COA_FY_Balance__c=cb.Id;
        pol.Purchase_Order__c=po.Id;
        pol.Budget_Line__c='Hardware Maintenance';
        pol.Quantity__c=1;
        pol.Product_Type__c = 'Consumable';
        insert pol;
        
        /*PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Purchase_Order__c=po.Id;
        insert pa;*/
          
        po.PO_Line_Validation_Bypass__c = true;
        po.Status__c='Issued';
        update po;
                
        Goods_Receipt__c gr=new Goods_Receipt__c();
        gr.Purchase_Order__c=po.Id;
        insert gr;
        
        GR_Line_Item__c gri=new GR_Line_Item__c();
        gri.PO_Line_Item__c=pol.Id;
        gri.Goods_Receipt__c=gr.Id;
        insert gri;
        
        Inventory__c inv = new Inventory__c();
        inv.Name = 'TestInventory';
        insert inv;
        
        Inventory_Tracking__c invTk = new Inventory_Tracking__c();
        invTk.GR_Line_Item__c = gri.Id;
        invTk.Inventory_ID__c = inv.Id;
        insert invTk;
        
        GRLineItemController.updateRecord(gri.Id,'Write Off',po.Id,'Test');
    }
}