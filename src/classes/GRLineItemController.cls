global class GRLineItemController {
    WebService static void updateRecord (Id grLineItemId, String action, Id poId,string voidReason){
        
        Purchase_Order__c po = [Select id, PO_Line_Validation_Bypass__c from Purchase_Order__c where id=:poId LIMIT 1];
        Purchase_Order__c newPO = new Purchase_Order__c();
        newPO.Id = po.Id;
        newPO.PO_Line_Validation_Bypass__c = true;
        update newPO;
        
        GR_Line_Item__c grLineItem = [Select id, Name, Void__c from GR_Line_Item__c where id=:grLineItemId LIMIT 1];
        GR_Line_Item__c newGRLineItem = new GR_Line_Item__c();
        newGRLineItem.Id = grLineItemId;
        newGRLineItem.Void__c = true;
        newGRLineItem.Void_Reason__c = voidReason;
        newGRLineItem.Void_Datetime__c = System.now();
        update newGRLineItem;
        
        List <Inventory_Tracking__c> invTracking = [Select id, Inventory_ID__c, Product_Name__c, Product_Type__c, Quantity__c, GR_Line_Item__c from Inventory_Tracking__c where GR_Line_Item__c=:grLineItemId];
        List <Inventory_Tracking__c> invTrackingList = new List<Inventory_Tracking__c>(); 
        
        List <Equipment__c> equipmentList = [Select id, Status__c from Equipment__c where GR_Line_Item__c=:grLineItemId];
        List <Equipment__c> newequipmentList = new List<Equipment__c>(); 
        
        if(!invTracking.isEmpty()){
            for(Inventory_Tracking__c invTrac: invTracking){  
                Inventory_Tracking__c newInvTrac = new Inventory_Tracking__c();
                newInvTrac.Action__c = 'Write Off';
                newInvTrac.IN_OUT__c = 'Out';
                newInvTrac.Product_Name__c = invTrac.Product_Name__c;
                newInvTrac.GR_Line_Item__c = invTrac.GR_Line_Item__c;
                newInvTrac.Quantity__c = invTrac.Quantity__c;
                newInvTrac.Remarks__c = 'VOID GR';
                newInvTrac.Inventory_ID__c = invTrac.Inventory_ID__c;
                invTrackingList.add(newInvTrac);
            }
            insert invTrackingList;
        }
        
        if(!equipmentList.isEmpty()){
            for(Equipment__c eq: equipmentList){  
                eq.Status__c = 'Inactive';
                eq.Action__c = 'Write Off';
                newequipmentList.add(eq);
            }
            update newequipmentList;
        }

        newPO.PO_Line_Validation_Bypass__c = false;
        update newPO;
        
    }
}