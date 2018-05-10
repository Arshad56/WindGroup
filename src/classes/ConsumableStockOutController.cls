public class ConsumableStockOutController{
    public Integer quantity{get;set;}
    public date stockoutDate{get;set;}
    public string remarks{get;set;}
    public Boolean success{get;set;}
    string invId;
    public Inventory__c inv{get;set;}    
    public ConsumableStockOutController(){
        success = false;
        stockoutDate = system.today();
        invId = Apexpages.CurrentPage().getParameters().get('Id');
        
        inv = new Inventory__c();
        for(Inventory__c iv:[Select id,Name,Available_Qty__c,Product_Name__c from Inventory__c where id=:invId limit 1]){
            inv = iv;
        } 
    }
    
    public void stockOut(){
        success = false;
        if(inv.Id!=null){
             if(quantity > 0 && quantity<=inv.Available_Qty__c){
                 Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                invTrack1.Action__c = 'Out';                    
                invTrack1.Date__c = stockoutDate;
                invTrack1.IN_OUT__c = 'Out';
                invTrack1.Product_Name__c = inv.Product_Name__c;
                invTrack1.Quantity__c = quantity;
                invTrack1.Remarks__c = remarks;
                invTrack1.Inventory_ID__c = inv.Id;
                insert invTrack1;
                
                success = true;
             }else{
                 Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Quantity should be greater than 0 and not more than available quantity in Inventory.'));
             }
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Inventory not found.'));
        }
    }
}