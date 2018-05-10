public class ConsumableTransferController{
    public date dt{get;set;}
    public Integer quantity{get;set;}
    public List<Inventory__c> inventoryList{get;set;}
    public Inventory__c inv{get;set;}
    string invId;
    public Boolean success{get;set;}
    Map<Id,Inventory__c> inventoryMap{get;set;}
    public ConsumableTransferController(){
        success = false;
        inventoryMap = new Map<Id,Inventory__c>();
        dt = system.today();
        invId = Apexpages.CurrentPage().getParameters().get('Id');
        inv = new Inventory__c();
        inventoryList = new List<Inventory__c>();
        for(Inventory__c iv:[Select id,Name,Available_Qty__c,Product_Name__c from Inventory__c where id=:invId limit 1]){
            inv = iv;
            inventoryList = [Select id,Name,Stock_Warehouse__c,Available_Qty__c,Stock_Warehouse__r.Name from Inventory__c where Product_Name__c=:inv.Product_Name__c and  id !=:inv.Id];
            inventoryMap = new Map<Id,Inventory__c>(inventoryList);
        }        
    }
    
    public void transfer(){
        success = false;
        if(inv.Id!=null){
            if(quantity > 0 && quantity<=inv.Available_Qty__c){
                string selInv = Apexpages.CurrentPage().getParameters().get('selInv');
                if(selInv!=null && selInv.trim().length()>0){
                    List<Inventory_Tracking__c> invTrackList = new List<Inventory_Tracking__c>();
                    Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                    invTrack1.Action__c = 'Transfer';                    
                    invTrack1.Date__c = dt;
                    invTrack1.IN_OUT__c = 'Out';
                    invTrack1.Inventory_ID__c = inv.Id;
                    invTrack1.Product_Name__c = inv.Product_Name__c;
                    invTrack1.Quantity__c = quantity;
                    invTrack1.Remarks__c = 'Transfer to '+inventoryMap.get(selInv).Name;
                    invTrackList.add(invTrack1);
                    
                    Inventory_Tracking__c invTrack2 = new Inventory_Tracking__c();
                    invTrack2.Action__c = 'Transfer';                    
                    invTrack2.Date__c = dt;
                    invTrack2.IN_OUT__c = 'In';
                    invTrack2.Inventory_ID__c = selInv;
                    invTrack2.Product_Name__c = inv.Product_Name__c;
                    invTrack2.Quantity__c = quantity;
                    invTrack2.Remarks__c = 'Transfer from '+inv.Name;
                    invTrackList.add(invTrack2);
                    
                    insert invTrackList;
                    
                    success = true;
                }else{
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Please select Inventory to transfer.'));
                }
            }else{
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Quantity should be greater than 0 and not more than available quantity in Inventory.'));
            }
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Inventory not found.'));
        }
    }
}