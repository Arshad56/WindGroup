public class RSTrigger_Helper {
    // Constant variables for Charge Type field in Rent_Schedules__c
    private static final String GTOCHARGETYPE = 'GTO Rent';
    
    public static Map<Id, Rent_Schedules__c> RSmap;
    
    public static Map<Id, Rent_Schedules__c> leaseRelatedGtoRsMap;
    
    // constant variables for Base Rent Charge Type
    private static final String BRCHARGETYPE = 'Advance Rental';
    
    /*
    *   Function to retrieve gto lookup relations' details base on rs Ids and returns
    *   map containing rent schedules.
    *   @param      rsIds       set of rs Ids to retrieve details
    *   @return     gtoRS       Map containing rs details
    */
    public static Map<Id, Rent_Schedules__c> retrieveGtoRsDetailsByRsId(Set<Id> rsIds){
        // Query to retrieve  lease agreement and lease charge terms of RS based on lookup relationships
        Map<Id, Rent_Schedules__c> gtoRs = new Map<Id, Rent_Schedules__c>();
        if(rsIds!=null && rsIds.size()>0){
            gtoRs = new Map<Id, Rent_Schedules__c>([SELECT Id,Unit__c,Converted_Base_Rent__c,Tiered__c,GTO_Monthly_Total_Converted__c,GTO_Amount1__c, Start_Date__c, End_Date__c, Currency_Code__c, Estimated_GTO_Rent__c, Lease_Charge__r.Id, Lease_Unit__r.Id, 
            Lease_Unit__r.Lease_Agreement_No__r.Id, Lease_Unit__r.Lease_Agreement_No__r.Name, Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c,
            Lease_Charge__r.Charge_Rate__c, Lease_Charge__r.Type__c, Lease_Charge__r.Billing_Terms__c, Lease_Charge__r.Billing_Frequency__c,
            Lease_Charge__r.End_Date__c, Lease_Charge__r.Charge_Type__c, Unit__r.Id, Unit__r.Charge_Method__c, Unit__r.NLA_SQF__c 
            FROM Rent_Schedules__c WHERE Id IN : rsIds]);
            System.debug('<-- retrieveGtoRsDetailsByRsId -->');
        }
        return gtoRs;
    }
    
    /*
    *   Function to receive set of lease Ids, start date and end date to retrieve GTO Rent charge type rent schedules that belongs the lease
    *   and falls within the start and end date.
    *   @param      leaseIds                set of lease Ids to retrieve related GTO Rs
    *   @param      startDate               start date to retrieve GTO Rs
    *   @param      endDate                 end date to retrieve GTO Rs
    *   @return     leaseRelatedGtoRs       Map containing GTO Rs that is under leases that were received
    */
    public static Map<Id, Rent_Schedules__c> retrieveLeaseRelatedGtoRsByLeaseId(Set<Id> leaseIds, Date startDate, Date endDate){
        // Retrieve gto rs under the same lease with Charge Type 'GTO Rent' and RS period must be within triggered rs's start and end date
        Map<Id, Rent_Schedules__c> leaseRelatedGtoRs = new Map<Id, Rent_Schedules__c>();
        if(leaseIds!=null && leaseIds.size()>0){
            leaseRelatedGtoRs = new Map<Id, Rent_Schedules__c>([Select Id,Tiered__c,Transaction_Status__c, Estimated_GTO_Rent__c, Estimated_GTO_Amount__c, Est_Calc_Non_Cumulative_Tiered__c, 
                Est_Calc_Cumulative_Tiered__c, Cap_Value__c, Leap_Year__c, Unit__r.NLA_SQF__c, Cap_Amount__c,GTO_Rent_By_Lease__c,Cumulative__c,Currency_Code__c,
                Start_Date__c, End_Date__c, Lease_Unit__r.Id, Lease_Unit__r.Lease_Agreement_No__r.GTO_Billed__c, Lease_Unit__r.Lease_Agreement_No__r.Id, Lease_Charge__r.Charge_Rate__c 
                FROM Rent_Schedules__c 
                WHERE Charge_Type__c = : GTOCHARGETYPE
                AND Start_Date__c <= : endDate
                AND End_Date__c >= : startDate
                AND Lease_Unit__r.Lease_Agreement_No__r.Id IN : leaseIds]);
        }
        return leaseRelatedGtoRs;
    }
    
    /*
    *   Function to receive set of lease Ids, start date and end date to retrieve Advance Rental charge type rent schedules that belongs the lease
    *   and falls within the start and end date.
    *   @param      leaseIds                set of rs Ids to retrieve details
    *   @param      startDate               start date to retrieve GTO Rs
    *   @param      endDate                 end date to retrieve GTO Rs
    *   @return     baseRentRs              Map containing base rent rs details
    */
    public static Map<Id, Rent_Schedules__c> retrieveBaseRentRsByLeaseId(Set<Id> leaseIds, Date startDate, Date endDate){
        // Retrieve base rent RS under the same lease with Charge Type 'Advance Rental' and base rent RS period must be within the gto rs start and end date
        Map<Id, Rent_Schedules__c> baseRentRs = new Map<Id, Rent_Schedules__c>();
        if(leaseIds!=null && leaseIds.size()>0){
            baseRentRs = new Map<Id, Rent_Schedules__c>([SELECT id,Start_Date__c,End_Date__c,
            Amount__c,Amount_Local__c,Amount_Foreign__c, Calculated_Amount_Foreign__c, Calculated_Amount_Local__c, Lease_Unit__r.Id, Lease_Unit__r.Lease_Agreement_No__r.Id, Unit__r.NLA_SQF__c FROM Rent_Schedules__c
            WHERE Lease_Unit__r.Lease_Agreement_No__r.Id IN : leaseIds
            AND Charge_Type__c = : BRCHARGETYPE 
            AND Start_Date__c <= : endDate 
            AND End_Date__c >= : startDate ORDER BY Start_Date__c ASC]);
        }
        
        return baseRentRs;
    }
    
        
    /*
    *   When Parent RS Amount__c is updated. Updates all Child RS Amount__c.
    *
    */
    public static void discountChildRSAmtUpdate(list<Rent_Schedules__c> triggerNew, Map<Id,Rent_Schedules__c> oldMap){
        Utility.doDiscount = false;
        Set<Id> rsIds = new Set<Id>();
        for(Rent_Schedules__c rs:triggerNew){
            if(rs.Amount__c!=oldMap.get(rs.Id).Amount__c){
                rsIds.add(rs.Id);
            }
        }
        System.debug('rsIds-->'+rsIds);
        if(rsIds.size()>0){
            Map<Id,List<Rent_Schedules__c>> parentToChildRSMap = new Map<Id,List<Rent_Schedules__c>>();
            List<Rent_Schedules__c> childRsList = [Select id,Lease_Charge__c,Lease_Charge__r.Charge_Rate__c,Amount__c,Parent_Rent_Schedule__c,Calc_No_of_Days_Pro_Rated__c from Rent_Schedules__c where Parent_Rent_Schedule__c in:rsIds and Lease_Charge__r.Type__c='By Percent' and Status__c = 'In-Tenancy'];
            for(Rent_Schedules__c rs:childRsList){
                List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                if(parentToChildRSMap.containsKey(rs.Parent_Rent_Schedule__c)){
                    tempList.addAll(parentToChildRSMap.get(rs.Parent_Rent_Schedule__c));
                }
                tempList.add(rs);
                parentToChildRSMap.put(rs.Parent_Rent_Schedule__c,tempList);
            }
            System.debug('parentToChildRSMap-->'+parentToChildRSMap);
            if(parentToChildRSMap.size()>0){
                List<Rent_Schedules__c> updRsList = new List<Rent_Schedules__c>();
                for(Rent_Schedules__c parentRs:triggerNew){
                    if(parentToChildRSMap.containsKey(parentRs.Id)){
                        for(Rent_Schedules__c childRs:parentToChildRSMap.get(parentRs.Id)){
                            if(parentRs.Amount__c!=null && childRs.Lease_Charge__r.Charge_Rate__c!=null){
                                childRs.Amount__c = -(parentRs.Amount__c*childRs.Lease_Charge__r.Charge_Rate__c/100);
                                childRs.Amount__c = childRs.Amount__c.setScale(2);
                            }else{
                                childRs.Amount__c = 0;
                            }
                            System.debug('childRs-->'+childRs);
                            updRsList.add(childRs);
                        }
                    }
                }
                update updRsList;
            }
        }
    }
    
    /*
    *   Function to compute rs converted base rent values according to prorated days and currency code.
    *   Execute queries to retrieve base rent rs linking in the rs object
    *
    */
    public static void calcConvertedBaseRent(list<Rent_Schedules__c> triggerNew){
        
        Set<Id> baseRentIds = new set<Id>();
        for(Rent_Schedules__c rs:triggerNew){
            if(rs.Base_Rent_RS_1__c!=null){
                baseRentIds.add(rs.Base_Rent_RS_1__c);
            }
            if(rs.Base_Rent_RS_2__c!=null){
                baseRentIds.add(rs.Base_Rent_RS_2__c);
            }
        }
        if(baseRentIds.size()>0){
            Map<Id,Rent_Schedules__c> baseRentRsMap = new Map<Id,Rent_Schedules__c>([Select id,Start_Date__c,End_Date__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c,Amount__c,Amount_Local__c,Amount_Foreign__c from Rent_Schedules__c where id in:baseRentIds]);
            System.debug('baseRentRsMap-->'+baseRentRsMap);
            for(Rent_Schedules__c rs:triggerNew){
                System.debug('rs.Id-->'+rs.Id +' '+rs.Base_Rent_RS_1__c);
                rs.Converted_Base_Rent__c = doBRcalculation(rs,rs.Base_Rent_RS_1__c,rs.Base_Rent_RS_2__c,baseRentRsMap);
                System.debug('rs.Converted_Base_Rent__c-->'+rs.Converted_Base_Rent__c);
            }
        }
            
    }
    /*
    *   Utility Method To calculate BaseRent Calculations Prorated
    *
    */
    public static Decimal doBRcalculation(Rent_Schedules__c rs, Id br1, Id br2,Map<Id,Rent_Schedules__c> baseRentRsMap){
        Decimal convertedBR = 0;
        
        if(br1!=null && br2==null){
            System.debug('1*1');
            if(baseRentRsMap.containsKey(br1)){
                Integer daysGap = rs.Start_Date__c.daysBetween(rs.End_Date__c)+1;
                Integer daysInMonth = Date.DaysInMonth(rs.Start_Date__c.Year(),rs.Start_Date__c.Month());
                decimal proRateDays = 1.00*daysGap/daysInMonth;
                proRateDays = proRateDays.setScale(4);
                System.debug(baseRentRsMap.get(br1).Calculated_Amount_Local__c + 'rs.Currency_Code__c-->'+rs.Currency_Code__c);
                if(rs.Currency_Code__c!=label.Default_Currency){                    
                    if(baseRentRsMap.get(br1).Calculated_Amount_Foreign__c!=null){
                        convertedBR = proRateDays*(baseRentRsMap.get(br1).Calculated_Amount_Foreign__c);
                        System.debug('convertedBR1-->'+convertedBR);
                    } 
                }else{
                    if(baseRentRsMap.get(br1).Calculated_Amount_Local__c!=null){
                        convertedBR = proRateDays*(baseRentRsMap.get(br1).Calculated_Amount_Local__c);
                        System.debug('convertedBR2-->'+convertedBR);
                    }
                }
                System.debug('convertedBR-->'+convertedBR);
            }
        }else if(br1!=null && br2!=null){
            System.debug('2*2');
            if(baseRentRsMap.containsKey(br1) && baseRentRsMap.containsKey(br2)){
                decimal amount1 = 0;
                decimal amount2 = 0;
                decimal proRateDays1 = 1.00*(rs.Start_Date__c.daysBetween(baseRentRsMap.get(br1).End_Date__c) + 1)/Date.DaysInMonth(baseRentRsMap.get(br1).End_Date__c.year(),baseRentRsMap.get(br1).End_Date__c.Month());
                proRateDays1 = proRateDays1.setScale(4);
                decimal proRateDays2 = 1.00*(baseRentRsMap.get(br2).Start_Date__c.DaysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.End_Date__c.year(),rs.End_Date__c.Month());
                proRateDays2 = proRateDays2.setScale(4);
                if(rs.Currency_Code__c!=label.Default_Currency){
                    if(baseRentRsMap.get(br1).Calculated_Amount_Foreign__c!=null){
                        amount1 = proRateDays1*baseRentRsMap.get(br1).Calculated_Amount_Foreign__c;
                    }
                    if(baseRentRsMap.get(br2).Calculated_Amount_Foreign__c!=null){
                        amount2 = proRateDays2*baseRentRsMap.get(br2).Calculated_Amount_Foreign__c;
                    }

                }else{
                    if(baseRentRsMap.get(br1).Calculated_Amount_Local__c!=null){
                        amount1 = proRateDays1*baseRentRsMap.get(br1).Calculated_Amount_Local__c;
                    }
                    if(baseRentRsMap.get(br2).Calculated_Amount_Local__c!=null){
                        amount2 = proRateDays2*baseRentRsMap.get(br2).Calculated_Amount_Local__c;
                    }
                }
                System.debug('proRateDays1 ---> '+proRateDays1+' amount1-'+amount1);
                System.debug('baseRentRsMap.get(br1) ---> '+ baseRentRsMap.get(br1));
                System.debug('proRateDays2 ---> '+proRateDays2+' amount2-'+amount2);
                System.debug('baseRentRsMap.get(br2) ---> '+ baseRentRsMap.get(br2));
                convertedBR = amount1 + amount2;
            }
        }
        
        return convertedBR;
    }
    /*
    *   Function is called in before insert and before update triggers.
    *   Base on the values of currency codes update exchange rates, amount local and foreign values
    *
    */
    
    public static void calcMultiCurrencyAmount(list<Rent_Schedules__c> triggerNew, Map<Id,Rent_Schedules__c> oldMap){
        Set<string> currencyCodes = new Set<string>();
        decimal baseForeignCurrencyRate = 0;
        
        Boolean checkCondtn = false;
        for(Rent_Schedules__c rs:triggerNew){
            checkCondtn = (oldMap != null)?((oldMap.containsKey(rs.Id))?(rs.Exchange_Rate__c!=oldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=oldMap.get(rs.Id).Amount__c || rs.Temp_Calculated_Amount__c != oldMap.get(rs.Id).Temp_Calculated_Amount__c):false):true;
             
             System.debug('rs.Amount__c-->'+rs.Amount__c);
             System.debug('oldMap.containsKey(rs.Id)-->'+oldMap.containsKey(rs.Id));

             System.debug('oldMap'+oldMap);

            if(checkCondtn){
	           System.debug('checkCondtn-->'+checkCondtn);
	           System.debug('oldMap.containsKey(rs.Id)-->'+oldMap.containsKey(rs.Id));
	           System.debug('rs.Amount__c != oldMap.get(rs.Id).Amount__c-->'+(rs.Amount__c != oldMap.get(rs.Id).Amount__c));
	           System.debug('rs.Amount__c-->'+rs.Amount__c);
	           System.debug('oldMap.get(rs.Id).Amount__c-->'+oldMap.get(rs.Id).Amount__c);
                //Updated on 21st Feb
                if(rs.Currency_Code__c!=null){ //Removed this condition rs.Exchange_Rate__c==null && 
                    currencyCodes.add(rs.Currency_Code__c);
                }
            }
        }
        
        if(currencyCodes.size()>0){
            currencyCodes.add(label.Base_Foreign_Currency);
            
            List<Exchange_Rate__c> exchangeRateList = [Select id,Currency_Code__c,Conversion_Rate__c,Applicable_Function__c,Start_Date_Time__c from Exchange_Rate__c where Currency_Code__c in:currencyCodes and Applicable_Function__c='Operations' and Start_Date_Time__c<=:system.now() order by Start_Date_Time__c desc];
            for(Exchange_Rate__c er:exchangeRateList){
                if(er.Currency_Code__c==label.Base_Foreign_Currency){
                    baseForeignCurrencyRate  = er.Conversion_Rate__c;
                    break;
                }
            }
            System.debug('baseForeignCurrencyRate-->'+baseForeignCurrencyRate);
            for(Rent_Schedules__c rs:triggerNew){
                checkCondtn = (oldMap != null)?((oldMap.containsKey(rs.Id))?(rs.Exchange_Rate__c!=oldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=oldMap.get(rs.Id).Amount__c || rs.Temp_Calculated_Amount__c != oldMap.get(rs.Id).Temp_Calculated_Amount__c):false):true;
                if(checkCondtn){
                    if(rs.Exchange_Rate__c==null && rs.Currency_Code__c!=null){
                        for(Exchange_Rate__c er:exchangeRateList){
                            if(er.Currency_Code__c==rs.Currency_Code__c){
                                rs.Exchange_Rate__c = er.Conversion_Rate__c;
                                break;
                            }
                        }
                    }
                }
            }
            
            for(Rent_Schedules__c rs:triggerNew){
                checkCondtn = (oldMap != null)?((oldMap.containsKey(rs.Id))?(rs.Exchange_Rate__c!=oldMap.get(rs.Id).Exchange_Rate__c || rs.Amount__c!=oldMap.get(rs.Id).Amount__c || rs.Temp_Calculated_Amount__c != oldMap.get(rs.Id).Temp_Calculated_Amount__c):false):true;
                System.debug('checkCondtn222-->'+checkCondtn);
                if(checkCondtn){
                    System.debug('rs.Amount_Foreign__c-->'+rs.Amount_Foreign__c);
                        System.debug('rs.Amount_Local__c-->'+rs.Amount_Local__c);
                    if(rs.Exchange_Rate__c!=null){
                        if(rs.Exchange_Rate__c==1){
                            if(rs.Amount__c!=null){
                                rs.Amount_Local__c = rs.Amount__c;
                                
                                if(baseForeignCurrencyRate>0){
                                    rs.Amount_Foreign__c = rs.Amount_Local__c/baseForeignCurrencyRate;
                                }
                            }
                            if(rs.Comm_Tax_Amount__c!=null){
                                rs.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount__c;
                                
                                if(baseForeignCurrencyRate>0){
                                    rs.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount_Local__c/baseForeignCurrencyRate;
                                }
                            }
                            if(rs.Temp_Calculated_Amount__c!=null){
                                rs.Calculated_Amount_Local__c = rs.Temp_Calculated_Amount__c;
                                
                                if(baseForeignCurrencyRate>0){
                                    rs.Calculated_Amount_Foreign__c = rs.Calculated_Amount_Local__c/baseForeignCurrencyRate;
                                }
                            }
                        }else{
                            if(rs.Amount__c!=null){
                                rs.Amount_Foreign__c = rs.Amount__c;
                                rs.Amount_Local__c = rs.Amount_Foreign__c*rs.Exchange_Rate__c;
                            }
                            if(rs.Comm_Tax_Amount__c!=null){
                                rs.Comm_Tax_Amount_Foreign__c = rs.Comm_Tax_Amount__c;
                                
                                rs.Comm_Tax_Amount_Local__c = rs.Comm_Tax_Amount_Foreign__c*rs.Exchange_Rate__c;
                            }
                            if(rs.Temp_Calculated_Amount__c!=null){
                                rs.Calculated_Amount_Foreign__c = rs.Temp_Calculated_Amount__c;
                                
                                rs.Calculated_Amount_Local__c = rs.Calculated_Amount_Foreign__c*rs.Exchange_Rate__c;
                            }
                        }
                        System.debug('rs.Amount_Foreign__c-->'+rs.Amount_Foreign__c);
                        System.debug('rs.Amount_Local__c-->'+rs.Amount_Local__c);
                        
                    }
                }
            }
        }
    }

/*end of calcMultiCurrencyAmount */
    
    /*
    *   Execute queries to retrieve parent RS amount
    *   Updates RS amount.
    */
    public static void discountRsAmountCheck(list<Rent_Schedules__c> triggerNew){
        Set<Id> parentRsIds = new Set<Id>();
        Set<Id> lcIds = new Set<Id>();
        for(Rent_Schedules__c rs:triggerNew){
            if(rs.Charge_Type__c=='Discount'){
                parentRsIds.add(rs.parent_Rent_Schedule__c);
                lcIds.add(rs.Lease_Charge__c);
            }
        }
        if(parentRsIds.size()>0 && lcIds.size()>0){
            Map<Id,Rent_Schedules__c> parentRsMap = new Map<Id,Rent_Schedules__c>([Select id,Amount__c from Rent_Schedules__c where id in:parentRsIds]);
            // TODO: replace with method retrieveGtoRsDetailsByRsId() to get rs with lease charge details
            //Map<Id,Lease_Charges__c> leaseChargeMap = new Map<Id,Lease_Charges__c>([Select id,Type__c,Charge_Rate__c from Lease_Charges__c where id in:lcIds]);
            
            for(Rent_Schedules__c rs:triggerNew){
                if(rs.Charge_Type__c=='Discount' && parentRsMap.containsKey(rs.parent_Rent_Schedule__c) && RSTrigger_Helper.RSmap.containsKey(rs.id)){
                    // TODO: replace object access to use rs from result of calling retrieveGtoRsDetailsByRsId()
                    Rent_Schedules__c tempRs = RSTrigger_Helper.RSmap.get(rs.id);
                    if(tempRs.Lease_Charge__r.Type__c=='Fixed'){
                        if(tempRs.Lease_Charge__r.Charge_Rate__c!=null){
                            rs.Amount__c = -(tempRs.Lease_Charge__r.Charge_Rate__c);
                            rs.Amount__c = rs.Amount__c.setScale(2);
                        }else{
                            rs.Amount__c = 0;
                        }
                    }else if(tempRs.Lease_Charge__r.Type__c=='By Percent'){
                        if(parentRsMap.get(rs.parent_Rent_Schedule__c).Amount__c!=null && tempRs.Lease_Charge__r.Charge_Rate__c!=null){
                            rs.Amount__c = -(parentRsMap.get(rs.parent_Rent_Schedule__c).Amount__c*tempRs.Lease_Charge__r.Charge_Rate__c/100);
                            rs.Amount__c = rs.Amount__c.setScale(2);
                        }else{
                            rs.Amount__c = 0;
                        } 
                    }
                }
            }
        }
    } 
    public static void calcChildBaseRent(list<Rent_Schedules__c> triggerNew, Map<Id,Rent_Schedules__c> oldMap){
        Set<Id> rsIds = new Set<Id>();
        for(Rent_Schedules__c rs:triggerNew){
            if(rs.Amount__c!=oldMap.get(rs.Id).Amount__c || rs.Exchange_Rate__c!=oldMap.get(rs.Id).Exchange_Rate__c){
                rsIds.add(rs.Id);
            } 
        }
        if(rsIds.size()>0){
            List<Rent_Schedules__c> childRsList = [Select id,Start_Date__c,End_Date__c,Base_Rent_RS_1__c,Base_Rent_RS_2__c,Currency_Code__c from Rent_Schedules__c where Base_Rent_RS_1__c in:rsIds or Base_Rent_RS_2__c in:rsIds];
            Set<Id> parentRsIds = new Set<Id>();
            for(Rent_Schedules__c rs:childRsList){
                if(rs.Base_Rent_RS_1__c!=null){
                    parentRsIds.add(rs.Base_Rent_RS_1__c);
                }
                
                if(rs.Base_Rent_RS_2__c!=null){
                    parentRsIds.add(rs.Base_Rent_RS_2__c);
                }
            }
            
            Map<Id,Rent_Schedules__c> baseRentRsMap = new Map<Id,Rent_Schedules__c>([Select id,Start_Date__c,End_Date__c,Calculated_Amount__c,Calculated_Amount_Foreign__c,Calculated_Amount_Local__c,Amount__c,Amount_Local__c,Amount_Foreign__c from Rent_Schedules__c where id in:parentRsIds]);
            
            for(Rent_Schedules__c rs:childRsList){
                rs.Converted_Base_Rent__c = doBRcalculation(rs,rs.Base_Rent_RS_1__c,rs.Base_Rent_RS_2__c,baseRentRsMap);
            }
            update childRsList;
        }
    }
    public static void calcEstimatedGTOByLease(boolean triggerBeforeFlag, Map<Id, Rent_Schedules__c> rsFrmTrigger, Map<Id, Rent_Schedules__c> gtoRs ,Date startDate, Date endDate){
        Set<Id> leaseIds = new Set<Id>();
        //Map<Id, Rent_Schedules__c> testGtoRs = gtoRs.clone();
        Map<Id, List<Rent_Schedules__c>> gtoRsByLease = new Map<Id, List<Rent_Schedules__c>>();
        
        if(triggerBeforeFlag){
            //gtoRS = retrieveGtoRsDetailsByRsId(rsFrmTrigger.keySet());
            EstimatedGTO estGTO = new EstimatedGTO(true, rsFrmTrigger, gtoRS, gtoRsByLease, leaseIds, startDate, endDate);
        }
        else{
            for(Rent_Schedules__c indivGtoRs: gtoRs.values()){
                if (indivGtoRs.Id!=null && indivGtoRs.Lease_Charge__r.Charge_Type__c!= null && indivGtoRs.Lease_Charge__r.Charge_Type__c.equals(GTOCHARGETYPE)){
                    leaseIds.add(indivGtoRs.Lease_Unit__r.Lease_Agreement_No__r.Id);
                    
                }
            }
            
            if(leaseIds.size() > 0){
                leaseRelatedGtoRsMap = retrieveLeaseRelatedGtoRsByLeaseId(leaseIds, startDate, endDate);
            }
            if(leaseRelatedGtoRsMap != null && leaseRelatedGtoRsMap.size()>0){
                // group gto rs by lease id and store in gtoRsByLease
                for(Rent_Schedules__c luRelatedGtoRs : leaseRelatedGtoRsMap.values()){
                    if(gtoRsByLease.containsKey(luRelatedGtoRs.Lease_Unit__r.Lease_Agreement_No__r.Id)){
                        List<Rent_Schedules__c> tempRSList = gtoRsByLease.get(luRelatedGtoRs.Lease_Unit__r.Lease_Agreement_No__r.Id);
                        tempRSList.add(luRelatedGtoRs);
                        gtoRsByLease.put(luRelatedGtoRs.Lease_Unit__r.Lease_Agreement_No__r.Id, tempRSList);
                    }else{
                        gtoRsByLease.put(luRelatedGtoRs.Lease_Unit__r.Lease_Agreement_No__r.Id, new List<Rent_Schedules__c> {luRelatedGtoRs});
                    }
                }
                
                EstimatedGTO estGTO = new EstimatedGTO(false, rsFrmTrigger, gtoRS, gtoRsByLease, leaseIds, startDate, endDate);
            }   
        }
        
    }
}