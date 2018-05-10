trigger PVTrigger on Payment_Voucher__c (after update, after insert,after delete, after undelete) {
    
    if(Trigger.isAfter){
        
        if(checkRecursive.runOnce() && Trigger.isUpdate){
            PaymentVoucherRefundController.createPaymentVoucher(Trigger.New);
            PaymentVoucherRefundController.updateVoidPaymentVoucher(Trigger.New, Trigger.Old);
        }

        if(Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete || Trigger.isUpdate){
            PVTrigger_Helper.rollupDepositAndInvoice(Trigger.New,new Map<Id,Payment_Voucher__c>());
        }       
    }
   
}