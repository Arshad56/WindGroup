global class InvoiceReceiptController {
    
     WebService static void updateRecord (Id irId, String action, Id poId){
        Purchase_Order__c po = [Select id, PO_Line_Validation_Bypass__c, Total_PO_Amount__c, recordtype.Name from Purchase_Order__c where id=:poId LIMIT 1];
        Purchase_Order__c newPO = new Purchase_Order__c();
        newPO.Id = po.Id;
        newPO.PO_Line_Validation_Bypass__c = true;
        update newPO;
        
        Invoice_Receipt__c ivRecp = [Select id, Status__c,Void_Datetime__c from Invoice_Receipt__c where id=:irId LIMIT 1];
        Invoice_Receipt__c newivRecp = new Invoice_Receipt__c();
        newivRecp.Id = ivRecp.Id;
        newivRecp.status__c = action;
        newivRecp.Void_Datetime__c = System.now();
        update newivRecp;

        if(po.recordtype.Name == 'One Time' && action.equals('Paid')){
             decimal invRTotalAmount = 0.0;
             List <Invoice_Receipt__c> ivReList = [Select Id, Total_Amount__c from Invoice_Receipt__c where Purchase_Order__r.Id =: po.Id and Status__c = 'Paid'];
             
             for(Invoice_Receipt__c invRe : ivReList)
                invRTotalAmount = invRTotalAmount + invRe.Total_Amount__c;
            
             if(invRTotalAmount == po.Total_PO_Amount__c)
                 newPO.Status__c = 'Closed';
             newPO.PO_Line_Validation_Bypass__c = false;
             update newPO;
             
         }
    }
    
    public static void InvoiceReceiptValidation(List<Invoice_Receipt__c > invReceipts){
       Map<Id,Goods_Receipt__c> grMap = new Map<Id,Goods_Receipt__c>();
       Map<String,Decimal> poInvoiceReciptMap = new Map<String,Decimal>();    
       Set<Id> purOrderIds = new Set<Id>();
       for(Invoice_Receipt__c inv : invReceipts){
           purOrderIds.add(inv.Purchase_Order__c);
       }
       Set<Id> oneTimeOrderIds = new Set<Id>();
       Map<Id,Purchase_Order__c> recuringOrderMap = new Map<Id,Purchase_Order__c>();
       for(Purchase_Order__c po:[Select id,recordtype.Name,Total_Receipt_Amount__c,Total_PO_Amount__c from Purchase_Order__c where id in:purOrderIds]){
           if(po.recordType.Name=='Recurring Svc'){
               recuringOrderMap.put(po.Id,po);
           }else{
               oneTimeOrderIds.add(po.Id);
           }
       }       
       
       for(Invoice_Receipt__c inv : invReceipts){
           if(oneTimeOrderIds.contains(inv.Purchase_Order__c)){
               if(inv.Goods_Receipt__c!=null){
                   grMap.put(inv.Goods_Receipt__c,null);
               }
               
               if(inv.Purchase_Order__c!= null)
                   poInvoiceReciptMap.put(inv.Purchase_Order__c,inv.Amount__c != null ? inv.Amount__c : 1); 
               
           }else if(recuringOrderMap.containsKey(inv.Purchase_Order__c)){
               Purchase_Order__c po = recuringOrderMap.get(inv.Purchase_Order__c);
               decimal totalAmount = (po.Total_Receipt_Amount__c!=null?po.Total_Receipt_Amount__c:0)+(inv.Amount__c!=null?inv.Amount__c:0)+(inv.Tax__c!=null?inv.Tax__c:0);
               if(totalAmount>po.Total_PO_Amount__c){
                   inv.addError('Total Invoice Receipt(s) amount should not exceed Total PO Amount.');
               }
           }
       }
       
       if(grMap.size() > 0){
           grMap = new Map<Id,Goods_Receipt__c>([SELECT id,Purchase_Order__c,Invoice_Created__c,GR_Amount__c,Tax_Amount__c from Goods_Receipt__c where id in:grMap.keyset()]);
           
           if(grMap.size()>0){                   
               for(AggregateResult ar: [SELECT Purchase_Order__c, SUM(Amount__c) invRoll
                                                      FROM Invoice_Receipt__c WHERE Purchase_Order__c IN:poInvoiceReciptMap.keySet()
                                                      GROUP BY Purchase_Order__c]){
                   String poId = String.valueOf(ar.get('Purchase_Order__c'));
                   Decimal invPoRollup = Double.valueOf(ar.get('invRoll'));
                   
                   if(poInvoiceReciptMap.containskey(poId))
                       poInvoiceReciptMap.put(poId,poInvoiceReciptMap.get(poId)+invPoRollup);
                   else    
                       poInvoiceReciptMap.put(poId,invPoRollup);
               }
           }
           
           List<Goods_Receipt__c> goodReceiptList = new List<Goods_Receipt__c>();
           
           for(Invoice_Receipt__c inv : invReceipts){
               Boolean isErrr = False;
               Decimal grAmount = grMap.get(inv.Goods_Receipt__c).GR_Amount__c;
               
               if(inv.Amount__c >  grAmount){
                   inv.addError('Error : Invoice Amount exceeds Goods Receipt Amount.');
                   isErrr = True; 
               }else if(inv.Amount__c <  grAmount){
                   inv.addError('Error : Invoice Amount preceeds Goods Receipt Amount.');
                   isErrr = True;
               }   
               
               if(!isErrr)
                   goodReceiptList.add(new goods_Receipt__c(id=inv.Goods_Receipt__c,invoice_created__c = true));            
           }
            
           if(goodReceiptList.size()>0){
                List<Purchase_order__c> poToUpdate = new List<Purchase_order__C>();
                boolean changedToValidate = false;
                for(Purchase_Order__c po : [SELECT PO_Line_Validation_Bypass__c 
                                                FROM Purchase_Order__c 
                                                WHERE id in :poInvoiceReciptMap.keySet()]){
                    if(!po.PO_Line_Validation_Bypass__c){
                        changedToValidate = true;
                        po.PO_Line_Validation_Bypass__c = True;
                        poToUpdate.add(po);
                    }
                 }
                 update poToUpdate;
                 update goodReceiptList;
                 if(changedToValidate){
                     for(Purchase_Order__c po : poToUpdate)
                         po.PO_Line_Validation_Bypass__c = false;
                      update poToUpdate; 
                 }
           }
       }
    }
}