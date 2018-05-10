public class EquipmentIssueController{
    public date issueDate{get;set;}
    public Equipment__c equipment{get;set;}
    public string remarks{get;set;}
    public Boolean success{get;set;}
    public EquipmentIssueController(){
        success = false;
        issueDate = system.today();
        equipment = new Equipment__c();
        string eqpId = Apexpages.CurrentPage().getParameters().get('Id');
        
        for(Equipment__c eqp:[Select id,Contact_Name__c,Inventory_ID__c,Product_Name__c from Equipment__c where id=:eqpId limit 1]){
            equipment = eqp;
        }
    }
    
    public void issue(){
        success = false;
        if(equipment.Id!=null){
            if(equipment.Inventory_ID__c!=null){
                Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                invTrack1.Action__c = 'Issue';                    
                invTrack1.Date__c = issueDate;
                invTrack1.IN_OUT__c = 'Out';
                invTrack1.Inventory_ID__c = equipment.Inventory_ID__c;
                invTrack1.Product_Name__c = equipment.Product_Name__c;
                invTrack1.Quantity__c = 1;
                invTrack1.Remarks__c = remarks;
                invTrack1.Equipment__c = equipment.Id;
                insert invTrack1;
                
                equipment.Action__c = 'Issue';
                update equipment;
                
                success = true;
            }else{
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Equipment is not connected with Inventory.'));
            }
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error,'Equipment not found.'));
        }
                    
    }
}