/*
*    Name             :     FullInvoiceReceiptController
*    Author           :     Mohd Anas
*    Date             :     4th July 2017
*    Description      :     Controller to full invoice receipt
*/
public class FullInvoiceReceiptController{
    
    public Purchase_Order__c purchaseOrder{ get; set; }
    public Boolean errorLock{ get; set; }
    public Invoice_Receipt__c fullInv { get; set;}
    
    public FullInvoiceReceiptController(){
        errorLock = FALSE;
        purchaseOrder= new Purchase_Order__c();
        fullInv = new Invoice_Receipt__c();
        Id poId = ApexPages.CurrentPage().getParameters().get('poId');
        
        if(poId != Null){
            purchaseOrder = [SELECT Currency_Code__c,Status__c,PO_Amount__c,Tax_Amount__c,Vendor_Name__c,Balance_Quantity__c,PO_Line_Validation_Bypass__c,(Select id from Invoice_Receipts__r where purchase_order__c = :poId and Status__c != 'Void')
                            FROM Purchase_Order__c 
                            WHERE id = :poId];
            fullInv.purchase_order__c = purchaseOrder.id;
            fullInv.Currency_Code__c = purchaseOrder.Currency_Code__c;
            fullInv.Amount__c = purchaseOrder.PO_Amount__c;
            fullInv.Tax__c = purchaseOrder.Tax_Amount__c;
            fullInv.Vendor_Name__c = purchaseOrder.Vendor_Name__c;
            fullInv.Invoice_Date__c=System.today();
            
            if(purchaseOrder.Invoice_Receipts__r.size()>0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info,'Full Invoice Receipt can not be generated, since few Invoice Receipt(s) have already been generated.'));
                errorLock = TRUE;
            }
            else if(purchaseOrder.Balance_Quantity__c != 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Balance quantity on Purchase Order should be 0 to generate Full Invoice'));
                errorLock = TRUE;
            }
            else if(''.equals(fullInv.Invoice_Number__c) || fullInv.Invoice_Number__c == null){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter Invoice Number.'));
                //errorLock = TRUE;
            }
            else if(fullInv.Invoice_Due_Date__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter Invoice Due Date.'));
                errorLock = TRUE;
            }
        }
        else
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info,'Purchase Order Not Selected'));
            
    }
    
    
    public pageReference saveFullInvoice(){
    
        if(!errorLock){
            SavePoint sp = Database.setSavePoint();
            try{
                
                List<Po_payment_arrangement__c>  poPaymentArrUpdate = new  List<Po_payment_arrangement__c>();
                poPaymentArrUpdate = [SELECT Invoice_Created__c FROM Po_payment_arrangement__c WHERE Purchase_Order__c = :fullInv.Purchase_Order__c];
                if(poPaymentArrUpdate.size()>0){
                    Boolean changePA = False;
                    for(Po_payment_arrangement__c pa: poPaymentArrUpdate){
                            pa.Invoice_Created__c =TRUE;
                            changePA = true;
                    }
                    if(changePA){
                        Boolean updatedPO = False;
                        if(!purchaseOrder.PO_Line_Validation_Bypass__c){
                            purchaseOrder.PO_Line_Validation_Bypass__c = true;
                            update purchaseOrder;
                            updatedPO = True;
                        }
                        update poPaymentArrUpdate;
                        if(updatedPO){
                            purchaseOrder.PO_Line_Validation_Bypass__c = false;
                            update purchaseOrder;
                        }
                            
                    }
                }
                insert fullInv;
            }
            catch(Exception e){
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info,e.getMessage()));
                return null;
            }
            return (new pageReference('/'+fullInv.id));
        }
        else
            return(null);
    }
}