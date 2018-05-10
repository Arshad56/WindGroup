/*
 *  Name        :    JournalVoucherTrigger
 *  Author      :    
 *  Date        :    22 March 2017
 *  Description :    On updating the value of Posting Status in Journal Voucher----
 *                   1. Updating the value of JV Status in Invoice.  
 *                   2. Updating the value of Posting Status in Journal Entry.
*/
trigger JournalVoucherTrigger on Journal_Voucher__c (after update) {
    Set<id> newJournalVoucherIds=new set<id>();
    
    //-------List for Invoice Update-----------
    List<Invoice__c> newInvoiceEntry=new List<Invoice__c>(); 
    
    //---------------------------Invoice JV Status Update ---------------------------------------- 
    for(Journal_voucher__c JVoucher:Trigger.New){
           if(JVoucher.Posting_Status__c != Trigger.oldMap.get(JVoucher.Id).Posting_Status__c){           
               if(JVoucher.Invoice__c != null){
				   //-----------------Invoice Object-----------------------
				   Invoice__c invObj = new Invoice__c();
				   invObj.Id =  JVoucher.Invoice__c;
				   
				   //-------------------Start Entring Updated Invoice object in List---------------------- 
				   if(JVoucher.Posting_Status__c =='Posted')
						invObj.JV_Status__c='Posted';
					else if(JVoucher.Posting_Status__c =='Void' || JVoucher.Posting_Status__c =='Canceled')
						invObj.Jv_Status__c='Pending';
						
				   
					newInvoiceEntry.add(invObj);
					//-------------------End Entring Updated Invoice object in List---------------------- 
				}
				
				 //-----------------Creating SET of Jounal Voucher Ids------------------------
                newJournalVoucherIds.add(JVoucher.id);
            }
    }
    if(newInvoiceEntry.size() >0)    
        update newInvoiceEntry;
    
    //---------------------------Journal Entry Status Update according to parent Journal Voucher -------------------- 
    
    if(newJournalVoucherIds.size()>0){
        List<Journal_Entry__c> updJournalEntry = [Select id,Posting_Status__c,Journal_Voucher__c 
                                                 from Journal_Entry__c 
                                                 where Journal_Voucher__r.id in :newJournalVoucherIds];
      
        if(updJournalEntry.size()>0){
            for(Journal_Entry__c jouEntry : updJournalEntry){
                String jourVouStatus = Trigger.newMap.get(jouEntry.Journal_Voucher__c).Posting_Status__c;
                if(jourVouStatus != Trigger.oldMap.get(jouEntry.Journal_Voucher__c).Posting_Status__c){
                    jouEntry.Posting_Status__c =  jourVouStatus;
                }
            }
            update updJournalEntry;
        }
      
    }    
     
}