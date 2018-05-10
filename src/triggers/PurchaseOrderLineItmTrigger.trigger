/*  
    Name         : PurchaseOrderLineItmTrigger 
    Author       : Rajesh 
    Created Date : 2nd Jun 2017   
    Description  : This trigger is used to rollup amount based on Status picklist field value in Purchase_Order__c object if picklist value is ‘IN-Approval’
                      then update total rollup amount in 'PO Pending',‘Issued’then update total rollup amount in 'PO Issued'.
                   //Relationship between PurchaseOrder and PurchaseOrderLineItem is Master details
*/
trigger PurchaseOrderLineItmTrigger on PO_Line_Item__c(before insert,before update,after update, before delete){
    If(Trigger.isBefore){
        
        if(trigger.isUpdate){
            PoLineItemController.poLineItemValidation(Trigger.New);
            PoLineItemController.updateCOAFYBalance(Trigger.New);
        }else if(trigger.isInsert){
            PoLineItemController.poLineItemValidation(Trigger.New);
            PoLineItemController.updateCOAFYBalance(Trigger.New);
        }else if(trigger.isDelete){
            PoLineItemController.validationPOLineItemDelete(Trigger.Old);
        }
        
    }else If(Trigger.isAfter){
        
        if(trigger.isUpdate){
            PoLineItemController.calPORollUpAmt(Trigger.New, trigger.oldMap);
        }
       
        
     }
}