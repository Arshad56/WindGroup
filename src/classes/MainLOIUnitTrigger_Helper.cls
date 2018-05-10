public with sharing class MainLOIUnitTrigger_Helper { 
    public static void updateLeasePlans(Set<Id> loiUnitIds,Set<Id> unitIds){
        Map<Id, Map<String,Lease_Plan__c>> mapLeaseplanwithMonths = new Map<Id, Map<String,Lease_Plan__c>>();
        String  soqlQueryUnit = 'select Id,Monthly_Budget__c,Unit__c,Start_Date__c,End_Date__c,Commited__c,Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,'
                                +'Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,'
                                +'Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,'
                                +'Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,'
                                +'Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,'
                                +'Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,'
                                +'Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,'
                                +'Status_7__c,Status_8__c,Status_9__c,Status_10__c,'
                                +'Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,'
                                +'Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,'
                                +'Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,'
                                +'Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c,'
                                +'Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,'
                                +'Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,'
                                +'Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,'
                                +'Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,'
                                +'Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,'
                                +'Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c '
                                +'from Lease_Plan__c where Unit__c =: unitIds';
        
        List<Lease_Plan__c> listLP =  database.query(soqlQueryUnit);
        List<LOI_Unit__c> listLU = [select Id,Unit__r.NLA_SQF__c,Unit__r.Charge_Method__c ,Unit__c,LOI_Agreement_No__r.LOI_Start_Date__c,LOI_Agreement_No__r.LOI_End_Date__c,LOI_Start_Date__c,LOI_End_Date__c, 
                                    (Select Id, Start_Date__c, Charge_Rate__c, Charge_Type__c, End_Date__c 
                                        From LOI_Charges__r where Charge_Type__c ='Advance Rental') 
                                    from LOI_Unit__c where Id =: loiUnitIds];
        Map<String,Lease_Plan__c> tempInner;
        for(Lease_Plan__c lp:listLP){
            if(mapLeaseplanwithMonths.containsKey(lp.Unit__c)) {
                Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
            } else {
                tempInner = new Map<String,Lease_Plan__c>();
                tempInner.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                mapLeaseplanwithMonths.put(lp.Unit__c, tempInner);
            }
        }
        Lease_Plan__c lp;
        Date Everyday;
        Date beforeDate;
        for(LOI_Unit__c lu: listLU){ 
            
            Integer totalMonths = 0;
            if(lu.LOI_Start_Date__c != null && lu.LOI_End_Date__c != null){
                //totalMonths = lu.Lease_Agreement_No__r.Lease_Start_Date__c.monthsBetween(lu.Lease_Agreement_No__r.Lease_End_Date__c);
              //  lu.Lease_Start_Date__c = lu.Lease_Agreement_No__r.Lease_Start_Date__c;
               // lu.Lease_End_Date__c = lu.Lease_Agreement_No__r.Lease_End_Date__c;
                totalMonths = lu.LOI_Start_Date__c.monthsBetween(lu.LOI_End_Date__c);
            }

            Date tempDate = lu.LOI_Start_Date__c;
            for(Integer i = 0; i <= totalMonths; i++){
                lp = new Lease_Plan__c();
                if(lu.Unit__c != null  && tempDate != null){
                    if(mapLeaseplanwithMonths.containsKey(lu.Unit__c)){
                        if(mapLeaseplanwithMonths.get(lu.Unit__c).containsKey(tempDate.Month()+''+tempDate.Year())){
                            Integer numberOfDays = Date.daysInMonth(tempDate.year(), tempDate.month());
                            Integer endOfMonth = Date.daysInMonth(tempDate.year(), tempDate.month());
                            if(tempDate.month() == lu.LOI_End_Date__c.month() && tempDate.year() == lu.LOI_End_Date__c.year()){
                                numberOfDays = lu.LOI_End_Date__c.day();
                            }
                            lp = mapLeaseplanwithMonths.get(lu.Unit__c).get(tempDate.Month()+''+tempDate.Year());
                            lp.LOI_Unit__c = lu.Id;
                            Everyday = tempDate;
                            beforeDate = Date.newInstance(Everyday.year(),Everyday.Month(),1);
                            lp.put('Status__c', 'LOI');
                            
                            if(lu.Unit__r.Charge_Method__c != null && (lu.Unit__r.Charge_Method__c.contains('Monthly Rate - CL') || lu.Unit__r.Charge_Method__c.contains('Monthly Rate - L'))){
                                for(LOI_Charges__c lulc : lu.LOI_Charges__r){
                                    if(((lp.Start_Date__c <= lulc.Start_Date__c && lp.End_Date__c >= lulc.Start_Date__c)||(lp.Start_Date__c >= lulc.Start_Date__c && lp.Start_Date__c <= lulc.End_Date__c)) && lulc.Charge_Rate__c != null){
                                        lp.put('LOI_Monthly_Budget__c', lulc.Charge_Rate__c);//endOfMonth);
                                        break;
                                    }
                                }
                            }
                            
                            for(Integer j = 1; j <= 31; j++){
                                lp.put('LOI__c',true);
                                if(j <= endOfMonth){
                                    if(lp.Monthly_Budget__c > 0){
                                        lp.put('Daily_Rate_'+j+'__c', lp.Monthly_Budget__c/endOfMonth);
                                    }
                                    String tempStat = (String)  lp.get('Status_'+j+'__c');
                                    if(beforeDate >= tempDate && j <= numberOfDays){
                                        lp.put('Day_'+j+'__c', Everyday);
                                        Everyday = Everyday +1;
                                        lp.put('Status_'+j+'__c', 'LOI');
                                    }else if(String.isEmpty(tempStat)){
                                        lp.put('Day_'+j+'__c',  beforeDate);
                                        lp.put('Status_'+j+'__c', 'Vacant');
                                    }
                                    beforeDate = beforeDate +1;
                                }else{
                                    lp.put('Day_'+j+'__c', null);
                                    lp.put('Status_'+j+'__c', 'N/A');
                                }
                                
                                
                            }
                            Map<String,Lease_Plan__c> tempMap = mapLeaseplanwithMonths.get(lp.Unit__c);
                            tempMap.put(lp.Start_Date__c.Month()+''+lp.Start_Date__c.Year(),lp);
                            mapLeaseplanwithMonths.put(lp.Unit__c, tempMap);
                        }
                    }
                    tempDate = Date.newInstance(tempDate.year(), tempDate.month()+1, 1);
                }
                
            }
        }
        List<Lease_Plan__c> updateLPs= new List<Lease_Plan__c>();
        for(Id ids:mapLeaseplanwithMonths.keySet()){
            for(String dateCode: mapLeaseplanwithMonths.get(ids).keySet()){
                updateLPs.add(mapLeaseplanwithMonths.get(ids).get(dateCode));
            }
        }
        update updateLPs;
    }
}