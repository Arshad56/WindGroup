public class WriteOffController{
    
    public String invId{get;set;} 
    public Integer quantity{get;set;}
    public string remarks{get;set;}
    public Boolean success{get;set;}
    public List <Equipment__c> equipmentList{get;set;}
    public List <Inventory__c> inventoryList{get;set;}
    
    public WriteOffController(){
       success=false;
       equipmentList = new List <Equipment__c>();
       inventoryList = new List <Inventory__c>();
       invId = Apexpages.CurrentPage().getParameters().get('InvId');
    }
    
    public WriteOffController(Set<Id> equipmentIds, Set<Id> invIds){
        
        equipmentList = new List <Equipment__c>();
        inventoryList = new List <Inventory__c>();
        
        if(equipmentIds != null)
            equipmentList = [Select id,Location__c,Inventory_ID__c,Product_Name__c from Equipment__c where id IN:equipmentIds];
        else if(invIds != null)
            inventoryList = [Select id,Product_Name__c,Write_Off_Qty__c,Write_Off_Remark__c from Inventory__c where id IN:invIds];
    }
    
    public void checkData(){
        if(quantity == null || quantity == 0){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Please enter quantity.'));
        } else if (remarks == null || ''.equals(remarks)){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Please enter remarks.'));
        } else {
            try{                
                    Inventory__c niv=[Select id,Name,Available_Qty__c,Product_Name__c,Write_Off_Qty__c,Write_Off_Remark__c from Inventory__c where id=:invId limit 1]; 
                    niv.Write_Off_Qty__c = quantity;
                    niv.Write_Off_Remark__c = remarks;
  
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(niv.Id);
                    Approval.ProcessResult result = Approval.process(psr);
                    update niv;
                    success =true;
                
            }catch(Exception e){
                 Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Inventory Available Quantity is 0.'));
            }            
        }   
    }
    
    public void writeOff(){ 
        
        if(!inventoryList.isEmpty() || !equipmentList.isEmpty()){          
            if(!inventoryList.isEmpty()){
                List <Inventory_Tracking__c> invTrackList = new List <Inventory_Tracking__c>();
                List <Inventory__c> newinvList = new List <Inventory__c>();

                for(Inventory__c inv: inventoryList){                    
                    
                    Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                    invTrack1.Action__c = 'Write Off';                    
                    invTrack1.Date__c = system.today();
                    invTrack1.IN_OUT__c = 'Out';
                    invTrack1.Product_Name__c = inv.Product_Name__c;
                    invTrack1.Quantity__c = inv.Write_Off_Qty__c;
                    invTrack1.Remarks__c = inv.Write_Off_Remark__c;
                    invTrack1.Inventory_ID__c = inv.Id;
                    invTrackList.add(invTrack1);
                    
                    inv.Status__c = 'Active';
                    inv.Write_Off_Qty__c = null;
                    inv.Write_Off_Remark__c = null;
                    newinvList.add(inv);

                }               
                insert invTrackList;
                update newinvList;
                
            }else if (!equipmentList.isEmpty()){
                List <Inventory_Tracking__c> invTrackList = new List <Inventory_Tracking__c>();               
                for(Equipment__c equipment: equipmentList)
                {
                    Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                    invTrack1.Action__c = 'Write Off';                    
                    invTrack1.Date__c = system.today();
                    invTrack1.IN_OUT__c = 'Out';
                    invTrack1.Product_Name__c = equipment.Product_Name__c;
                    invTrack1.Quantity__c = 1;
                    invTrack1.Remarks__c = remarks;
                    invTrack1.Inventory_ID__c = equipment.Inventory_ID__c;
                    invTrack1.Equipment__c = equipment.Id;
                    invTrackList.add(invTrack1);
                }                     
                insert invTrackList;
            }             
        }
    }
}