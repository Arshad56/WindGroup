trigger SetInvoiceIndex on Invoice__c (before insert,after update, after insert) {
    
    Set<Id> invIdsm = new Set<Id>();
    if(trigger.IsBefore){
        Set<Id> leaseIds = new Set<Id>();
        for(Invoice__c inv:Trigger.New){
            if(inv.Lease__c!=null){
                leaseIds.add(inv.Lease__c);
            }
        }
        if(leaseIds.size()>0){
            List<Lease__c> leaseList = [Select id,Property__c from Lease__c where id in:leaseIds];
            Map<Id,Id> leaseToPropertyMap = new Map<Id,Id>();
            Set<Id> propIds = new Set<Id>();
            for(Lease__c ls:leaseList){
                if(ls.Property__c!=null){
                    propIds.add(ls.Property__c);
                    leaseToPropertyMap.put(ls.Id,ls.Property__c);
                }
            }
            
            if(propIds.size()>0){
                Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Invoice_Index__c from Property__c where id in:propIds]);
                
                List<Property__c> propertyList = new List<Property__c>();
                Set<Id> dupCheck = new Set<Id>();
                for(Invoice__c inv:Trigger.New){
                    if(inv.Lease__c!=null && leaseToPropertyMap.containsKey(inv.Lease__c) && propMap.containsKey(leaseToPropertyMap.get(inv.Lease__c))){
                        property__c prop = propMap.get(leaseToPropertyMap.get(inv.Lease__c));
                        
                        Integer IntIndex = 1;
                        if(prop.Invoice_Index__c!=null && prop.Invoice_Index__c>0){
                            intIndex = Integer.valueOf(prop.Invoice_Index__c);
                        }
                        
                        Integer indexSize = string.valueOf(intIndex).length();
                        
                        string index = '';
                        for(integer i =1;i<=6-indexSize;i++){
                            index += '0';
                        }
                        index += string.valueOf(intIndex);
                        inv.Invoice_Index__c = index;
                        prop.Invoice_Index__c = intIndex + 1;
                        if(!dupCheck.contains(prop.Id)){
                            propertyList.add(prop);
                            dupCheck.add(prop.Id);
                        }
                    }
                }
                
                if(propertyList.size()>0){
                    update propertyList;
                }
            }
        }
    }
    
    //Added by Prabhat (TMC)
    if(trigger.IsAfter){
        set<Id> invoiceIds = new set<Id>();
        for(Invoice__c invc : trigger.new){
        	if(trigger.IsInsert){
        		invIdsm.add(invc.Id);
        	}else if(trigger.IsUpdate && (invc.Amount_Paid__c != Trigger.OldMap.get(invc.Id).Amount_Paid__c || invc.Total_Amount__c != Trigger.OldMap.get(invc.Id).Total_Amount__c || invc.Exchange_Rate__c != Trigger.OldMap.get(invc.Id).Exchange_Rate__c)){
        		invIdsm.add(invc.Id);
        	}
			
    			
    		if(trigger.IsUpdate){	
                if(invc.Invoice_Generated__c && !trigger.oldMap.get(invc.Id).Invoice_Generated__c){
                    invoiceIds.add(invc.Id);
                }
    		}
        }
        System.debug('invoiceIds-->'+invoiceIds);
        if(!invoiceIds.isEmpty()){
            DownloadInvoice.getAttachmentByInvoiceId(invoiceIds);
   	    }
    }
    
    /*if(invIdsm.size() > 0 && Trigger.isAfter && Utility.invoiceOnce){
    	List<Invoice__c> invList = [select Id,Exchange_Rate__c,Amount_Paid__c,Total_Amount__c,Outstanding_Amount__c,Foreign_Exchange_Rate__c,
    								Total_Amount_Local__c,Total_Amount_Foreign__c,Amount_Paid_Foreign__c,Amount_Paid_Local__c
    								 from Invoice__c where id =: invIdsm];
    	for(Invoice__c inv:invList){
			if(inv.Exchange_Rate__c!=null){
                if(inv.Exchange_Rate__c==1){
                    if(inv.Amount_Paid__c!=null){
                        inv.Amount_Paid_Local__c = Trigger.NewMap.get(inv.Id).Amount_Paid__c;
                        if(inv.Foreign_Exchange_Rate__c>0){
                            inv.Amount_Paid_Foreign__c = inv.Amount_Paid_Local__c/inv.Foreign_Exchange_Rate__c;
                        }
                    }
                }else{
                	System.debug('44444');
                    if(inv.Amount_Paid__c!=null){
                        inv.Amount_Paid_Foreign__c = Trigger.NewMap.get(inv.Id).Amount_Paid__c.setScale(2);
                        inv.Amount_Paid_Local__c = (inv.Amount_Paid__c*inv.Exchange_Rate__c).setScale(2);
                    } 
                }
                inv.Outstanding_Amount_Local__c = (inv.Total_Amount_Local__c!=null?inv.Total_Amount_Local__c:0) - (inv.Amount_Paid_Local__c !=null?inv.Amount_Paid_Local__c:0);
                inv.Outstanding_Amount_Foreign__c = (inv.Total_Amount_Foreign__c!=null?inv.Total_Amount_Foreign__c:0) - (inv.Amount_Paid_Foreign__c !=null?inv.Amount_Paid_Foreign__c:0);
            }
    		//}
    	}
    	Utility.invoiceOnce = false;
    	update invList;
    }*/
}