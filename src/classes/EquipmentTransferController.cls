public class EquipmentTransferController{
    public date dt{get;set;}
    public Integer quantity{get;set;}
    public List<Inventory__c> inventoryList{get;set;}
    public string invName{get;set;}
    public string invId{get;set;}
    public Boolean success{get;set;}
    List<Equipment__c> equipmentList;
    Map<Id,Inventory__c> inventoryMap;
    public EquipmentTransferController(){
        inventoryMap = new Map<Id,Inventory__c>();
        string equipIds = Apexpages.CurrentPage().getParameters().get('Ids');
        dt = system.today();
        inventoryList = new List<Inventory__c>();
        equipmentList = new List<Equipment__c>();
        if(equipIds!=null && equipIds.trim().length()>0){
            if(equipIds.endsWith(',')){
                equipIds = equipIds.substring(0,equipIds.length()-1);
            }
            
            List<string> eqIdList = equipIds.split(',');
            equipmentList = [Select id,Inventory_ID__c,Inventory_ID__r.name,Product_Name__c from Equipment__c where id in :eqIdList];
            if(equipmentList.size()>0){
                Quantity = equipmentList.size();
                invId = equipmentList[0].Inventory_ID__c;
                invName = equipmentList[0].Inventory_ID__r.name;
                inventoryList = [Select id,Name,Stock_Warehouse__c,Available_Qty__c,Stock_Warehouse__r.Name from Inventory__c where Product_Name__c=:equipmentList[0].Product_Name__c and  id !=:invId];
                inventoryMap = new Map<Id,Inventory__c>(inventoryList);
            }
        }
    }
    
    public void Transfer(){
        success = false;
        if(invId!=null){
            if(quantity > 0){
                string selInv = Apexpages.CurrentPage().getParameters().get('selInv');
                if(selInv!=null && selInv.trim().length()>0){
                    List<Inventory_Tracking__c> invTrackList = new List<Inventory_Tracking__c>();
                    for(Equipment__c eqp:equipmentList){
                        Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                        invTrack1.Action__c = 'Transfer';                    
                        invTrack1.Date__c = dt;
                        invTrack1.IN_OUT__c = 'Out';
                        invTrack1.Inventory_ID__c = invId;
                        invTrack1.Product_Name__c = eqp.Product_Name__c;
                        invTrack1.Quantity__c = 1;
                        invTrack1.Remarks__c = 'Transfer to '+inventoryMap.get(selInv).Name;
                        invTrackList.add(invTrack1);
                        
                        Inventory_Tracking__c invTrack2 = new Inventory_Tracking__c();
                        invTrack2.Action__c = 'Transfer';                    
                        invTrack2.Date__c = dt;
                        invTrack2.IN_OUT__c = 'In';
                        invTrack2.Inventory_ID__c = selInv;
                        invTrack2.Product_Name__c = eqp.Product_Name__c;
                        invTrack2.Quantity__c = 1;
                        invTrack2.Remarks__c = 'Transfer from '+invName;
                        invTrack2.Equipment__c = eqp.Id;
                        invTrackList.add(invTrack2);
                        
                        eqp.Action__c = 'Transfer';
                    }
                    
                    
                    insert invTrackList;
                    
                    update equipmentList;
                    
                    success = true;
                }else{
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Please select Inventory to transfer.'));
                }
            }else{
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Quantity should be greater than 0.'));
            }
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Inventory not found.'));
        }
    }
    

}