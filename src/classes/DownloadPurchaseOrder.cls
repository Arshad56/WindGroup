/*
*    Name             :     Download Purchase Order
*    Author           :     Mohd Anas
*    Date             :     20th June 2017 
*    Description      :     Future class that saves the pdf to the attachments in the Purchase order
*/

public class DownloadPurchaseOrder{
    
    @future (callout=True)
    public static void generatePDFAsAttachment(Set<Id> PoIds){
        List<Purchase_order__c> pOrderList = [Select id,Name from Purchase_order__c where id in :poIds];        
        if(pOrderList.size()>0){            
            List<Attachment> attachList = [Select id,parentId from Attachment where parentId in :poIds];
            if(attachList.size()>0){
                delete attachList;
            }
            
            List<Attachment> attachments = new List<Attachment>();
            for(Purchase_order__c po : pOrderList){
                Blob body;
                PageReference pdf = new PageReference('/apex/PurchaseOrderPDF?id='+po.id);
                if(Test.isRunningTest()){
                    body = blob.valueOf('Test');
                }else{
                    body = pdf.getContentAsPDF();
                }
                
                Attachment attach = new Attachment();
                attach.Body = body;
                attach.name= po.name+'.PDF';
                attach.ParentId = po.id;
                attachments.add(attach);
            }
            if(attachments.size()>0)
                insert attachments;
        }
    }
    
    
    
}