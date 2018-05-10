@isTest
class ConsumableStockOutControllerTest{
    @isTest
    static void test1(){
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
        
        Equipment__c eqp= new Equipment__c();
        eqp.Action__c = 'New';
        eqp.Fixed_Asset_ID__c = 'Test12345';
        eqp.Inventory_ID__c = inv.Id;
        eqp.Product_Name__c = product.Id;
        insert eqp;
        
        Inventory_Tracking__c invTrack = new Inventory_Tracking__c();
        invTrack.Date__c = system.today();
        invTrack.IN_OUT__c = 'In';
        invTrack.Inventory_ID__c = inv.Id;
        invTrack.Product_Name__c = product.Id;
        invTrack.Quantity__c = 5;
        invTrack.Stock_Warehouse__c = stk.Id;
        invTrack.Equipment__c = eqp.Id;
        insert invTrack;
        
        Apexpages.CurrentPage().getParameters().put('Id',inv.Id);
        ConsumableStockOutController cs = new ConsumableStockOutController();
        cs.Quantity = 1;
        cs.stockOut();
        
    }    
}