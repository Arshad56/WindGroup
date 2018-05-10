@isTest
class EquipmentTransferControllerTest{

    @isTest
    static void test2(){
        Item_Catalogue__c product = new Item_Catalogue__c();
        product.Name = 'Prod1';
        product.Amount__c = 100;
        product.Department__c ='Operations';
        product.Expiry_Date__c = system.today().addYears(1);
        product.Product_Type__c = 'Equipment';
        product.Status__c = 'Active';
        insert product;
        
        Stock__c stk = new Stock__c();
        stk.Name = 'Stock1';
        insert stk;
        
        Inventory__c inv = new Inventory__c();
        inv.Product_Name__c = product.Id;
        inv.Stock_Warehouse__c = stk.Id;
        insert inv;
        
        Stock__c stk1 = new Stock__c();
        stk1.Name = 'Stock2';
        insert stk1;
        
        Inventory__c inv1 = new Inventory__c();
        inv1.Product_Name__c = product.Id;
        inv1.Stock_Warehouse__c = stk1.Id;
        insert inv1;
        
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
        invTrack.Quantity__c = 1;
        invTrack.Stock_Warehouse__c = stk.Id;
        invTrack.Equipment__c = eqp.Id;
        insert invTrack;
        
        
        
        Item_Catalogue__c product1 = new Item_Catalogue__c();
        product1.Name = 'Prod2';
        product1.Amount__c = 100;
        product1.Department__c ='Operations';
        product1.Expiry_Date__c = system.today().addYears(1);
        product1.Product_Type__c = 'Equipment';
        product1.Status__c = 'Active';
        insert product1;
        
        Apexpages.CurrentPage().getParameters().put('Ids',eqp.Id);
        EquipmentTransferController etc = new EquipmentTransferController();
        Apexpages.CurrentPage().getParameters().put('selInv',inv1.Id);
        etc.Transfer();
        
    }
}