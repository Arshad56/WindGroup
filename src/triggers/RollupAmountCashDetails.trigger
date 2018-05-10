trigger RollupAmountCashDetails on Cash_Detail__c (after insert, after delete, after undelete, after update) {
    Set<id> voidedInvoiceIds = new Set<id>();
    Set<id> voidedDepositIds = new Set<id>();
    Set<id> pvIds = new Set<id>();
  System.debug('Trigger.isUpdate-->'+Trigger.isUpdate);
  
  if(Trigger.isAfter){
      if(Trigger.isUndelete || Trigger.isUpdate || Trigger.isInsert){
          for(Cash_Detail__c con1 : Trigger.new){
        System.debug('con1-->'+con1);
              if(Trigger.isUpdate && con1.Invoice__c == null ){
                voidedInvoiceIds.add(Trigger.oldMap.get(con1.id).Invoice__c);
              }else if(con1.Invoice__c != null){
                voidedInvoiceIds.add(con1.Invoice__c);
              }
              
              if(Trigger.isUpdate && con1.Deposit__c == null ){
                voidedDepositIds.add(Trigger.oldMap.get(con1.id).Deposit__c);
              }else if(con1.Deposit__c != null){
                voidedDepositIds.add(con1.Deposit__c);
              }
              
              if(Trigger.isUpdate && con1.Payment_Voucher__c == null ){
                pvIds.add(Trigger.oldMap.get(con1.id).Payment_Voucher__c);
              }else if(con1.Payment_Voucher__c != null){
                pvIds.add(con1.Payment_Voucher__c);
              }
          }
      }
      System.debug('111-->'+voidedInvoiceIds);
      System.debug('222-->'+voidedDepositIds);
      if(Trigger.isDelete){
          for(Cash_Detail__c con1 : Trigger.old){
            if(con1.Invoice__c != null){
              voidedInvoiceIds.add(con1.Invoice__c);
            }
            if(con1.Deposit__c != null){
              voidedDepositIds.add(con1.Deposit__c);
            }
            
            if(con1.Payment_Voucher__c!=null){
                pvIds.add(con1.Payment_Voucher__c);
            }
          } 
      }
      if(voidedInvoiceIds.size() > 0 || voidedDepositIds.size() > 0 || pvIds.size()>0 ){
        RollupAmountCashDetails_Helper.rollupAmount(voidedInvoiceIds, voidedDepositIds,pvIds);
        System.debug('111-->'+voidedInvoiceIds);
        System.debug('222-->'+voidedDepositIds);
      }
  }
}