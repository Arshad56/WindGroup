global class  DownloadDeposit {
	public static Boolean fromButton1;
	public static Boolean fromButton2;
    webservice static void generateFromDeposit(Id depositId, String fromSrc){
    	
    	generateFromDepositTrigger(new Set<Id>{depositId}, fromSrc);
    	/*List<Attachment> listattach = new List<Attachment>();
    	Attachment attInsertLease = new Attachment();
        Attachment attInsertLeaseUnit = new Attachment();
        Attachment attInsertDeposit = new Attachment(); 
    	System.debug('depositId-->'+depositId);
    	System.debug('leaseId-->'+leaseId);
    	if(depositId != null){
    		list<Attachment> attdelete = new List<Attachment>();
    			Deposit__c dp=[select Id,Name,Deposit_Type__c,Lease_Unit__c,Lease_Unit__r.Unit__r.Name,Lease__c,CreatedDate from Deposit__c where id = : depositId];
    			DateTime crDt = Datetime.now();
    			String stdt = crDt.format('YYYYMMdd-HHmm');
    			String temp = '';
    			if(dp.Lease_Unit__r.Unit__c != null){
    				temp = dp.Lease_Unit__r.Unit__r.Name;
    			}
    			attInsertDeposit.name= dp.Name+'-'+temp+'-'+dp.Deposit_Type__c+'-'+stdt+'.PDF';
    			attInsertDeposit.ParentId = depositId;
    			attdelete=[SELECT Id FROM Attachment WHERE ParentId =: depositId];
    		if(!attdelete.isEmpty()){ 
                delete attdelete;
            }
            
            Blob body;
    		PageReference pdf = new PageReference('/apex/DepositPDF?depositId='+depositId+'&leaseId='+leaseId);
    		if(Test.isRunningTest()){
	            body = blob.valueOf('Test');
	        }else{
	            body = pdf.getContentAsPDF();
	        }
	        attInsertDeposit.Body = body;
            attInsertDeposit.IsPrivate = false;
            attInsertDeposit.contentType = 'application/pdf';
            listattach.add(attInsertDeposit);
            
            attInsertLeaseUnit.ParentId = dp.Lease_Unit__c;
            attInsertLeaseUnit.Name = attInsertDeposit.Name;
    	    attInsertLeaseUnit.Body = attInsertDeposit.Body;
            attInsertLeaseUnit.IsPrivate = attInsertDeposit.IsPrivate;
            attInsertLeaseUnit.contentType = attInsertDeposit.contentType ;
            listattach.add(attInsertLeaseUnit);
            
            attInsertLease.ParentId = dp.Lease__c;
            attInsertLease.Name = attInsertDeposit.Name;
    	    attInsertLease.Body = attInsertDeposit.Body;
            attInsertLease.IsPrivate = attInsertDeposit.IsPrivate;
            attInsertLease.contentType = attInsertDeposit.contentType ;
            listattach.add(attInsertLease);
           
            insert listattach;
    	}*/
    	
    }
    @future(callout=true)
    public static void generateFromDepositTrigger(Set<Id> depIds, String fromSrc){
    	
    	list<Attachment> attdelete = [SELECT Id,ParentId FROM Attachment WHERE ParentId =: depIds];
    	Set<Id> depAttCount = new Set<Id>();
    	
		if(!attdelete.isEmpty() && fromSrc != 'LOI To LA Conversion'){ 
            delete attdelete;
        }
        for(Attachment att: attdelete){
    		depAttCount.add(att.ParentId);
    	}
    	
    	List<Attachment> listattach = new List<Attachment>();
    	Attachment attInsertLease = new Attachment();
        Attachment attInsertLeaseUnit = new Attachment();
        
        Attachment attInsertLOI = new Attachment();
        Attachment attInsertLOIUnit = new Attachment();
        
        Attachment attInsertDeposit = new Attachment(); 
    	System.debug('depIds-->'+depIds);
		
		List<Deposit__c> dpList=[select Id,Name,Deposit_Type__c,Lease_Unit__c,Lease_Unit__r.Unit__r.Name,Lease__c,LOI_Unit__c,LOI_Unit__r.Unit__r.Name,LOI__c,CreatedDate from Deposit__c where id = : depIds];
		for(Deposit__c dpo: dpList){
			System.debug('dpo-->'+dpo);
			DateTime crDt = Datetime.now();
			String stdt = crDt.format('YYYYMMdd-HHmm');
			String temp = '';
				if(dpo.Lease_Unit__r.Unit__c != null){
					temp = dpo.Lease_Unit__r.Unit__r.Name;
				}else if(dpo.LOI_Unit__r.Unit__c != null){
					temp = dpo.LOI_Unit__r.Unit__r.Name;
				}

			attInsertDeposit.name= dpo.Name+'-'+temp+'-'+dpo.Deposit_Type__c+'-'+stdt+'.PDF';
			attInsertDeposit.ParentId = dpo.Id;
	        
	        Blob body;
			PageReference pdf = new PageReference('/apex/DepositPDF?depositId='+dpo.Id);
			if(Test.isRunningTest()){
	            body = blob.valueOf('Test');
	        }else{
	            body = pdf.getContentAsPDF();
	        }
	        attInsertDeposit.Body = body;
	        attInsertDeposit.IsPrivate = false;
	        attInsertDeposit.contentType = 'application/pdf';
	        
	        if(fromSrc != 'LOI To LA Conversion'){
	        	listattach.add(attInsertDeposit);
	        }
	        
	        if(dpo.Lease_Unit__c != null){
	        	attInsertLeaseUnit.ParentId = dpo.Lease_Unit__c;
		        attInsertLeaseUnit.Name = attInsertDeposit.Name;
			    attInsertLeaseUnit.Body = attInsertDeposit.Body;
		        attInsertLeaseUnit.IsPrivate = attInsertDeposit.IsPrivate;
		        attInsertLeaseUnit.contentType = attInsertDeposit.contentType ;
		        listattach.add(attInsertLeaseUnit);
	        }
	        if(dpo.Lease__c != null){    
		        attInsertLease.ParentId = dpo.Lease__c;
		        attInsertLease.Name = attInsertDeposit.Name;
			    attInsertLease.Body = attInsertDeposit.Body;
		        attInsertLease.IsPrivate = attInsertDeposit.IsPrivate;
		        attInsertLease.contentType = attInsertDeposit.contentType ;
		        listattach.add(attInsertLease);
	        }
	       
		}
		if(listattach.size() > 0)
        insert listattach;
        System.debug('listattach-->'+listattach.size());
    	
    }
}