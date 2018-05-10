public class DownloadInvoice{
    
    @future(callout=true)
    public static void getAttachmentByInvoiceId(Set<Id> invoiceIds){
        
        list<Attachment> attInsert = new List<Attachment>();
        list<Attachment> attdelete = new List<Attachment>();
        list<Invoice__c> invList = new list<Invoice__c>();
        
        if(!invoiceIds.isEmpty()){
            attdelete=[SELECT Id FROM Attachment WHERE ParentId IN: invoiceIds];
            if(!attdelete.isEmpty()){
                delete attdelete;
            }
        
            invList = [Select id, name from Invoice__c where Id IN: invoiceIds];
            if(!invList.isEmpty()){
                for(Invoice__c inv : invList){
                    Blob body;
                    PageReference pdf = new PageReference('/apex/InvoicePDF?id='+inv.id);
                    
                    if(Test.isRunningTest()){
                        body = blob.valueOf('Test');
                    }else{
                        body = pdf.getContentAsPDF();
                    }
                    
                    Attachment attach = new Attachment();
                    attach.Body = body;
                    attach.name= inv.name+'.PDF';
                    attach.IsPrivate = false;
                    attach.ParentId = inv.id;
                    attach.contentType = 'application/pdf';
                    attInsert.add(attach);
                }   
                if(!attInsert.isEmpty()){
                    insert attInsert;
                }
            }
        } 
    }
    
    @future(callout=true)
    public static void generatePDFAsAttachment(Set<Id> rentRollIds){
        List<Rent_Roll__c> rentRollList = [Select id,Name from Rent_Roll__c where id in:rentRollIds];        
        if(rentRollList.size()>0){            
            List<Attachment> attachList = [Select id,parentId from Attachment where parentId in:rentRollIds];
            if(attachList.size()>0){
                delete attachList;
            }
            
            List<Attachment> attachments = new List<Attachment>();
            for(Rent_Roll__c rr:rentRollList){
                Blob body;
                PageReference pdf = new PageReference('/apex/RentRollPDF?id='+rr.id);
                if(Test.isRunningTest()){
                    body = blob.valueOf('Test');
                }else{
                    body = pdf.getContentAsPDF();
                }
                
                Attachment attach = new Attachment();
                attach.Body = body;
                attach.name= rr.name+'.PDF';
                attach.ParentId = rr.id;
                attachments.add(attach);
            }
            insert attachments;
        }
    }
    
    @future(callout=true)
    public static void generateReceiptAsAttachment(Set<Id> cashRepIds){
        List<Cash_Receipt__c> cashReceipts = [Select id,Name from Cash_Receipt__c where id in:cashRepIds];
        if(cashReceipts.size()>0){
            List<Attachment> attachList = [Select id,parentId from Attachment where parentId in:cashRepIds];
            if(attachList.size()>0){
                delete attachList;
            }
            
            List<Attachment> attachments = new List<Attachment>();
            for(Cash_Receipt__c cr:cashReceipts){
                Blob body;
                PageReference pdf = new PageReference('/apex/CashReceiptPDF?id='+cr.id);
                if(Test.isRunningTest()){
                    body = blob.valueOf('Test');
                }else{
                    body = pdf.getContentAsPDF();
                }
                
                Attachment attach = new Attachment();
                attach.Body = body;
                attach.name= cr.name+'.PDF';
                attach.ParentId = cr.id;
                attachments.add(attach);
            }
            insert attachments;
        }
    }
}