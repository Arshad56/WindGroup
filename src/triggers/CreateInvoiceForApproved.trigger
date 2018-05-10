trigger CreateInvoiceForApproved on Rent_Roll__c (after update){
    if(Utility.invCreateRun){
        Set<Id> rentRollIds = new Set<Id>();
        Map<Id,String> mapLeaseIdEmail = new Map<Id,String>(); //added by myat oct-29;
        Map<Id,Id> mapLeaseIdTenantId = new Map<Id,Id>();//added by myat nov-29;
        Set<Id> propIds = new Set<Id>();
        for(Rent_Roll__c rr:Trigger.New){
            if(rr.Approved__c && rr.Approved__c!=Trigger.OldMap.get(rr.Id).Approved__c){
                rentRollIds.add(rr.Id);
                if(rr.Property__c!=null){
                    propIds.add(rr.Property__c);
                }
            }
        }
        List<Billing_Due_Day__c> biilingDaysList = [select Id, Billing_Due_Days__c, Billing_Type__c, Property__c from Billing_Due_Day__c where Property__c =: propIds];
        Map<Id, Map<String,Decimal>> biilingDaysMap = new Map<Id,Map<String,Decimal>>();
        for(Billing_Due_Day__c bb: biilingDaysList){ 
            System.debug('bb.Billing_Type__c--->'+bb.Billing_Type__c);
            if(bb.Billing_Type__c != null){
                Map<String,Decimal>  strMap = new Map<String,Decimal>();
                if(biilingDaysMap.containsKey(bb.Property__c)){
                    strMap = biilingDaysMap.get(bb.Property__c);
                }
                String[] tmpString = bb.Billing_Type__c.split(';');
                System.debug('tmpString--->'+tmpString);
                for(String s : tmpString){
                     System.debug('s--->'+biilingDaysMap);
                    strMap.put(s,Integer.valueOf(bb.Billing_Due_Days__c));
                }
                /*if(bb.Billing_Due_Days__c != null){
                    strMap.put(bb.Billing_Type__c,Integer.valueOf(bb.Billing_Due_Days__c));
                }else{
                    strMap.put(bb.Billing_Type__c,0);
                }*/
                biilingDaysMap.put(bb.Property__c, strMap);
            }
        }
        System.debug('biilingDaysMap--->'+biilingDaysMap);
        if(rentRollIds.size()>0){
            Set<Id> leaseIds = new Set<Id>();
            Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Billing_Due_Days__c from Property__c where id in:propIds]);
            map<Id,map<Id,Map<string,List<Rent_Roll_Detail__c>>>> rentrollToDetailMap = new map<Id,map<Id,Map<string,List<Rent_Roll_Detail__c>>>>();
            List<Rent_Roll_Detail__c> rentDetails = [Select id,Charge_Type__c,Remarks__c,Transaction_Start_Date__c,Transaction_End_Date__c,Comm_Tax_Amount__c,Billing_Date__c,Name,Amount__c,Rent_Roll__c,Lease_Charge__c,Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__c,Lease_Unit__r.Lease_Agreement_No__r.Financial_Contact__r.Email,Lease_Unit__r.Lease_Agreement_No__r.Tenant__c,Tenant__c,Lease_Charge__r.Charge_Description__c,Electric_Meter__c,Electric_Meter_Number__c,Invoice_Line_Item__c,Start_Date__c,End_Date__c,Invoice__c,Invoice__r.Lease__c,Invoice__r.Lease__r.Financial_Contact__r.Email,Invoice__r.Lease__r.Tenant__c,Currency_Code__c,Exchange_Rate__c,Amount_Local__c,Amount_Foreign__c,Comm_Tax_Amount_Local__c,Comm_Tax_Amount_Foreign__c,Outstanding_Amount__c,Default_Days__c,Late_Percent_Rate__c,POS_Sales_Amount__c,GTO_Amount__c,(Select id,Invoice_Line_Item__c,Invoice_Line_Item__r.Invoice__r.Name from Rent_Schedules__r where Invoice_Line_Item__c!=null limit 1) from Rent_Roll_Detail__c where Rent_Roll__c in:rentRollIds and status__c='Approved'];
            if(rentDetails.size()>0){
                 for(Rent_Roll_Detail__c rrd:rentDetails){
                     if(rrd.Lease_Unit__c!=null){
                         mapLeaseIdEmail.put(rrd.Lease_Unit__r.Lease_Agreement_No__c, rrd.Lease_Unit__r.Lease_Agreement_No__r.Financial_Contact__r.Email); //added by myat oct-29;
                     }else if(rrd.Invoice__c!=null){
                         mapLeaseIdEmail.put(rrd.Invoice__r.Lease__c, rrd.Invoice__r.Lease__r.Financial_Contact__r.Email);
                     }
                     
                     map<Id,map<string,List<Rent_Roll_Detail__c>>> tempMap = new map<Id,map<string,List<Rent_Roll_Detail__c>>>();
                     Map<string,List<Rent_Roll_Detail__c>> tempMap2 = new Map<string,List<Rent_Roll_Detail__c>>();
                     List<Rent_Roll_Detail__c> tempList = new List<Rent_Roll_Detail__c>();
                     if(rentrollToDetailMap.containsKey(rrd.Rent_Roll__c)){
                         tempMap = rentrollToDetailMap.get(rrd.Rent_Roll__c);
                         if(rrd.Lease_Unit__c!=null){
                             if(tempMap.containsKey(rrd.Lease_Unit__r.Lease_Agreement_No__c)){
                                 tempMap2 = tempMap.get(rrd.Lease_Unit__r.Lease_Agreement_No__c);
                             }
                         }else if(rrd.Invoice__c!=null){
                             if(tempMap.containsKey(rrd.Invoice__r.Lease__c)){
                                 tempMap2 = tempMap.get(rrd.Invoice__r.Lease__c);
                             }
                         }
                     }
                     if(rrd.Lease_Charge__c!=null){
                         if(tempMap2.containsKey(rrd.Start_Date__c.Month()+'-'+rrd.Start_Date__c.Year()+'-'+rrd.Lease_Charge__c)){
                             tempList.addAll(tempMap2.get(rrd.Start_Date__c.Month()+'-'+rrd.Start_Date__c.Year()+'-'+rrd.Lease_Charge__c));
                         }
                     }else if(rrd.Invoice__c!=null){
                         if(tempMap2.containsKey(rrd.Invoice__c)){
                             tempList.addAll(tempMap2.get(rrd.Invoice__c));
                         }
                     }
                     tempList.add(rrd);
                     if(rrd.Lease_Charge__c!=null){
                         tempMap2.put(rrd.Start_Date__c.Month()+'-'+rrd.Start_Date__c.Year()+'-'+rrd.Lease_Charge__c,tempList);
                     }else{
                         tempMap2.put(rrd.Invoice__c,tempList);
                     }
                     if(rrd.Lease_Unit__c!=null){
                         tempMap.put(rrd.Lease_Unit__r.Lease_Agreement_No__c,tempMap2);
                     }else if(rrd.Invoice__c!=null){
                         tempMap.put(rrd.Invoice__r.Lease__c,tempMap2);
                     }
                     rentrollToDetailMap.put(rrd.Rent_Roll__c,tempMap);
                     if(rrd.Lease_Unit__c!=null){
                         leaseIds.add(rrd.Lease_Unit__r.Lease_Agreement_No__c);
                         mapLeaseIdTenantId.put(rrd.Lease_Unit__r.Lease_Agreement_No__c, rrd.Lease_Unit__r.Lease_Agreement_No__r.Tenant__c);//added by myat nov-29
                     }else if(rrd.Invoice__c!=null){
                         leaseIds.add(rrd.Invoice__r.Lease__c);
                         mapLeaseIdTenantId.put(rrd.Invoice__r.Lease__c, rrd.Invoice__r.Lease__r.Tenant__c);//added by myat nov-29
                     }
                 }
            }
            
            if(rentrollToDetailMap.size()>0){
                Map<Id,Lease__c> leaseMap = new Map<Id,Lease__c>([Select id,Tenant_Type__c,Price_Factor__c,Charge_Method__c from Lease__c where id in:leaseIds]);
                List<Invoicewrapper> invWrapperList = new List<Invoicewrapper>();
                for(Rent_Roll__c rr:Trigger.New){
                    if(rentrollToDetailMap.containsKey(rr.Id)){
                        map<Id,Map<string,List<Rent_Roll_Detail__c>>> tempMap = rentrollToDetailMap.get(rr.Id);
                        for(Id leaseId:tempMap.keyset()){
                            
                            if(rr.Billing_Type__c!='Late Charge'){
                                Invoicewrapper invWrap = new Invoicewrapper();
                                Invoice__c inv = new Invoice__c();
                                inv.Rent_Roll__c = rr.Id;
                                inv.Status__c = 'Outstanding';
                                inv.Invoice_Type__c = 'System Generated Invoice';
                                inv.Lease__c = leaseId;
                                if(leaseMap.containsKey(leaseId)){
                                    inv.tenant_Type__c = leaseMap.get(leaseId).Tenant_Type__c;
                                    inv.Price_Factor__c = leaseMap.get(leaseId).Price_Factor__c;
                                    inv.Charge_Method__c = leaseMap.get(leaseId).Charge_Method__c;
                                }
                                inv.Billing_Email__c = mapLeaseIdEmail.get(leaseId);//added by myat oct-29;
                                inv.Tenant_Name__c = mapLeaseIdTenantId.get(leaseId);//added by myat nov-29
                                
                                string billingType = rr.Billing_Type__c;
                                
                                if(billingType!='Late Charge'){
                                    inv.Currency_Code__c = rr.Currency_Code__c;
                                }
                                                        
                                if(billingType=='Credit Note' || billingType=='Miscellaneous'){
                                    inv.Late_Charge_Applicable__c = false;
                                }
                                
                                if(billingType=='Late Charge' || billingType=='Debit Note' || billingType=='Credit Note' || billingType=='Rent' || billingType=='Monthly' || billingType=='GTO Rent'){
                                    inv.Exchange_Rate__c = rr.Exchange_Rate__c;
                                }
                                
                                if(rr.Actual_Invoice_Date__c!=null){
                                    inv.Invoice_Date__c = rr.Actual_Invoice_Date__c;
                                    if(rr.Property__c!=null && propMap.containsKey(rr.Property__c) && propMap.get(rr.Property__c).Billing_Due_Days__c!=null){
                                        if(biilingDaysMap.containsKey(rr.Property__c) && biilingDaysMap.get(rr.Property__c).containsKey(billingType)){
                                            inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(Integer.valueOf(biilingDaysMap.get(rr.Property__c).get(billingType)));
                                        }else{
                                            if(billingType=='Debit Note' || billingType=='Credit Note' || billingType=='Ad-Hoc Invoice' || billingType=='Late Charge'){
                                                inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(7);
                                            }else{
                                                inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(Integer.valueOf(propMap.get(rr.Property__c).Billing_Due_Days__c));
                                            }
                                        }
                                    }
                                }
                                    
                                invWrap.inv = inv;
                                
                                Map<string,List<Rent_Roll_Detail__c>> tempMap2 = tempMap.get(leaseId);
                            
                                for(string str:tempMap2.keyset()){
                                    LineItemWrapper liw = new LineItemWrapper();
                                    Invoice_Line_Item__c invLinItm = new Invoice_Line_Item__c();
                                    //invLinItm.Description__c = rs.Lease_Charge__r.Charge_Description__c;
                                    invLinItm.Amount__c = 0;
                                    invLinItm.Comm_Tax_Amount__c = 0;
                                    for(Rent_Roll_Detail__c rrd:tempMap2.get(str)){
                                        invLinItm.Amount__c += (rrd.Amount__c!=null?rrd.Amount__c.setScale(2):0);
                                        invLinItm.Comm_Tax_Amount__c += (rrd.Comm_Tax_Amount__c!=null?rrd.Comm_Tax_Amount__c:0);
                                        if(invLinItm.Description__c==null){
                                            if(rrd.Lease_Charge__c!=null){
                                                invLinItm.Description__c = rrd.Lease_Charge__r.Charge_Description__c;
                                            }else{
                                                invLinItm.Description__c = rrd.Remarks__c;
                                            }
                                           
                                            invLinItm.Start_Date__c = rrd.Start_Date__c;
                                            invLinItm.End_Date__c = rrd.End_Date__c;
                                            invLinItm.Lease_Charge__c = rrd.Lease_Charge__c;
                                            invLinItm.Transaction_Start_Date__c = rrd.Transaction_Start_Date__c;
                                            invLinItm.Transaction_End_Date__c = rrd.Transaction_End_Date__c;
                                            //invLinItm.Amount_Local__c = rrd.Amount_Local__c;
                                            //invLinItm.Amount_Foreign__c = rrd.Amount_Foreign__c;
                                            //invLinItm.Comm_Tax_Amount_Local__c = rrd.Comm_Tax_Amount_Local__c;
                                            //invLinItm.Comm_Tax_Amount_Foreign__c = rrd.Comm_Tax_Amount_Foreign__c;
                                            //invLinItm.Exchange_Rate__c = rrd.Exchange_Rate__c;
                                            invLinItm.Currency_Code__c = rrd.Currency_Code__c;
                                            
                                            if(inv.Currency_Code__c==null && billingtype=='Late Charge'){
                                                inv.Currency_Code__c = rrd.Currency_Code__c;
                                                inv.Exchange_Rate__c = rrd.Exchange_Rate__c;
                                            }
                                            
                                            invLinItm.Due_Days__c = rrd.Default_Days__c;
                                            invLinItm.Late_Rate__c = rrd.Late_Percent_Rate__c;
                                            invLinItm.Invoice_old__c = rrd.Invoice__c;
                                            invLinItm.Outstanding_Amount__c = rrd.Outstanding_Amount__c;
                                            
                                            invLinItm.Sales_Amount__c = rrd.POS_Sales_Amount__c;
                                            invLinItm.GTO_Amount__c = rrd.GTO_Amount__c;
                                            
                                            if(rrd.Charge_Type__c=='Invoice Discount'){
                                                invLinItm.Withholding_Tax__c = true;
                                            }
                                            
                                        }
                                        system.debug('billingType===='+billingType);
                                        if((billingType=='Debit Note' || billingType=='Credit Note') && invLinItm.Old_Inovoice_Name__c==null){
											
                                            if(rrd.Rent_Schedules__r.size()>0){
												
                                                invLinItm.Old_Inovoice_Name__c = rrd.Rent_Schedules__r[0].Invoice_Line_Item__r.Invoice__r.Name;
                                            }
                                        }
                                        
                                        liw.rentRollDetails.add(rrd);
                                    }
                                    liw.lineItem = invLinItm;
                                    
                                    invWrap.invLineItemList.add(liw);
                                }
                                invWrapperList.add(invWrap);
                            }else{
                                Map<string,List<Rent_Roll_Detail__c>> tempMap2 = tempMap.get(leaseId);
                                for(string str:tempMap2.keyset()){
                                    Invoicewrapper invWrap = new Invoicewrapper();
                                    Invoice__c inv = new Invoice__c();
                                    inv.Rent_Roll__c = rr.Id;
                                    inv.Status__c = 'Outstanding';
                                    inv.Invoice_Type__c = 'System Generated Invoice';
                                    inv.Lease__c = leaseId;
                                    inv.Billing_Email__c = mapLeaseIdEmail.get(leaseId);//added by myat oct-29;
                                    inv.Tenant_Name__c = mapLeaseIdTenantId.get(leaseId);//added by myat nov-29
                                    string billingType = rr.Billing_Type__c;
                                    //inv.Currency_Code__c = rr.Currency_Code__c;
                                    inv.Late_Charge_Applicable__c = false;                                                            
                                    //inv.Exchange_Rate__c = rr.Exchange_Rate__c;
                                    
                                    if(rr.Actual_Invoice_Date__c!=null){
                                        inv.Invoice_Date__c = rr.Actual_Invoice_Date__c;
                                        if(rr.Property__c!=null && propMap.containsKey(rr.Property__c) && propMap.get(rr.Property__c).Billing_Due_Days__c!=null){
                                            if(biilingDaysMap.containsKey(rr.Property__c) && biilingDaysMap.get(rr.Property__c).containsKey(billingType)){
                                                inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(Integer.valueOf(biilingDaysMap.get(rr.Property__c).get(billingType)));
                                            }else{
                                                if(billingType=='Debit Note' || billingType=='Credit Note' || billingType=='Ad-Hoc Invoice' || billingType=='Late Charge'){
                                                    inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(7);
                                                }else{
                                                    inv.Payment_Due_Date__c = inv.Invoice_Date__c.addDays(Integer.valueOf(propMap.get(rr.Property__c).Billing_Due_Days__c));
                                                }
                                            }
                                        }
                                    }
                                    
                                    for(Rent_Roll_Detail__c rrd:tempMap2.get(str)){
                                        LineItemWrapper liw = new LineItemWrapper();
                                        Invoice_Line_Item__c invLinItm = new Invoice_Line_Item__c();
                                        invLinItm.Amount__c = (rrd.Amount__c!=null?rrd.Amount__c.setScale(2):0);
                                        invLinItm.Comm_Tax_Amount__c = (rrd.Comm_Tax_Amount__c!=null?rrd.Comm_Tax_Amount__c:0);
                                        if(rrd.Lease_Charge__c!=null){
                                            invLinItm.Description__c = rrd.Lease_Charge__r.Charge_Description__c;
                                        }else{
                                            invLinItm.Description__c = rrd.Remarks__c;
                                        }
                                       
                                        invLinItm.Start_Date__c = rrd.Start_Date__c;
                                        invLinItm.End_Date__c = rrd.End_Date__c;
                                        invLinItm.Lease_Charge__c = rrd.Lease_Charge__c;
                                        invLinItm.Transaction_Start_Date__c = rrd.Transaction_Start_Date__c;
                                        invLinItm.Transaction_End_Date__c = rrd.Transaction_End_Date__c;
                                        invLinItm.Currency_Code__c = rrd.Currency_Code__c;
                                        
                                        if(inv.Currency_Code__c==null && billingtype=='Late Charge'){
                                            inv.Currency_Code__c = rrd.Currency_Code__c;
                                            inv.Exchange_Rate__c = rrd.Exchange_Rate__c;
                                        }
                                        
                                        invLinItm.Due_Days__c = rrd.Default_Days__c;
                                        invLinItm.Late_Rate__c = rrd.Late_Percent_Rate__c;
                                        invLinItm.Invoice_old__c = rrd.Invoice__c;
                                        invLinItm.Outstanding_Amount__c = rrd.Outstanding_Amount__c;
                                        
                                        invLinItm.Sales_Amount__c = rrd.POS_Sales_Amount__c;
                                        invLinItm.GTO_Amount__c = rrd.GTO_Amount__c;
                                        
                                        liw.rentRollDetails.add(rrd);
                                        liw.lineItem = invLinItm;
                                        invWrap.invLineItemList.add(liw);
                                    }
                                    invWrap.inv = inv;
                                    invWrapperList.add(invWrap);
                                }
                            }
                        }
                    }
                }
                
                if(invWrapperList.size()>0){
                    List<Invoice__c> invList = new List<Invoice__c>();
                    for(Invoicewrapper iw:invWrapperList){
                        if(iw.invLineItemList.size()==0){
                            iw.inv.Status__c= 'Paid';
                        }else{
                            Decimal amt = 0;
                            for(LineItemWrapper liWrap:iw.invLineItemList){
                                amt += liWrap.lineItem.Amount__c;
                            }
                            if(amt==0){
                                iw.inv.Status__c= 'Paid';
                            }
                        }
                        invList.add(iw.inv);
                    }
                    insert invList;
                    List<Invoice_Line_Item__c> invLinItms = new List<Invoice_Line_Item__c>();
                    for(Invoicewrapper iw:invWrapperList){
                        for(LineItemWrapper liWrap:iw.invLineItemList){
                            liWrap.lineItem.Invoice__c = iw.inv.Id;
                            invLinItms.add(liWrap.lineItem);
                        }
                    }
                    insert invLinItms;
                    
                    List<Rent_Roll_Detail__c> rentRollDetailList = new List<Rent_Roll_Detail__c>();
                    for(Invoicewrapper iw:invWrapperList){
                        for(LineItemWrapper liWrap:iw.invLineItemList){
                            for(Rent_Roll_Detail__c rrd:liWrap.rentRollDetails){
                                rrd.Invoice_Line_Item__c = liWrap.lineItem.Id;
                                rentRollDetailList.add(rrd);
                            }
                        }
                    }
                    
                    update rentRollDetailList;
                    
                    Set<Id> invIds = new Set<Id>();
                    for(Invoice__c inv:invList){
                        invIds.add(inv.Id);
                    }
                    
                    invList = [Select billing_Type__c,Invoice_Generated__c from Invoice__c where id in:invIds];
                    List<Invoice__c> updInvoices = new List<Invoice__c>();
                    for(Invoice__c inv:invList){
                        if(inv.billing_Type__c=='Late Charge'){
                            inv.Invoice_Generated__c = true;
                            updInvoices.add(inv);
                        }
                    }
                    update updInvoices;
                    
                    Utility.invCreateRun = false;
                }
            }
        }
    }
    class Invoicewrapper{
        Invoice__c inv;
        List<LineItemWrapper>  invLineItemList;
        Invoicewrapper(){
            inv = new Invoice__c();
            invLineItemList = new List<LineItemWrapper>();
        }
    }
    
    class LineItemWrapper{
        Invoice_Line_Item__c lineItem;
        List<Rent_Roll_Detail__c> rentRollDetails;
        public LineItemWrapper(){
            lineItem = new Invoice_Line_Item__c();
            rentRollDetails = new List<Rent_Roll_Detail__c>();
        }
    }
}