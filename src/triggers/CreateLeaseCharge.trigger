trigger CreateLeaseCharge on Lease_Unit__c(after insert){
        Map<String, Id>typeMap = New Map<String, Id>();
    
        for(RecordType rt: [Select ID, DeveloperName From RecordType Where sObjectType = 'Lease_Charges__c']){
            typeMap.put(rt.DeveloperName, rt.id);
        }
    
        Set<Id>unitIds = new Set<Id>();
        Set<Id>leaseIds = new Set<Id>();
        for(Lease_Unit__c lu: Trigger.New){
            if(!lu.Converted_From_LOI__c){
                leaseIds.add(lu.Lease_Agreement_No__c);
                if(lu.Unit__c != null){
                    unitIds.add(lu.Unit__c);
                }
            }
        }
    
        if(unitIds.size()>0){
            Map<Id, Id>unitToPropertyMap = new Map<Id, Id>();
            Map<Id, Units__c>unitMap = new Map<Id, Units__c>();
            Set<Id>propertyIds = new Set<Id>();
            Map<Id, Map<string, Lease_Plan__c>>unitToLeasePlanMap = new Map<Id, Map<string, Lease_Plan__c>>();
            List<Units__c>unitList = [Select id, Property__c, Charge_Method__c,(Select id, Start_Date__c, Daily_Rate_1__c, Daily_Rate_2__c, Daily_Rate_3__c, Daily_Rate_4__c, Daily_Rate_5__c, Daily_Rate_6__c, Daily_Rate_7__c, Daily_Rate_8__c, Daily_Rate_9__c, Daily_Rate_10__c, Daily_Rate_11__c, Daily_Rate_12__c, Daily_Rate_13__c, Daily_Rate_14__c, Daily_Rate_15__c, Daily_Rate_16__c, Daily_Rate_17__c, Daily_Rate_18__c, Daily_Rate_19__c, Daily_Rate_20__c, Daily_Rate_21__c, Daily_Rate_22__c, Daily_Rate_23__c, Daily_Rate_24__c, Daily_Rate_25__c, Daily_Rate_26__c, Daily_Rate_27__c, Daily_Rate_28__c, Daily_Rate_29__c, Daily_Rate_30__c, Daily_Rate_31__c from Lease_Plans__r)from Units__c where id in: unitIds];
            for(Units__c un: unitList){
                unitMap.put(un.Id, un);
                unitToPropertyMap.put(un.Id, un.Property__c);
                propertyIds.add(un.Property__c);
    
                if(un.Lease_Plans__r.size()>0){
                    Map<string, Lease_Plan__c>tempPlanMap = new Map<string, Lease_Plan__c>();
                    for(Lease_Plan__c lp: un.Lease_Plans__r){
                        if(lp.Start_Date__c != null){
                            tempPlanMap.put(lp.Start_Date__c.month()+ '-' + lp.Start_Date__c.year(), lp);
                        }
                    }
                    unitToLeasePlanMap.put(un.Id, tempPlanMap);
                }
            }
    
            if(propertyIds.size()>0){
                List<Applicable_Charges__c>appChgList = [Select id, Charge_Start_Day__c, Currency_Code__c, Billing_Frequency__c, Base_Charge_Type__c, Due_Month_Formula__c, Billing_Terms__c, Lease_Type__c, RecordType.DeveloperName, Name, Active__c, Property__c, Base_included__c, Base_Value__c, Billing_Days__c, Frequency__c, Charge_Operator__c, Charge_Rate__c, GTO_Percent__c, Charge_Rate_Description__c, Multiple_of_Parameter__c, Finance_Accounts_Code__c, Finance_Accounts_Desc__c, Type__c, Rate__c, Commercial_Tax_Apply__c, Charge_Type__c, Multiple_Rental_Schedule__c, Cap_Applicable__c, Cap_Value__c, Tiered_Limit__c, Cumulative_for_each_Tier__c, Tier_1_Rate__c, Tier_1_Upper_Limit__c, Tier_2_Rate__c, Tier_2_Upper_Limit__c, Tier_3_Rate__c, Tier_3_Upper_Limit__c, Tier_4_Rate__c, Tier_4_Upper_Limit__c, Tier_5_Rate__c, Tier_5_Upper_Limit__c, Tier_6_Rate__c, Tier_6_Upper_Limit__c, Tier_7_Rate__c, Tier_7_Upper_Limit__c, Tier_8_Rate__c, Tier_8_Upper_Limit__c, Tiered_Lower_Limit__c, Charge_Method__c, Expected_GTO_Amount__c from Applicable_Charges__c where Property__c in: propertyIds and Charge_Type__c != 'Miscellaneous'
                    and Active__c = true];
                Map<Id, List<Applicable_Charges__c>>propToAppChgMap = new Map<Id, List<Applicable_Charges__c>>();
                for(Applicable_Charges__c ac: appChgList){
                    List<Applicable_Charges__c>tempList = new List<Applicable_Charges__c>();
                    if(propToAppChgMap.containsKey(ac.Property__c)){
                        tempList.addAll(propToAppChgMap.get(ac.Property__c));
                    }
                    tempList.add(ac);
                    propToAppChgMap.put(ac.Property__c, tempList);
                }
    
    
                Map<Id, Lease__c>leaseMap = new Map<Id, Lease__c>([Select id, Lease_Start_Date__c, Lease_End_Date__c, Rent_Free_Start_Date__c, Rent_Free_End_Date__c from Lease__c where id in: leaseIds]);
                
                if(propToAppChgMap.size()>0){
                    
                    Map<Id,Map<string,Lease_Plan__c>> unitToDateLpMap = new Map<Id,Map<string,Lease_Plan__c>>();
                    for(Lease_Plan__c lp:[Select id,Unit__c,Start_Date__c,End_Date__c,Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c,Monthly_Budget__c from Lease_Plan__c where Unit__c=:unitIds]){
                        Map<string,Lease_Plan__c> tempMap = new Map<string,Lease_Plan__c>();
                        if(unitToDateLpMap.containsKey(lp.Unit__c)){
                            tempMap = unitToDateLpMap.get(lp.Unit__c);
                        }
                        tempMap.put(lp.Start_Date__c.month()+'-'+lp.Start_Date__c.year(),lp);
                        
                        unitToDateLpMap.put(lp.Unit__c,tempMap);
                    }
                    
                    List<Lease_Charges__c>leaseChargeList = new List<Lease_Charges__c>();
                    Map<string, Lease_Charges__c>rentFreeLsChgMap = new Map<string, Lease_Charges__c>();
                    for(Lease_Unit__c lu: Trigger.New){
                        Date luStartDate = (lu.Lease_Start_Date__c == null)?leaseMap.get(lu.Lease_Agreement_No__c).Lease_Start_Date__c:lu.Lease_Start_Date__c;
                        Date luEndDate = (lu.Lease_End_Date__c == null)?leaseMap.get(lu.Lease_Agreement_No__c).Lease_End_Date__c:lu.Lease_End_Date__c;
                            
                        if(!lu.Converted_From_LOI__c){
                            if(unitToPropertyMap.containsKey(lu.Unit__c)&& propToAppChgMap.containsKey(unitToPropertyMap.get(lu.Unit__c))){
                                for(Applicable_Charges__c ac: propToAppChgMap.get(unitToPropertyMap.get(lu.Unit__c))){
                                    if(unitMap.get(lu.Unit__c).Charge_Method__c != null){
                                        if(ac.Charge_Method__c == 'Daily Rate'){
                                            if(unitMap.get(lu.Unit__c).Charge_Method__c.contains(ac.Charge_Method__c)){
                                                for(Date dt =luStartDate; dt <=luEndDate; dt = dt + 1){
                                                    Lease_Charges__c lc = new Lease_Charges__c();
                                                  
                                                    CreateLeaseChargeHelper.assignValues(lc,ac,lu,typeMap,leaseMap);
                                                    
                                                    lc.Start_Date__c = dt;
                                                    lc.End_Date__c = dt;
                                                    if(unitToLeasePlanMap.containsKey(lu.Unit__c)){
                                                        if(unitToLeasePlanMap.get(lu.Unit__c).containsKey(dt.month()+ '-' + dt.year())){
                                                            Lease_Plan__c lp = unitToLeasePlanMap.get(lu.Unit__c).get(dt.month()+ '-' + dt.year());
                                                            lc.Lease_Plan__c = lp.Id;
                                                            lc.Charge_Rate__c =(decimal)lp.get('Daily_Rate_' + dt.day()+ '__c');
                                                        }
                                                    }
                                                    leaseChargeList.add(lc);
                                                }
    
                                            }
                                        }else if(ac.Charge_Method__c == 'Monthly Rate - L' || ac.Charge_Method__c == 'Transaction Rate' ||(ac.Charge_Method__c == 'Monthly Rate - CL' && ac.Charge_Type__c!= 'Advance Rental')){
                                            if(unitMap.get(lu.Unit__c).Charge_Method__c.contains(ac.Charge_Method__c)){
                                                Lease_Charges__c lc = new Lease_Charges__c();
                                                CreateLeaseChargeHelper.assignValues(lc,ac,lu,typeMap,leaseMap);
    
                                                //Start And End Date
                                                if(luStartDate != null){
                                                    lc.Start_Date__c = luStartDate; // Antony - 29th Aug 2016
                                                } else {
                                                    lc.Start_Date__c = leaseMap.get(lu.Lease_Agreement_No__c).Lease_Start_Date__c;
                                                }
                                                if(luEndDate != null){
                                                    lc.End_Date__c = luEndDate; // Antony - 29th Aug 2016
                                                } else {
                                                    lc.End_Date__c = leaseMap.get(lu.Lease_Agreement_No__c).Lease_End_Date__c;
                                                }
                                                //---------------
                                                //CHARGE RATE   
                                                lc.Charge_Rate__c = ac.Charge_Rate__c;
                                                //---------------
    
                                                leaseChargeList.add(lc);
                                            }
                                        }else if(ac.Charge_Method__c == 'Monthly Rate - CL' && ac.Charge_Type__c == 'Advance Rental'){
                                            if(unitMap.get(lu.Unit__c).Charge_Method__c.contains(ac.Charge_Method__c)){
                                                    Integer luStartMonth = luStartDate.month();
                                                    Integer luStartYear = luStartDate.year();
                                                    
                                                    Integer luEndMonth = luEndDate.month();
                                                    Integer luEndYear = luEndDate.year();
                                                    
                                                    Lease_Charges__c lc = new Lease_Charges__c();
                                                    CreateLeaseChargeHelper.assignValues(lc,ac,lu,typeMap,leaseMap);
                                                    
                                                    lc.Start_Date__c = null;
                                                    lc.Charge_Rate__c = null;
                                                    while((luStartMonth<=luEndMonth && luStartYear<=luEndYear) || (luStartMonth>luEndMonth && luStartYear<luEndYear)){
                                                        if(unitToDateLpMap.containsKey(lu.Unit__c)){
                                                            decimal tempRate = null;
                                                            if(unitToDateLpMap.get(lu.Unit__c).containsKey(luStartMonth+'-'+luStartYear) && unitToDateLpMap.get(lu.Unit__c).get(luStartMonth+'-'+luStartYear).Monthly_Budget__c>0){
                                                                tempRate = unitToDateLpMap.get(lu.Unit__c).get(luStartMonth+'-'+luStartYear).Monthly_Budget__c;
                                                            }else{
                                                                tempRate = 0;
                                                            }
                                                            if(lc.Charge_Rate__c!=null){
                                                                if(lc.Charge_Rate__c!=tempRate){
                                                                    leaseChargeList.add(lc);
                                                                    lc = new Lease_Charges__c();
                                                                    CreateLeaseChargeHelper.assignValues(lc,ac,lu,typeMap,leaseMap);
                                                                    lc.Start_Date__c = null;
                                                                    lc.Charge_Rate__c = tempRate;
                                                                }
                                                            }else{
                                                                lc.Charge_Rate__c = tempRate;
                                                            }
                                                            /*If(priceFactor!=null && luChr1.Charge_Rate__c!=null){
                                                                luChr1.Charge_Rate__c = luChr1.Charge_Rate__c*priceFactor;
                                                            }*/
                                                            if(lc.Start_Date__c==null){
                                                                if(luStartMonth==luStartDate.month() && luStartYear==luStartDate.Year()){
                                                                    lc.Start_Date__c = Date.NewInstance(luStartYear,luStartMonth,luStartDate.Day());
                                                                }else{
                                                                    lc.Start_Date__c = Date.NewInstance(luStartYear,luStartMonth,1);
                                                                }
                                                            }
                                                            if(luStartMonth==luEndDate.month() && luStartYear==luEndDate.Year()){
                                                                lc.End_Date__c = Date.NewInstance(luStartYear,luStartMonth,luEndDate.Day());
                                                            }else{
                                                                lc.End_Date__c = Date.NewInstance(luStartYear,luStartMonth,Date.DaysInMonth(luStartYear,luStartMonth));
                                                            }
                                                            
                                                            if(lc.End_Date__c>luEndDate){
                                                                lc.End_Date__c = luEndDate;
                                                            }
                                                        }else{
                                                            lc.Charge_Rate__c = 0;
                                                            lc.Start_Date__c =  luStartDate;
                                                            lc.End_Date__c =  luEndDate;
                                                            break;
                                                        }
                                                        if(luStartMonth==12){
                                                            luStartMonth = 1;
                                                            luStartYear++;
                                                        }else{
                                                            luStartMonth++;
                                                        }
                                                    }
                                                    leaseChargeList.add(lc);
                                                    
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(leaseChargeList.size()>0){
                        insert leaseChargeList;
                        System.debug('leaseChargeList-->'+leaseChargeList);
                    }
    
                }
            }
        }
        
        
        Set<Id> leaseUnitIds = new Set<Id>();
        unitIds = new Set<Id>();
        for(Lease_Unit__c lu: Trigger.new){
            System.debug('Trigger.isInsert-->'+Trigger.isInsert);
            System.debug('Trigger.isUpdate -->'+Trigger.isUpdate);
            //System.debug('lu.Update_Lease_Plans__c-->'+lu.Unit__c);
            if(Trigger.isInsert && lu.Update_Lease_Plans__c){
                leaseUnitIds.add(lu.Id); 
                unitIds.add(lu.Unit__c);
                //System.debug('111-->'+lu.id);
            }
        }
        System.debug('11unitIds-->'+unitIds);
        //System.debug('leaseUnitIds-->'+leaseUnitIds);
        if(leaseUnitIds.size() > 0){
            MainLeaseUnitTrigger_Helper.updateLeasePlans(leaseUnitIds,unitIds);
        }
}