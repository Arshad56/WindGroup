/*
*	Developer Name: Nicholas See
*	Email: nicholas.see@wind.com.sg/nicholassee8@gmail.com
*	Date: Aug-4-2017
*	Description: To compute Estimate GTO Rent based on different GTO Billed types, 
*	'By Lease Unit', 'By Lease (Lease Unit)', 'By Lease (Summary)'.
*	In the process, populates the following fields in Rent_Schedules__c, 
*	Estimated_GTO_Amount__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c
*/
public class EstimatedGTO {
	// constant variables for Base Rent Charge Type
	private static final String BRCHARGETYPE = 'Advance Rental';
	
	// constant variables for GTO Billed field in Lease__c
	private static final String GTOBYLEASEUNIT = 'By Lease Unit';
	private static final String GTOBYLEASELEASEUNIT = 'By Lease (Lease Unit)';
	private static final String GTOBYLEASESUMMARY = 'By Lease (Summary)';
	
	// Constant variables for Charge Type field in Rent_Schedules__c
	private static final String GTOCHARGETYPE = 'GTO Rent';
	
	// Constant variables for Type field in Lease_Charge__c
	private static final String GTOHIGHERTYPE = 'GTO (Higher)';
	private static final String GTOTYPE = 'GTO';
	private static final String GTOSUMTYPE = 'GTO (Sum)';
	
	// Constant variables for Currency Code
	private static final String MMKCURRENCYCODE = Label.Default_Currency;
	private static final String USDCURRENCYCODE = Label.Base_Foreign_Currency;
	
    decimal totalCapAmount;
    
    Map<Id, Rent_Schedules__c> rsToUpdate = new Map<Id, Rent_Schedules__c>();
    
    Set<Id> setOfProcessedRs = new Set<Id>();
	
	public EstimatedGTO(boolean triggerBeforeFlag ,Map<Id, Rent_Schedules__c> rsFrmTrigger, Map<Id, Rent_Schedules__c> gtoRS, Map<Id, List<Rent_Schedules__c>> gtoRsByLease, Set<Id> leaseIds, Date startDate, Date endDate){
		// compute total converted base rent base of each lease unit related to RS from trigger and group by master rs Id
		Map<Id, LeaseRSList> leaseRelatedRs = ComputeLeaseTotalConvertedBaseRent(rsFrmTrigger, gtoRS, leaseIds, startDate, endDate);
		
		for(Rent_Schedules__c masterRs : rsFrmTrigger.values()){			
			if(!triggerBeforeFlag && masterRs.Charge_Type__c != null && masterRs.Charge_Type__c.equals(GTOCHARGETYPE) && gtoRS != null 
			&& gtoRS.get(masterRs.Id) != null && gtoRsByLease.get(gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.Id) != null 
			&& gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c != null
			&& masterRs.Total_Estimated_GTO_Converted__c > 0
			&& (gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c.equals(GTOBYLEASESUMMARY) || gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c.equals(GTOBYLEASELEASEUNIT))){
				LeaseRSList currentRsList = new LeaseRSList();
				currentRsList = leaseRelatedRs.get(masterRs.Id);
				// if currentRsList is not null and current masterRs has not been updated under related Gto rs, proceed to compute
				if(currentRsList != null && !setOfProcessedRs.contains(masterRs.Id)){
					
					// store current master rs as processed rs to prevent overwriting in 'After' trigger
					setOfProcessedRs.add(masterRs.Id);
					
					List<Rent_Schedules__c> relatedLuGtoRs = gtoRsByLease.get(gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.Id);
					// filter all gto rs under a lease to retrieve only those that falls within the masterRs start and end date
	
					for(Rent_Schedules__c indivLuGtoRs : relatedLuGtoRs){
						// retrieve gto rs that shares the same lease agreement number as masterRs and period of rs falls within the masterRs start and end date
						if(indivLuGtoRs.Start_Date__c <= masterRs.End_Date__c && indivLuGtoRs.End_Date__c >= masterRs.Start_Date__c){
							// add valid gto rs to current LeaseRSList object
							currentRsList.addGtoRs(indivLuGtoRs);
							setOfProcessedRs.add(indivLuGtoRs.Id);
						}
					}				
					
					// Store all base rent of related lease unit and tabulate total converted base rent for a lease
					if(gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c.equals(GTOBYLEASESUMMARY)){
						ComputeByLeaseSummary(masterRs, gtoRS.get(masterRs.Id), currentRsList.getTotalConvertedBaseRent(), currentRsList.getLeaseTotalNLA());
					}
					else{
						ComputeByLease_LeaseUnit(masterRs, gtoRS.get(masterRs.Id), currentRsList.getTotalConvertedBaseRent(), currentRsList);
					}
				}
			}
			else if(triggerBeforeFlag && masterRs.Charge_Type__c != null && masterRs.Charge_Type__c.equals(GTOCHARGETYPE) 
			&& gtoRS != null && gtoRS.get(masterRs.Id) != null && gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c != null
			&& gtoRS.get(masterRs.Id).Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c.equals(GTOBYLEASEUNIT)){
				// TODO
				ComputeByLeaseUnit(masterRs, gtoRS.get(masterRs.Id));
			}
		}
		
		// update all impacted gto RS
		update rsToUpdate.values();
	}
    
    /*
    *	Function that retrieves all base rent and compute total converted base rent amount for each lease unit if the base rent period exist within the GTO RS period
    *
    *	Returns a map contain lease unit Id and corresponding converted base rent amount. 
    */
    
    private Map<Id, LeaseRSList> ComputeLeaseTotalConvertedBaseRent(Map<Id, Rent_Schedules__c> gtoRS, Map<Id, Rent_Schedules__c> gtoRSAddInfo, Set<Id> leaseIds, Date startDate, Date endDate){
    	
    	// variable to store total base rent by Lease unit id
    	Map<Id, decimal> leaseUnitTotalBRMap = new Map<Id, decimal>();
    	
    	Map<Id, LeaseRSList> leaseRelatedRs = new Map<Id, LeaseRSList>();
    	
    	// Retrieve base rent RS under the same lease with Charge Type 'Advance Rental' and base rent RS period must be within the gto rs start and end date
    	//Map<Id, Rent_Schedules__c> baseRentRS = new Map<Id, Rent_Schedules__c>([SELECT id,Start_Date__c,End_Date__c,
    	//Amount__c,Amount_Local__c,Amount_Foreign__c, Calculated_Amount_Foreign__c, Calculated_Amount_Local__c, Lease_Unit__r.Id, Lease_Unit__r.Lease_Agreement_No__r.Id, Unit__r.NLA_SQF__c FROM Rent_Schedules__c
    	//WHERE Lease_Unit__r.Lease_Agreement_No__r.Id IN : leaseIds
    	//AND Charge_Type__c = : BRCHARGETYPE 
    	//AND Start_Date__c <= : endDate 
    	//AND End_Date__c >= : startDate ORDER BY Start_Date__c ASC]);
    	Map<Id, Rent_Schedules__c> baseRentRS = RSTrigger_Helper.retrieveBaseRentRsByLeaseId(leaseIds, startDate, endDate);
    	
    	// Group RS by Lease Unit to cater stagger rents
    	Map<Id, Set<Rent_Schedules__c>> luMap = new Map<Id, Set<Rent_Schedules__c>>();
    	for (Rent_Schedules__c gtoRsFrmTrigger: gtoRS.values()){
    		for (Rent_Schedules__c rs : baseRentRS.values()){
    			// only add to map if base rent rs is covers the GTO RS start and end date period.
    			if(rs.Start_Date__c <= gtoRsFrmTrigger.End_Date__c && rs.End_Date__c >= gtoRsFrmTrigger.Start_Date__c){
				    if(luMap.containsKey(rs.Lease_Unit__r.Id)){
				        Set<Rent_Schedules__c> tempRSList = luMap.get(rs.Lease_Unit__r.Id);
				        tempRSList.add(rs);
				        luMap.put(rs.Lease_Unit__r.Id, tempRSList);
				    }else{
				        luMap.put(rs.Lease_Unit__r.Id, new Set<Rent_Schedules__c> {rs});
				    }
    			}
			}
    	}
		
		for(Rent_Schedules__c gtoRsFrmTrigger: gtoRSAddInfo.values()){
			if(luMap.size()>0){
				LeaseRSList leaseRSList = new LeaseRSList();
				leaseRSList.setMasterGtoRsId(gtoRsFrmTrigger.Id);
				for(Id currentLuId : luMap.keySet()){
					// to store related base rent rs of current lease unit
					Map<Id, Rent_Schedules__c> luBrRsMap = new Map<Id, Rent_Schedules__c>();
					Id br_1_Id = null;
					Id br_2_Id = null;
					decimal convertedBrAmount = 0;
					for (Rent_Schedules__c individualRS : luMap.get(currentLuId)){
						// only compute if base rent RS is under the same lease as gto rs and overlaps gto rs period
						if(individualRS.Lease_Unit__r.Lease_Agreement_No__r.Id.equals(gtoRsFrmTrigger.Lease_Unit__r.Lease_Agreement_No__r.Id) 
						&& individualRS.Start_Date__c <= gtoRsFrmTrigger.End_Date__c
						&& individualRS.End_Date__c >= gtoRsFrmTrigger.Start_Date__c){
							
							if(br_1_Id == null){
								br_1_Id = individualRS.Id;
								luBrRsMap.put(individualRS.Id, individualRS);
							}
							else{
								br_2_Id = individualRS.Id;
								luBrRsMap.put(individualRS.Id, individualRS);
							}
						}
						if(luBrRsMap.size()>0){
							convertedBrAmount = RSTrigger_Helper.doBRcalculation(gtoRsFrmTrigger, br_1_Id, br_2_Id ,luBrRsMap);
						}
						leaseRSList.setLeaseUnitTotalBRMap(individualRS.Lease_Unit__r.Id, convertedBrAmount);
						leaseRSList.setleaseUnitTotalNLAMap(individualRS.Lease_Unit__r.Id, individualRS.Unit__r.NLA_SQF__c);
					}
				}
				// compute base rent for this lease
				leaseRSList.computeLeaseTotalBr();
				leaseRelatedRs.put(leaseRSList.getMasterGtoRsId(), leaseRSList);
			}
		}
    	return leaseRelatedRs;
    }
    
    /*
    *	Function to compute Estimated GTO Rent when GTO Billed is By Lease (Summary)
    *	the following fields in Rent_Schedules__c Object, 
	*	Estimated_GTO_Amount__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c 
    */
    private void ComputeByLeaseSummary(Rent_Schedules__c rs, Rent_Schedules__c rsAddInfo, decimal totalConvertedBaseRent, decimal totalLeaseNLA){
    	
    	// Calculate By Lease Summary
    	decimal capValue = 0;
		decimal capAmount = 0;
		decimal oldEstimatedGtoRent = null;
		//decimal oldEstimatedGtoAmt = null;
		if(rsAddInfo.Estimated_GTO_Rent__c != null){
			oldEstimatedGtoRent = rsAddInfo.Estimated_GTO_Rent__c;
		}
		
    	// compute Estimated_GTO_Amount__c field of gto rs
    	rsAddInfo.Total_Estimated_GTO__c = rs.Total_Estimated_GTO__c;
    	rsAddInfo.Estimated_GTO_Amount__c = ComputeEstGTOAmount(rs, rsAddInfo);
    	
    	// if Cap value exists and cap value greater than 0, set flag to perform cap amount comparison
        if (rs.Cap_Value__c != null && rs.Cap_Value__c > 0) {
            capValue = rs.Cap_Value__c;
        }else {
        	capValue = 0;
        }
        
        // Compute gross rent. If SUM case, est gross rent = est gto amt + base rent
        rsAddInfo.Estimated_Gross_Rent__c = ComputeEstGrossRent(rsAddInfo.Lease_Charge__r.Type__c, rsAddInfo.Estimated_GTO_Amount__c, totalConvertedBaseRent);
        
        // compute gross rent (cap) if cap is applicable, other gross rent (cap) = gross rent
        if(rsAddInfo.Unit__r.NLA_SQF__c != null){
        	////getLeaseTotalNLA
        	//capAmount = capValue * (rs.Calc_No_of_Days_Pro_Rated_2__c/100) * rsAddInfo.Unit__r.NLA_SQF__c;
        	capAmount = capValue * (rs.Calc_No_of_Days_Pro_Rated_2__c/100) * totalLeaseNLA;
      		// if gross rent is less than cap amount or there is no cap, gross rent (cap) = gross rent. Else gross rent (cap) = cap amount
      		if(rs.Cap_Value__c == null || capAmount <= 0 || rsAddInfo.Estimated_Gross_Rent__c <= capAmount){
      			rsAddInfo.Estimated_Gross_Rent_Cap__c = rsAddInfo.Estimated_Gross_Rent__c;
      		}else{
      			rsAddInfo.Estimated_Gross_Rent_Cap__c = capAmount;
      		}
        }else{
        	rsAddInfo.Estimated_Gross_Rent_Cap__c = 0;
        }
        
        // Compute final GTO rent amount
        if(rsAddInfo.Lease_Charge__r.Type__c.equals(GTOSUMTYPE) || rsAddInfo.Lease_Charge__r.Type__c.equals(GTOHIGHERTYPE)){
        	if(rsAddInfo.Estimated_Gross_Rent_Cap__c > totalConvertedBaseRent){
        		rsAddInfo.Estimated_GTO_Rent__c = rsAddInfo.Estimated_Gross_Rent_Cap__c - totalConvertedBaseRent;
        	} else{
        		rsAddInfo.Estimated_GTO_Rent__c = 0;
        	}
        } else {
        	rsAddInfo.Estimated_GTO_Rent__c = rsAddInfo.Estimated_Gross_Rent_Cap__c;
        }
    	//update rsAddInfo;
    	if(oldEstimatedGtoRent != rsAddInfo.Estimated_GTO_Rent__c){
    		rsToUpdate.put(rsAddInfo.Id, rsAddInfo);
    	}
    }

    /*
    *	Function to compute Estimated GTO Rent when GTO Billed is By Lease (Summary)
    *	the following fields in Rent_Schedules__c Object, 
	*	Estimated_GTO_Amount__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c 
    *	@param	rs			Rent Schedule Object from trigger. Contains all fields excluding relation lookup fields
    *	@param	rsAddInfo	Rent Schedule Object containing required relation lookup fields of Rent Schedule from trigger
    *	@return				Populate rs with values in Estimated_GTO_Amount__c, Estimated_Gross_Rent__c, Estimated_Gross_Rent_Cap__c, Estimated_GTO_Rent__c
    */
    private void ComputeByLease_LeaseUnit(Rent_Schedules__c rs, Rent_Schedules__c rsAddInfo, decimal totalConvertedBaseRent, LeaseRSList leaseRSList){
    	
    	// Calculate By Lease Summary
    	decimal capValue;
		decimal capAmount = 0;
    	decimal oldEstimatedGtoRent = null;
    	//decimal oldEstimatedGtoAmt = null;
		if(rsAddInfo.Estimated_GTO_Rent__c != null){
			oldEstimatedGtoRent = rsAddInfo.Estimated_GTO_Rent__c;
		}

    	// compute Estimated_GTO_Amount__c field of gto rs
    	rsAddInfo.Estimated_GTO_Amount__c = ComputeEstGTOAmount(rs, rsAddInfo);
        
        for(Rent_Schedules__c relatedLuGtoRs : leaseRSList.getLeaseRelatedGtoRs().values()){
    		// if Cap value exists and cap value greater than 0, set flag to perform cap amount comparison
    		capValue = 0;
	    	if (relatedLuGtoRs.Cap_Value__c != null && relatedLuGtoRs.Cap_Value__c > 0) {
	            capValue = relatedLuGtoRs.Cap_Value__c;
	        }
    		
    		if(relatedLuGtoRs.Unit__r.NLA_SQF__c != null){
	        	capAmount += capValue * (rs.Calc_No_of_Days_Pro_Rated_2__c/100) * relatedLuGtoRs.Unit__r.NLA_SQF__c;
	      		// if gross rent is less than cap amount or there is no cap, gross rent (cap) = gross rent. Else gross rent (cap) = cap amount
	        }
    		
    	}       
         // Compute gross rent. If SUM case, est gross rent = est gto amt + base rent
        rsAddInfo.Estimated_Gross_Rent__c = ComputeEstGrossRent(rsAddInfo.Lease_Charge__r.Type__c, rsAddInfo.Estimated_GTO_Amount__c, totalConvertedBaseRent);
    	// Compute gross rent. If SUM case, est gross rent = est gto amt + base rent
    	if(rsAddInfo.Unit__r.NLA_SQF__c != null){
      		// if gross rent is less than cap amount or there is no cap, gross rent (cap) = gross rent. Else gross rent (cap) = cap amount
      		if(rs.Cap_Value__c == null || capAmount <= 0 || rsAddInfo.Estimated_Gross_Rent__c <= capAmount){
      			rsAddInfo.Estimated_Gross_Rent_Cap__c = rsAddInfo.Estimated_Gross_Rent__c;
      		}else{
      			rsAddInfo.Estimated_Gross_Rent_Cap__c = capAmount;
      		}
        }else{
        	rsAddInfo.Estimated_Gross_Rent_Cap__c = 0;
        }
    	decimal leaseTotalGtoRent = 0;
    	// Compute final GTO rent amount
    	if(rsAddInfo.Lease_Charge__r.Type__c.equals(GTOSUMTYPE) || rsAddInfo.Lease_Charge__r.Type__c.equals(GTOHIGHERTYPE)){
    		// get base rent of GTO rs
    		decimal masterRsBr = leaseRSList.getLeaseUnitTotalBRMap(rsAddInfo.Lease_Unit__r.Id);
    		
        	if(rsAddInfo.Estimated_Gross_Rent_Cap__c > totalConvertedBaseRent){
        		leaseTotalGtoRent = rsAddInfo.Estimated_Gross_Rent_Cap__c - totalConvertedBaseRent;
        		if(leaseRSList.getTotalConvertedBaseRent() > 0){
        			rsAddInfo.Estimated_GTO_Rent__c = ((masterRsBr/leaseRSList.getTotalConvertedBaseRent()).setScale(4) * leaseTotalGtoRent).setScale(2);
        		}
        		else{
        			rsAddInfo.Estimated_GTO_Rent__c = 0;
        		}
        	} else{
        		rsAddInfo.Estimated_GTO_Rent__c = 0;
        	}
        } else {
        	// future case, not relevant now
        	rsAddInfo.Estimated_GTO_Rent__c = rsAddInfo.Estimated_Gross_Rent_Cap__c;
        }
        if(oldEstimatedGtoRent != rsAddInfo.Estimated_GTO_Rent__c){
        	rsToUpdate.put(rsAddInfo.Id, rsAddInfo);
        }
    	// Split final GTO according to weightage of base rent and populate back to relevant GTO RS
    	for(Rent_Schedules__c relatedLuGtoRs : leaseRSList.getLeaseRelatedGtoRs().values()){
    		// get base rent of GTO rs
    		decimal leaseUnitBr = leaseRSList.getLeaseUnitTotalBRMap(relatedLuGtoRs.Lease_Unit__r.Id);
    		
			if(relatedLuGtoRs.Estimated_GTO_Rent__c != null){
				oldEstimatedGtoRent = relatedLuGtoRs.Estimated_GTO_Rent__c;
			}
    		relatedLuGtoRs.Estimated_GTO_Amount__c = rsAddInfo.Estimated_GTO_Amount__c;
    		relatedLuGtoRs.Estimated_Gross_Rent__c = rsAddInfo.Estimated_Gross_Rent__c;
    		relatedLuGtoRs.Estimated_Gross_Rent_Cap__c = rsAddInfo.Estimated_Gross_Rent_Cap__c;
    		if(leaseRSList.getTotalConvertedBaseRent() == 0 && !relatedLuGtoRs.Id.equals(rs.Id)){
    			relatedLuGtoRs.Estimated_GTO_Rent__c = 0;
				if(oldEstimatedGtoRent != relatedLuGtoRs.Estimated_GTO_Rent__c){
		        	rsToUpdate.put(relatedLuGtoRs.Id, relatedLuGtoRs);
		        }
    			//rsToUpdate.put(relatedLuGtoRs.Id, relatedLuGtoRs);
    		}
    		else if (!relatedLuGtoRs.Id.equals(rs.Id)){
    			relatedLuGtoRs.Estimated_GTO_Rent__c = ((leaseUnitBr/leaseRSList.getTotalConvertedBaseRent()).setScale(4) * leaseTotalGtoRent).setScale(2);
				if(oldEstimatedGtoRent != relatedLuGtoRs.Estimated_GTO_Rent__c){
		        	rsToUpdate.put(relatedLuGtoRs.Id, relatedLuGtoRs);
		        }
    			//rsToUpdate.put(relatedLuGtoRs.Id, relatedLuGtoRs);
    		}
    		
    	}
    	
    	//rsToUpdate.put(rsAddInfo.Id, rsAddInfo);
    }
    
    /*
    *	Function to compute EstGTOAmount for all GTO Billed types
    *	
    *
    */
    private static decimal ComputeEstGTOAmount (Rent_Schedules__c rs, Rent_Schedules__c rsAddInfo){
    	// calculate GTO base on tier and cummulative formula
    	decimal estimatedGtoAmount;
    	if (rs.Total_Estimated_GTO_Converted__c != null &&  rsAddInfo.Lease_Charge__r.Charge_Rate__c != null && !rs.Tiered__c) {
    		estimatedGtoAmount = rs.Total_Estimated_GTO_Converted__c * rsAddInfo.Lease_Charge__r.Charge_Rate__c / 100.00;  
        } else if(rs.Est_Calc_Cumulative_Tiered__c != null && rs.Tiered__c && rs.Cumulative__c) {
            estimatedGtoAmount = rs.Est_Calc_Cumulative_Tiered__c;
        } else if(rs.Est_Calc_Non_Cumulative_Tiered__c != null && rs.Tiered__c && !rs.Cumulative__c){
            estimatedGtoAmount = rs.Est_Calc_Non_Cumulative_Tiered__c;
        } else{
        	estimatedGtoAmount = 0;
        }
        return estimatedGtoAmount.setScale(2);
    }
    
    /*
    *	Function to compute Estimated GTO Gross Rent for all GTO type
    *
    *
    */
    private decimal ComputeEstGrossRent(String gtoType, decimal estimatedGTOAmt, decimal totalConvertedBaseRent){
    	// Compute gross rent. If SUM case, est gross rent = est gto amt + base rent
    	// If Higher case, est gross rent = whichever that is higher(est gto amt, total converted base rent)
        if (gtoType.equals(GTOSUMTYPE)) {
            return estimatedGTOAmt + totalConvertedBaseRent;
        } else if(gtoType.equals(GTOHIGHERTYPE)){
        	if(estimatedGTOAmt > totalConvertedBaseRent){
        		return estimatedGTOAmt;
        	} else{
        		return totalConvertedBaseRent;
        	}
        } else if(gtoType.equals(GTOTYPE)){
        	return estimatedGTOAmt;
        } else{
        	return 0;
        }
    }

	private void ComputeByLeaseUnit(Rent_Schedules__c rsFrmTrigger, Rent_Schedules__c rsAddInfo){
		decimal capValue = 0;
		decimal capAmount = 0;
        decimal baseRentCal = 0;
        
        // Logic to run for GTO billed type By Lease unit and populate estimated GTO amount
    	// calculate GTO base on tier and cummulative formula
        rsFrmTrigger.Estimated_GTO_Amount__c = ComputeEstGTOAmount(rsFrmTrigger, rsAddInfo);
        
        // if Cap value exists and cap value greater than 0, set flag to perform cap amount comparison
        if (rsFrmTrigger.Cap_Value__c != null && rsFrmTrigger.Cap_Value__c > 0) {
            capValue = rsFrmTrigger.Cap_Value__c;
        }else {
        	capValue = 0;
        }
        
        // check for null in event where Base Rent RS is not generated
        if (rsFrmTrigger.Converted_Base_Rent__c == null) {
            baseRentCal = 0;
        } else {
            baseRentCal = rsFrmTrigger.Converted_Base_Rent__c;
        }
        
        // Compute gross rent. If SUM case, est gross rent = est gto amt + base rent
        
        rsFrmTrigger.Estimated_Gross_Rent__c = ComputeEstGrossRent(rsAddInfo.Lease_Charge__r.Type__c, rsFrmTrigger.Estimated_GTO_Amount__c, baseRentcal);
        
        // compute gross rent (cap) if cap is applicable, other gross rent (cap) = gross rent
        if(rsAddInfo.Unit__r.NLA_SQF__c != null){
        	capAmount = capValue * (rsFrmTrigger.Calc_No_of_Days_Pro_Rated_2__c/100) * rsAddInfo.Unit__r.NLA_SQF__c;
      		// if gross rent is less than cap amount or there is no cap, gross rent (cap) = gross rent. Else gross rent (cap) = cap amount
      		if(rsFrmTrigger.Cap_Value__c == null || capAmount <= 0 || rsFrmTrigger.Estimated_Gross_Rent__c <= capAmount){
      			rsFrmTrigger.Estimated_Gross_Rent_Cap__c = rsFrmTrigger.Estimated_Gross_Rent__c;
      		}else{
      			rsFrmTrigger.Estimated_Gross_Rent_Cap__c = capAmount;
      		}
        }else{
        	rsFrmTrigger.Estimated_Gross_Rent_Cap__c = 0;
        }
        
        // Compute final GTO rent amount
        if(rsAddInfo.Lease_Charge__r.Type__c.equals(GTOSUMTYPE) || rsAddInfo.Lease_Charge__r.Type__c.equals(GTOHIGHERTYPE)){
        	if(rsFrmTrigger.Estimated_Gross_Rent_Cap__c > baseRentCal){
        		rsFrmTrigger.Estimated_GTO_Rent__c = rsFrmTrigger.Estimated_Gross_Rent_Cap__c - baseRentCal;
        	} else{
        		rsFrmTrigger.Estimated_GTO_Rent__c = 0;
        	}
        } else {
        	rsFrmTrigger.Estimated_GTO_Rent__c = rsFrmTrigger.Estimated_Gross_Rent_Cap__c;
        }
        
	}
	private class LeaseRSList {
		decimal totalConvertedBaseRent;
		Id masterGtoRsId;
		// variable to store total base rent by Lease unit id
    	Map<Id, decimal> leaseUnitTotalBRMap = new Map<Id, decimal>();
    	
    	// variable to store total NLA by Lease unit id
    	Map<Id, decimal> leaseUnitTotalNLAMap = new Map<Id, decimal>();
    	
    	Map<Id, Rent_Schedules__c> leaseRelatedGtoRs = new Map<Id, Rent_Schedules__c>();
    	
    	//List<Rent_Schedules__c> leaseRelatedGtoRs = new List<Rent_Schedules__c>
		private LeaseRSList(){
			totalConvertedBaseRent = 0;
		}
		private void addTotalConvertedBaseRent(decimal convertedBaseRent){
			if(convertedBaseRent != null){
				totalConvertedBaseRent += convertedBaseRent;
			}
		}
		private void setMasterGtoRsId(ID leaseId){
			this.masterGtoRsId = leaseId;
		}
		private void setLeaseUnitTotalBRMap(Id leaseUnitId, decimal convertedBaseRent){
			this.leaseUnitTotalBRMap.put(leaseUnitId, convertedBaseRent);
		}
		private void setleaseUnitTotalNLAMap(Id leaseUnitId, decimal nla){
			this.leaseUnitTotalNLAMap.put(leaseUnitId, nla);
		}
		private void addGtoRs(Rent_Schedules__c rs){
			this.leaseRelatedGtoRs.put(rs.Id, rs);
		}
		private Map<Id, Rent_Schedules__c> getLeaseRelatedGtoRs(){
			return this.leaseRelatedGtoRs;
		}
		private decimal getTotalConvertedBaseRent(){
			return this.totalConvertedBaseRent;
		}
		private Id getMasterGtoRsId(){
			return this.masterGtoRsId;
		}
		private decimal getLeaseUnitTotalBRMap(Id leaseUnitId){
			return this.leaseUnitTotalBRMap.get(leaseUnitId);
		}
		private decimal getLeaseUnitTotalNLAMap(Id leaseUnitId){
			return this.leaseUnitTotalNLAMap.get(leaseUnitId);
		}
		private boolean leaseUnitTotalBRMapContainsKey(Id leaseUnitId){
			return this.leaseUnitTotalBRMap.containskey(leaseUnitId);
		}
		
		private decimal getLeaseTotalNLA(){
			decimal totalNLA = 0;
			for(decimal nla : this.leaseUnitTotalNLAMap.values()){
				totalNLA += nla;
			}
			return totalNLA;
		}
		
		private void computeLeaseTotalBr(){
			this.totalConvertedBaseRent = 0;
			for(decimal baseRentAmt : this.leaseUnitTotalBRMap.values()){
				if(baseRentAmt != null){
					this.totalConvertedBaseRent += baseRentAmt;
				}
			}
		}
	}
}