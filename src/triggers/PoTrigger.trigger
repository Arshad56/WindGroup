/*
*    Name             :     PoTrigger 
*    Author           :     Rajesh
*    Date             :     29th June 2017
*    Description      :     Combined Triggers on Purchase Order 
*/
trigger PoTrigger on Purchase_Order__c (before update,after Update,after Insert, before insert) {
    
    if(trigger.isBefore){
        if(trigger.isUpdate){
            PoController.PurchaseOrderThreeQuoteValidation(trigger.new);
            PoController.PurchaseOrderTriggerForVendorUpdate(trigger.new,trigger.oldMap);
            PoController.setValidationByPass(trigger.new,trigger.oldMap);
            PoController.createDOA(trigger.new,trigger.oldMap);
            
        }else if (trigger.isInsert){
            PoController.setPOName(trigger.new);
            PoController.createDOA(trigger.new,trigger.oldMap);
        }
    } else if(trigger.isAfter){
        if(trigger.isUpdate){
            PoController.GeneratePurchaseOrderPDF(trigger.new,trigger.oldMap);
            PoController.rollupAmountOnTheBasisOfStatus(trigger.new,trigger.oldMap);
            PoController.CancelPurchaseOrder(trigger.new);
            PoController.createNewProduct(trigger.new,trigger.oldMap);
        }
    }
}