/*
Author - Arshad Shaikh (TMC)
Description - To Update the Status on invoice 
			  To Generate Payment Voucher.

Test Class - SetInvoiceIndex_Test
*/
trigger UpdateInvoiceStatus on Invoice__c (before update,after update) {
	
    List<Payment_Voucher__c> pvList = new List<Payment_Voucher__c>();
    Map<string,Exchange_Rate__c> exgRateMap = new Map<string,Exchange_Rate__c>();
    for(Exchange_Rate__c exgRate:[Select id,Conversion_Rate__c,Start_Date_Time__c,Currency_Code__c from Exchange_Rate__c where Applicable_Function__c = 'Finance' and Start_Date_Time__c<=:system.now() order By Start_Date_Time__c desc]){
        if(!exgRateMap.containsKey(exgRate.Currency_Code__c)){
            exgRateMap.put(exgRate.Currency_Code__c,exgRate);
        }
    }
    Set<Id> rrIds = new Set<Id>();
    Set<Id> invIdsm = new Set<Id>();
    for(Invoice__c inv:Trigger.New){
    	System.debug('Amount_Paid__c1111-- '+inv.Amount_Paid__c + ' '+Trigger.OldMap.get(inv.Id).Amount_Paid__c);
    	System.debug('Exchange Rate -- '+inv.Exchange_Rate__c + ' '+Trigger.OldMap.get(inv.Id).Exchange_Rate__c);
    	System.debug('Total_Amount__c-- '+inv.Total_Amount__c + ' '+Trigger.OldMap.get(inv.Id).Total_Amount__c);
    	if(Trigger.isAfter && Trigger.isUpdate)
	    	//if(inv.Amount_Paid__c != Trigger.OldMap.get(inv.Id).Amount_Paid__c){
	    		invIdsm.add(inv.Id);
	    	//}
    	rrIds.add(inv.Rent_Roll__c);
    }
    Map<Id, Rent_Roll__c> rrMap = new Map<Id, Rent_Roll__c>([select Id,Billing_Type__c from Rent_Roll__c where id=:rrIds and Billing_Type__c ='Credit Note']);
    
    for(Invoice__c inv:Trigger.New){
    	if(Trigger.isBefore){
	    	/*inv.Total_Refunded_Amount__c = (inv.Total_Refunded_Amount__c!= null)?inv.Total_Refunded_Amount__c:0;
	    	inv.Requested_Amount__c = (inv.Requested_Amount__c!= null)?inv.Requested_Amount__c:0;
	    	if(rrMap.ContainsKey(inv.Rent_Roll__c)){
	        	inv.Amount_Paid__c =  inv.Total_Refunded_Amount__c - ((inv.Refund_Status__c =='Submitted')?inv.Requested_Amount__c:0);
	        	if(inv.Currency_Code__c != label.Default_Currency && inv.Foreign_Exchange_Rate__c != null){
	        		inv.Amount_Paid__c = inv.Amount_Paid__c/inv.Foreign_Exchange_Rate__c;
	        	}
	    	}*/
	        	
	        if( inv.Status__c!='Cancelled' && (inv.Amount_Paid__c != Trigger.OldMap.get(inv.Id).Amount_Paid__c || inv.Total_Amount__c!=Trigger.OldMap.get(inv.Id).Total_Amount__c)){
	            if(inv.Outstanding_Amount__c==0){
	                inv.Status__c = 'Paid';
	            }else if(((inv.Total_Amount__c > 0 && inv.Outstanding_Amount__c > 0) || (inv.Total_Amount__c < 0 && inv.Outstanding_Amount__c < 0)) && inv.Total_Amount__c.setScale(2)==inv.Outstanding_Amount__c && inv.Amount_Paid__c==0){
	                inv.Status__c = 'Outstanding';
	            }else if((inv.Total_Amount__c > 0 && inv.Outstanding_Amount__c > 0 && inv.Amount_Paid__c > 0) || (inv.Total_Amount__c < 0 && inv.Outstanding_Amount__c < 0 && inv.Amount_Paid__c < 0)){
	                inv.Status__c = 'Partially Paid';
	            }
	            inv.Exchange_Rate__c = (inv.Exchange_Rate__c!=null)?inv.Exchange_Rate__c:1;
	        }
	        if(inv.Requested_Amount__c!=null && inv.Refund_Mode__c!=null && inv.Refund_Status__c=='Approved' && inv.Refund_Status__c!=Trigger.oldMap.get(inv.Id).Refund_Status__c){
	        	inv.Total_Requested_Amount__c = (inv.Total_Requested_Amount__c!= null)?inv.Total_Requested_Amount__c:0;
	            inv.Total_Requested_Amount__c += inv.Requested_Amount__c;
	        }
	    }
	    /*--------*/
	    /*--------*/
	    /*--------*/
        if(Trigger.isAfter){
        	System.debug('after-->'+inv);
        	if(inv.Requested_Amount__c!=null && inv.Refund_Mode__c!=null && inv.Refund_Status__c=='Approved' && inv.Refund_Status__c!=Trigger.oldMap.get(inv.Id).Refund_Status__c){
	            Payment_Voucher__c pv = new Payment_Voucher__c();
	            pv.Invoice__c = inv.Id;
	            pv.Refund_Mode__c = inv.Refund_Mode__c;
	            pv.Payment_Mode__c = inv.Refund_Mode__c;
	            pv.Status__c = 'New';
	            pv.Currency_Code__c = inv.Refund_Currency_Code__c;
	            pv.Amount__c = -inv.Requested_Amount__c;
	            
	            if(exgRateMap.containsKey(inv.Currency_Code__c)){
	                pv.Exchange_Rate__c = exgRateMap.get(inv.Currency_Code__c).Conversion_Rate__c;
	            }
	            if(inv.Currency_Code__c != inv.Refund_Currency_Code__c)
	                pv.Default_Amount_Foreign__c = -inv.Requested_Amount__c / inv.Exchange_Rate__c;            
	            if(exgRateMap.containsKey(label.Base_Foreign_Currency)){
	                pv.Exchange_Rate__c = exgRateMap.get(label.Base_Foreign_Currency).Conversion_Rate__c;
	            }

	            pv.Transaction_Type__c = 'Invoice';
	            pvList.add(pv);
	            System.debug('pv1-->'+pv);
	            System.debug('pv-->'+pv);      
	        }     
        }
    }
    
    System.debug('pvList-->'+pvList);
    if(pvList.size() > 0){
    	 insert pvList;
   		 PaymentVoucherRefundController.createPaymentVoucher(pvList);
    
    }
    
    
}