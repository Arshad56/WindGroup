global class InvoiceButtonClick {
	
    webservice static void voidAllInvoices(Id invoiceId, String reason) { 
        
        System.debug('Button clicked-->'+ invoiceId);
		if(invoiceId != null || invoiceId != ''){
	        Invoice__c seletedInvoice = new Invoice__c(id = invoiceId, Voided__c = true,Void_Reason__c = reason,Void_Datetime__c = System.now());
	        update seletedInvoice;
				
	        Invoice__c invTemp = [select id, Billing_Type__c from Invoice__c where id =: invoiceId];
	       
	        Map<Id,Invoice_Line_Item__c> allRelatedLineItems = new Map<Id,Invoice_Line_Item__c> ([select id,Invoice__c,Voided__c from Invoice_Line_Item__c where Invoice__c =: invoiceId]);
	        System.debug('Button clicked-->'+ invoiceId);
	        for(Invoice_Line_Item__c il: allRelatedLineItems.values()){
	        	il.Voided__c = true;
	        	il.Void_Datetime__c = System.now(); 
	        	System.debug('il-->'+ il);
	        }
	        
	        List<Rent_Roll_Detail__c> allRelatedRentDet = [select Id,Voided__c from Rent_Roll_Detail__c where Status__c = 'Approved' And Invoice_Line_Item__c =: allRelatedLineItems.keySet()];
	    	System.debug('allRelatedRentDet-->'+ allRelatedRentDet);
	    	Set<Id> rrdId = new Set<Id>();
	    	for(Rent_Roll_Detail__c rrd: allRelatedRentDet){
	    		rrdId.add(rrd.Id);
	    		rrd.Voided__c = true;
	    		rrd.Void_Datetime__c = System.now(); 
	    		System.debug('rrd-->'+ rrd);
	    	}
	    	System.debug('rrdId-->'+ rrdId);
	    	List<Rent_Schedules__c> rentSchedulesList = [select Id,Status__c,RR_Text__c,RRD_Text__c,Rent_Roll__c,Invoice_Line_Item__r.Invoice__r.Billing_Type__c,Rent_Roll_Detail__c,Approved__c from Rent_Schedules__c where Rent_Roll_Detail__c =: rrdId];
	    	System.debug('rentSchedulesList-->'+ rentSchedulesList);
	    	
	    	set<String> billingType = new Set<String>();
	    	billingType.add('Ad-Hoc Invoice');
			billingType.add('Credit Note');
			billingType.add('Debit Note');
			billingType.add('Late Charge');
			billingType.add('Miscellaneous');
	    	
	    	for(Rent_Schedules__c rs:rentSchedulesList){
	    		System.debug('rs-->'+ rs);
	    		System.debug('rs.RR_Text__c-->'+ rs.RR_Text__c);
	    		System.debug('rs.Rent_Roll__c-->'+ rs.Rent_Roll__c);
	    		
	    		rs.RRD_Text__c = String.valueOf(rs.Rent_Roll_Detail__c);//.substring(0, 15);
    			rs.RR_Text__c  = String.valueOf(rs.Rent_Roll__c);//.substring(0, 15);
    			
	    		if(!billingType.contains(invTemp.Billing_Type__c) || invTemp.Billing_Type__c == null){
		    		rs.Rent_Roll__c = null;
		    		rs.Rent_Roll_Detail__c = null;
		    		rs.Status__c = 'In-Tenancy';
		    	}
	    		rs.Approved__c = false;
	    		
	    		System.debug('rs11-->'+ rs);
	    	}
	    	
	    	//try{
	    		update seletedInvoice;
	    		update allRelatedLineItems.values();
	    		update allRelatedRentDet;
	    		update rentSchedulesList;
	    		MainTriggerRentRollDetails_Helper.rollupAmount(new Set<Id>{seletedInvoice.id});
	    		MainTriggerRentRollDetails_Helper.makeRentScheduleBlank(new Set<Id>{seletedInvoice.id});
	    		
	    	//}catch(Exception e){
	    	//	System.debug('Exception Occured--> '+e);
	    	//}
		}	
    }
    webservice static void unvoidAllInvoices(Id invoiceId) { 
        
        System.debug('Button clicked-->'+ invoiceId);
		if(invoiceId != null || invoiceId != ''){
	        Invoice__c seletedInvoice = new Invoice__c(id = invoiceId, Voided__c = false, Void_Reason__c = '');
	        
	        Map<Id,Invoice_Line_Item__c> allRelatedLineItems = new Map<Id,Invoice_Line_Item__c> ([select id,Invoice__c,Voided__c from Invoice_Line_Item__c where Invoice__c =: invoiceId]);
	        System.debug('Button clicked-->'+ invoiceId);
	        for(Invoice_Line_Item__c il: allRelatedLineItems.values()){
	        	il.Voided__c = false;
	        	il.Void_Datetime__c = null; 
	        	System.debug('il-->'+ il);
	        }
	        
	        List<Rent_Roll_Detail__c> allRelatedRentDet = [select Id,Voided__c from Rent_Roll_Detail__c where Status__c = 'Approved' And Invoice_Line_Item__c =: allRelatedLineItems.keySet()];
	    	System.debug('allRelatedRentDet-->'+ allRelatedRentDet);
	    	Set<Id> rrdId = new Set<Id>();
	    	for(Rent_Roll_Detail__c rrd: allRelatedRentDet){
	    		rrdId.add(rrd.Id);
	    		rrd.Voided__c = false;
	    		rrd.Void_Datetime__c = null; 
	    		System.debug('rrd-->'+ rrd);
	    	}
	    	System.debug('rrdId-->'+ rrdId);
	    	List<Rent_Schedules__c> rentSchedulesList = [select Id,Status__c,RRD_Text__c,RR_Text__c,Rent_Roll__c,Rent_Roll_Detail__c,Approved__c from Rent_Schedules__c where RRD_Text__c =: rrdId];
	    	System.debug('rentSchedulesList-->'+ rentSchedulesList);
	    	for(Rent_Schedules__c rs:rentSchedulesList){
	    		rs.Rent_Roll__c = rs.RR_Text__c;
	    		rs.Rent_Roll_Detail__c = rs.RRD_Text__c;
	    		rs.Approved__c = true;
	    		rs.Status__c = 'Rent Roll Generated	';
	    	}
	    	
	    	//try{
	    		update seletedInvoice;
	    		update allRelatedLineItems.values();
	    		update allRelatedRentDet;
	    		update rentSchedulesList;
	    		MainTriggerRentRollDetails_Helper.rollupAmount(new Set<Id>{seletedInvoice.id});
	    		MainTriggerRentRollDetails_Helper.makeRentScheduleBlank(new Set<Id>{seletedInvoice.id});
	    		
	    	//}catch(Exception e){
	    	//	System.debug('Exception Occured--> '+e);
	    	//}
		}	
    }
}