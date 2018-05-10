global class PopulateBaseRentRsController{
    
    webservice static string pplBaseRent(string lcId,string baseChargeType){ 
        if(baseChargeType==null || baseChargeType.trim().length()==0){
            return 'Please select Base Charge Type to populate Base Rent RS.';
        }
        string result;
        try{
            List<Rent_Schedules__c> rsList = [Select id,Lease_Charge__c,Lease_Charge__r.Base_Charge_Type__c,Lease_Unit__c,Start_Date__c,End_Date__c,Base_Rent_RS_1__c,Base_Rent_RS_2__c from Rent_Schedules__c where Base_Rent_RS_1__c=null and Lease_Charge__r.Base_Charge_Type__c!=null and Approved__c=false and Lease_Charge__c=:lcId];
            Set<Id> luIds = new Set<Id>();
            Set<string> baseChgTypes = new Set<string>();
            if(rsList.size()>0){
                for(Rent_Schedules__c rs:rsList){
                 luIds.add(rs.Lease_Unit__c);
                    baseChgTypes.add(RS.Lease_Charge__r.Base_Charge_Type__c);
                }
                
                Map<Id,Map<string,List<Rent_Schedules__c>>> luToBaseChgRentScheduleMap = new Map<Id,Map<string,List<Rent_Schedules__c>>>();
                List<Lease_Charges__c> baseLeaseChargeList = [Select id,Lease_Unit__c,Charge_Type__c,(Select id,Start_Date__c,End_Date__c,Amount__c,Amount_Local__c,Amount_Foreign__c,Base_Rent_RS_1__c,Base_Rent_RS_2__c from Rent_Schedules__r) from Lease_Charges__c where Lease_Unit__c in:luIds and Charge_Type__c in:baseChgTypes];
                
                for(Lease_Charges__c blc:baseLeaseChargeList){
                    Map<string,List<Rent_Schedules__c>> tempMap = new Map<string,List<Rent_Schedules__c>>();
                    if(luToBaseChgRentScheduleMap.containsKey(blc.Lease_Unit__c)){
                        tempMap = luToBaseChgRentScheduleMap.get(blc.Lease_Unit__c);
                    }
                    List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
                    
                    if(tempMap.containsKey(blc.Charge_Type__c)){
                        tempList.addAll(tempMap.get(blc.Charge_Type__c));
                    }
                    tempList.addAll(blc.Rent_Schedules__r);
                    tempMap.put(blc.Charge_Type__c,tempList);
                    luToBaseChgRentScheduleMap.put(blc.Lease_Unit__c,tempMap);
                }
                
                Map<Id,Rent_Schedules__c> baseRsMap = new Map<Id,Rent_Schedules__c>();
                for(Rent_Schedules__c rs:rsList){
                    if(luToBaseChgRentScheduleMap.containsKey(rs.Lease_Unit__c)){
                        for(Rent_Schedules__c baseRs:luToBaseChgRentScheduleMap.get(rs.Lease_Unit__c).get(rs.Lease_Charge__r.Base_Charge_Type__c)){
                            baseRsMap.put(baseRs.Id,baseRs);
                            if(rs.Start_Date__c>=baseRs.Start_Date__c && rs.Start_Date__c<=baseRs.End_Date__c){
                                rs.Base_Rent_RS_1__c = baseRs.Id;
                            }
                            if(rs.End_Date__c>=baseRs.Start_Date__c && rs.End_Date__c<=baseRs.End_Date__c){
                                if(baseRs.Id!=rs.Base_Rent_RS_1__c){
                                    rs.Base_Rent_RS_2__c = baseRs.Id;
                                }
                            }
                        }
                        if(rs.Base_Rent_RS_1__c!=null && rs.Base_Rent_RS_2__c==null){
                            decimal proRateDays = 1.00*(rs.Start_Date__c.daysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.Start_Date__c.Year(),rs.Start_Date__c.Month());
                            proRateDays = proRateDays.setScale(4);
                            if(rs.Currency_Code__c!='MMK'){
                                if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c!=null){
                                    rs.Converted_Base_Rent__c = proRateDays*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c;
                                }
                            }else{
                                if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                    rs.Converted_Base_Rent__c = proRateDays*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c;
                                }
                            }
                        }else if(rs.Base_Rent_RS_1__c!=null && rs.Base_Rent_RS_2__c!=null){
                            decimal amount1 = 0;
                            decimal amount2 = 0;
                            decimal proRateDays1 = 1.00*(rs.Start_Date__c.daysBetween(baseRsMap.get(rs.Base_Rent_RS_1__c).End_Date__c) + 1)/Date.DaysInMonth(rs.Start_Date__c.year(),rs.Start_Date__c.Month());
                            proRateDays1 = proRateDays1.setScale(4);
                            decimal proRateDays2 = 1.00*(baseRsMap.get(rs.Base_Rent_RS_2__c).Start_Date__c.DaysBetween(rs.End_Date__c)+1)/Date.DaysInMonth(rs.Start_Date__c.year(),rs.Start_Date__c.Month());
                            proRateDays2 = proRateDays2.setScale(4);
                            if(rs.Currency_Code__c!='MMK'){
                                if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c!=null){
                                    amount1 = proRateDays1*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Foreign__c;
                                }
                                if(baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Foreign__c!=null){
                                    amount2 = proRateDays2*baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Foreign__c;
                                }
                            }else{
                                if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                    amount1 = proRateDays1*baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c;
                                }
                                
                                if(baseRsMap.get(rs.Base_Rent_RS_1__c).Amount_Local__c!=null){
                                    amount2 = proRateDays2*baseRsMap.get(rs.Base_Rent_RS_2__c).Amount_Local__c;
                                }
                            }
                            rs.Converted_Base_Rent__c = amount1 + amount2;
                        }
                    }
                }
                update rsList;
                result = 'Base Rent Rs populated successfully.';
            }else{
                result = 'Rent Schedule(s) are not generated yet. Please check Base Rent Schedule(s) are generated, and generate Rent Schedule(s).';
            }
        }catch(exception e){
            result = e.getMessage();
        }
        
        return result;

    }
}