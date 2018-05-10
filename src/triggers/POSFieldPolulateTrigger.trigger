trigger POSFieldPolulateTrigger on POS_Transaction__c (before insert, after insert) {
	if(Trigger.isBefore){
	    Set<string> posIds = new Set<string>();
	    Set<Id> rsIds = new Set<Id>();
	    Map<Id,POS_Transaction__c> posNewTrans = new Map<Id,POS_Transaction__c>();
	    for(POS_Transaction__c pt:trigger.New){
	        if(pt.POS_Id__c!=null && !pt.Manual__c){
	            posIds.add(pt.POS_Id__c);
	            System.debug('pt.POS_Id__c-->'+pt.POS_Id__c);
	        }else if(pt.Rent_Schedule__c!= null && pt.Manual__c){
	        	rsIds.add(pt.Rent_Schedule__c);
	        	posNewTrans.put(pt.Rent_Schedule__c,pt);
	        }
	    }
	    if(rsIds.size() > 0){
	    	List<Rent_Schedules__c> rsList = [select Id,Property_Short_Code__c,Start_Date__c,Transaction_Start_Date__c,Transaction_End_Date__c,End_Date__c,Lease_Unit__c,PropertyLU__c from Rent_Schedules__c where Id =: rsIds ];
	    	Map<Id, Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>(rsList);
	    	for(Rent_Schedules__c rs:rsList){
	    		rs.Transaction_Status__c = 'Applicable - Imported';
	    		if(posNewTrans.containsKey(rs.Id)){
	    			if(rs.Transaction_Start_Date__c == null || rs.Transaction_Start_Date__c > posNewTrans.get(rs.Id).From_Date__c){
                        rs.Transaction_Start_Date__c =  posNewTrans.get(rs.Id).From_Date__c;
                    }
	    			if(rs.Transaction_End_Date__c == null || rs.Transaction_End_Date__c < posNewTrans.get(rs.Id).To_Date__c){
                        rs.Transaction_End_Date__c =  posNewTrans.get(rs.Id).To_Date__c;
                    }
                }
	    	}
	    	for(POS_Transaction__c pt:trigger.New){
	    		if(pt.To_Date__c == null ||  pt.From_Date__c == null){
            		pt.addError('From Date and To Date is required.');
            	}else if(pt.From_Date__c > pt.To_Date__c){
	    			pt.addError('From Date must be before To Date.');
	    		}else if(pt.From_Date__c > rsMap.get(pt.Rent_Schedule__c).End_Date__c ){
	    			pt.addError('From Date must be before End date.');
	    		}else if(pt.To_Date__c  < rsMap.get(pt.Rent_Schedule__c).Start_Date__c || pt.To_Date__c > rsMap.get(pt.Rent_Schedule__c).End_Date__c ){
	    			pt.addError('To Date must be between Rent Schedule Start date and End date.');
	    		}else{
		    		if(rsMap.get(pt.Rent_Schedule__c).Lease_Unit__c!= null)
		    			pt.Lease_Unit__c = rsMap.get(pt.Rent_Schedule__c).Lease_Unit__c;
		    		if(rsMap.get(pt.Rent_Schedule__c).PropertyLU__c!= null){
		    			pt.Property__c = rsMap.get(pt.Rent_Schedule__c).PropertyLU__c;
		    			pt.Property_Short_Code__c = rsMap.get(pt.Rent_Schedule__c).Property_Short_Code__c;
		    		}
	    		}
	    	}
    		update rsList;
	    }
	    if(posIds.size()>0){
	        Set<Id> leaseUnitIds = new Set<Id>();
	        List<Lease_POS__c> leasePOSList = [Select id,Name,Start_Date__c,End_Date__c,Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__r.Property__c from Lease_POS__c where name in:posIds and Start_Date__c!=null and End_Date__c!=null and Lease_Unit__c!=null];
	        List<Lease_POS__c> leasePOSList11 = [Select id,Name,Start_Date__c,End_Date__c,Lease_Unit__c,Lease_Unit__r.Lease_Agreement_No__r.Property__c from Lease_POS__c ];
	        System.debug('leasePOSList11--> '+leasePOSList11);
	        
	        System.debug('leasePOSList-->'+leasePOSList);
	        Map<String,Id> LeasePOSmap = new Map<String,Id>();
	        for(Lease_POS__c lp:leasePOSList){
	        	System.debug('lp.Lease_Unit__c-->'+lp.Lease_Unit__c);
	            leaseUnitIds.add(lp.Lease_Unit__c);
	            LeasePOSmap.put(lp.name, lp.Id);
	        }
		    
	        if(leaseUnitIds.size()>0){
	        	Map<String, List<POS_Transaction__c>> multiplePOScheck = new Map<String, List<POS_Transaction__c>>();
	        	Set<Id> tempRSIds= new Set<Id>();
	        	
	            Map<Id,List<Rent_Schedules__c>> unitToRsMap = new Map<Id,List<Rent_Schedules__c>>();
	            for(Lease_Charges__c ls:[Select id,Lease_Unit__c,Charge_Type__c,(Select id,Currency_Code__c,Lease_Charge__c,Lease_Charge__r.Type__c,Start_Date__c,End_Date__c,Transaction_Start_Date__c,Transaction_End_Date__c,Transaction_Status__c from Rent_Schedules__r Where Status__c='In-Tenancy' OR Status__c='Rent Free') from Lease_Charges__c where Lease_Unit__c in:leaseUnitIds and Charge_Type__c='GTO Rent']){
	                if(ls.Rent_Schedules__r.size() > 0){
	                	List<Rent_Schedules__c> tempRS = new List<Rent_Schedules__c>(); 
		                if(unitToRsMap.containsKey(ls.Lease_Unit__c)){
		                    tempRS.addAll(unitToRsMap.get(ls.Lease_Unit__c));
		                }
		                tempRS.addAll(ls.Rent_Schedules__r);
		                unitToRsMap.put(ls.Lease_Unit__c,tempRS);
		                for(Rent_Schedules__c rs:ls.Rent_Schedules__r){
		                	tempRSIds.add(rs.Id);
		                }
	                }
	            }
	            for(Rent_Schedules__c rentS: [select Id,(Select Id,From_Date__c, To_Date__c, POS_Id__c From Monthly_Transaction_Summary__r)  from Rent_Schedules__c where Id=: tempRSIds And (Status__c='In-Tenancy'  OR Status__c='Rent Free')]){
	            	for(POS_Transaction__c pos:rentS.Monthly_Transaction_Summary__r){
	            		String key = (rentS.Id+'-'+pos.POS_Id__c).replace(' ', '@');
	            		List<POS_Transaction__c> tempList = new List<POS_Transaction__c>();
	            		if(multiplePOScheck.containsKey(key))
	            			tempList = multiplePOScheck.get(key);
	            		tempList.add(pos);
	            			
	            		multiplePOScheck.put(key,tempList);
	            		System.debug(key+' --POS--> ' +pos);
	            	}
	            }
	           // System.debug('multiplePOScheck-->'+multiplePOScheck);
	            System.debug('unitToRsMap-->'+unitToRsMap);
	            Map<Id,Rent_Schedules__c> rsMap = new Map<Id,Rent_Schedules__c>();
	            Map<Id,Date> StDateCheckMap = new Map<Id,Date>();
	            Map<Id,Date> edDateCheckMap = new Map<Id,Date>();
	            
	            System.debug('trigger.New-->'+trigger.New);
	            for(POS_Transaction__c pt:trigger.New){
	            	System.debug('pt-->'+pt);
	            	if(!pt.Manual__c){
		                Boolean rsFound = false;
		                Boolean posFound = false;
		                System.debug('pt1-->'+pt); 

		                if(pt.POS_Id__c!=null && pt.From_Date__c!=null && pt.To_Date__c!=null){
		                	String keyForMap = '';
		                	Date posFromDT;
							Date posToDT;
		                    for(Lease_POS__c lp:leasePOSList){
		                    	System.debug('2nd-->'+(lp.Name==pt.POS_Id__c && pt.From_Date__c>=lp.Start_date__c && pt.From_Date__c<=lp.End_Date__c));
		                        if(lp.Name==pt.POS_Id__c && pt.From_Date__c>=lp.Start_date__c && pt.From_Date__c<=lp.End_Date__c){
		                            pt.Lease_POS__c = lp.Id;
		                            pt.Lease_Unit__c = lp.Lease_Unit__c;
		                            pt.Property__c = lp.Lease_Unit__r.Lease_Agreement_No__r.Property__c;
		                            System.debug('3rd-->'+unitToRsMap.containsKey(lp.Lease_Unit__c));
		                            if(unitToRsMap.containsKey(lp.Lease_Unit__c)){
		                                for(Rent_Schedules__c rs:unitToRsMap.get(lp.Lease_Unit__c)){
		                                	System.debug('rs.Id-->'+rs.Id); 
		                                	System.debug('ptrrr-->'+pt); 
		                                    if(pt.From_Date__c >= rs.Start_Date__c && pt.To_Date__c <= rs.End_Date__c){ 
		                                        keyForMap = (rs.Id+'-'+pt.POS_Id__c).replace(' ', '@');
		                                        System.debug('keyForMap-->'+keyForMap); 
		                                        if(multiplePOScheck.containsKey(keyForMap)){
		                                        	for(POS_Transaction__c posTrans: multiplePOScheck.get(keyForMap)){
		                                        		posFromDT = posTrans.From_Date__c;
								                        posToDT = posTrans.To_Date__c;
								                        system.debug('posFromDT ==> ' + posFromDT);
		                        						system.debug('posToDT ==> ' + posToDT);
		                        						system.debug('posToDT ==> ' + posToDT);
		                        						system.debug('posFromDT <= pt.To_Date__c  ==> ' + (posFromDT <= pt.To_Date__c));
		                        						system.debug('pt.From_Date__c <= posToDT  ==> ' + (pt.From_Date__c <= posToDT));
														if(posFromDT <= pt.To_Date__c && pt.From_Date__c <= posToDT){
															posFound = true;
				                                			break;
														}
		                                        	}
	                                        	}
												if(!posFound){
													//System.debug('rs.Id-->'+rs.Id); 
		                                			System.debug('pt true-->'+pt); 
		                                        	pt.Rent_Schedule__c = rs.Id;
		                                            if(StDateCheckMap.containsKey(rs.Id)){
		                                                if(StDateCheckMap.get(rs.Id) > pt.From_Date__c){
		                                                    rs.Transaction_Start_Date__c = pt.From_Date__c;
		                                                    StDateCheckMap.put(rs.Id,rs.Transaction_Start_Date__c);
		                                                }
		                                            }else{
		                                                rs.Transaction_Start_Date__c = pt.From_Date__c;
		                                                StDateCheckMap.put(rs.Id,rs.Transaction_Start_Date__c);
		                                            }
		                                            if(edDateCheckMap.containsKey(rs.Id)){
		                                                if(edDateCheckMap.get(rs.Id) < pt.To_Date__c){
		                                                    rs.Transaction_End_Date__c = pt.To_Date__c;
		                                                    edDateCheckMap.put(rs.Id,rs.Transaction_End_Date__c);
		                                                }
		                                            }else{
		                                                rs.Transaction_End_Date__c = pt.To_Date__c;
		                                                edDateCheckMap.put(rs.Id,rs.Transaction_End_Date__c);
		                                            }
		                                            rs.Transaction_Status__c = 'Applicable - Imported';
		                                            rsMap.put(rs.Id,rs);
			                                        rsFound = true;
			                                        
			                                        List<POS_Transaction__c> tempList = new List<POS_Transaction__c>();
								            		if(multiplePOScheck.containsKey((rs.Id+'-'+pt.POS_Id__c).replace(' ', '@')))
								            			tempList = multiplePOScheck.get((rs.Id+'-'+pt.POS_Id__c).replace(' ', '@'));
								            		tempList.add(pt);
			                                        multiplePOScheck.put((rs.Id+'-'+pt.POS_Id__c).replace(' ', '@'),tempList);
			                                        
			                                        break;
			                                	}
		                                        
		                                    }
		                                }
		                            }
		                        } 
		                    }
		                    
		                }
		                System.debug('rsFound-->'+rsFound);
		                System.debug('posFound-->'+posFound);
		                
		                //if(!rsFound ){
		                	if(pt.POS_Id__c==null && !pt.Manual__c){
					        	pt.addError('POS ID is required.');
					        }else if(pt.To_Date__c == null ||  pt.From_Date__c == null){
		                		pt.addError('From Date and To Date is required.');
		                	}else if(pt.To_Date__c < pt.From_Date__c ){
		                		pt.addError('From Date must be before To Date.');
		                	}else if(!LeasePOSmap.containsKey(pt.POS_Id__c) && !pt.Manual__c){
					            pt.addError('POS ID not found.');
					        }
					        if(pt.Rent_Schedule__c == null){
				            	pt.addError('No Rent Schedule found in between From Date and To Date.');
				            }
			            //}
		            	if(posFound){
		                	pt.addError('POS Transaction for identified Rent Schedule already exist.');
		                }
			            
			        }
	            }
	            if(rsMap!= null){
	                update rsMap.values();
	            }
		    }
		}
	}
	if(Trigger.isAfter){
		System.debug('---After Insert---');
		List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Applicable_Function__c='Finance' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
	    Map<String,Decimal> exchRateMap= new Map<String,Decimal>();
	    for(Exchange_Rate__c er:exchangeRateList){ 
	        if(er.Currency_Code__c!=label.Default_Currency){
	            exchRateMap.put(er.Currency_Code__c,er.Conversion_Rate__c);
	            break;
	        }
	    }
	    System.debug('trigger.newMap.keySet()-->'+trigger.newMap.keySet());
	    List<POS_Transaction__c> posList = [select Id, Rent_Schedule__c, Rent_Schedule__r.Currency_Code__c,Rent_Schedule__r.Exchange_Rate__c  from POS_Transaction__c where Id =: trigger.newMap.keySet()];
		List<Rent_Schedules__c> rsList = new List<Rent_Schedules__c>();
		Set<Id> doubleRS = new Set<Id>();
		for(POS_Transaction__c pos:posList){
			System.debug('pos.Id-->'+pos.Id);
			System.debug('pos.Rent_Schedule__r.Currency_Code__c-->'+pos.Rent_Schedule__r.Currency_Code__c);
			System.debug('pos.Rent_Schedule__r.Exchange_Rate__c-->'+pos.Rent_Schedule__r.Exchange_Rate__c);
			if(pos.Rent_Schedule__c !=null && !doubleRS.contains(pos.Rent_Schedule__c)){
				doubleRS.add(pos.Rent_Schedule__c);
				Rent_Schedules__c tempRS = new Rent_Schedules__c();
				tempRS.Id = pos.Rent_Schedule__c;
				if(pos.Rent_Schedule__r.Currency_Code__c != label.Default_Currency && pos.Rent_Schedule__r.Currency_Code__c != null && exchRateMap.containsKey(pos.Rent_Schedule__r.Currency_Code__c)){
		        	tempRS.Exchange_Rate__c = exchRateMap.get(pos.Rent_Schedule__r.Currency_Code__c);
		        }else if(pos.Rent_Schedule__r.Currency_Code__c == label.Default_Currency ){
		        	tempRS.Exchange_Rate__c = 1;
		        }
		        rsList.add(tempRS);
			}
		}
		 System.debug('rsList-->'+rsList);
		if(rsList.size()>0){
			update rsList;
		}
	}
}