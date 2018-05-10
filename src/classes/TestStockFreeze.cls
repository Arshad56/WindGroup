@isTest
public class TestStockFreeze {
    Static TestMethod void Test(){ 
        Item_Catalogue__c product = new Item_Catalogue__c();
        product.Name = 'Prod1';
        product.Amount__c = 100;
        product.Department__c ='Operations';
        product.Expiry_Date__c = system.today().addYears(1);
        product.Product_Type__c = 'Consumable';
        product.Status__c = 'Active';
        insert product;
        
        Stock__c stk = new Stock__c();
        stk.Name = 'Stock1';
        insert stk;
        
        Inventory__c inv = new Inventory__c();
        inv.Product_Name__c = product.Id;
        inv.Stock_Warehouse__c = stk.Id;
        insert inv;

        stk.Stock_Freeze__c = true;
        update stk;
        
        stk.Stock_Freeze__c = false;
        update stk;
    }
}