public class StockIn_Extension {
    
    public Boolean error{get;set;}
    public Inventory__c inventory{get;set;}
    public Integer stockInQty{get;set;}
    public String productType{get;set;}
    
    public StockIn_Extension (ApexPages.standardController std) {
        this.inventory = (Inventory__c) std.getRecord();
        productType = ApexPages.currentpage().getParameters().get('productType');
        stockInQty = 0;
    }
    
    public void checkData (){
        
        error = false;
        
        if(stockInQty == null || stockInQty == 0){
            error = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Stock In Quantity.'));
        }else{
            error = true;
            createInventoryTracking ();           
        }        
    }
    
    public void createInventoryTracking (){
        
        Inventory_Tracking__c invTrack = new Inventory_Tracking__c();
        invTrack.Action__c = 'New';
        invTrack.IN_OUT__c = 'In';
        invTrack.Product_Name__c = inventory.Product_Name__c;
        invTrack.Quantity__c = stockInQty;
        invTrack.Stock_Warehouse__c = inventory.Stock_Warehouse__c;
        invTrack.Inventory_ID__c = inventory.Id;
        insert invTrack;
        
        if(productType.equals('Equipment') && stockInQty > 0){
             List <Equipment__c> eqList = new List <Equipment__c>();
             for(Integer i=1;i<=stockInQty;i++){
                 Equipment__c eqt = new Equipment__c();
                 eqt.Name = inventory.Product_Name__r.Name;
                 eqt.Product_Name__c = inventory.Product_Name__c;
                 eqt.Inventory_ID__c = inventory.Id;
                 eqList.add(eqt);
             }
            insert eqList;
        }
    }
}