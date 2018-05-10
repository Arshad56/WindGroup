trigger CreateRentSchedule on Units__c (after insert,after update) {
    Set<Id> unitIds = new Set<Id>();
    
    //added by myat oct-28 for CT(%)       
    Map<Id,Decimal> mapUnitIdCT = new Map<Id,Decimal>();    
    Map<Id,Property__c> mapProperty = new Map<Id,Property__c>([SELECT Id, Name, End_Year__c, Comm_Tax__c FROM Property__c]);
    
    //Rent_Schedule_Configuration__c scheduleConfig = Rent_Schedule_Configuration__c.getValues('Rent');
    //if(scheduleConfig != null && scheduleConfig.Rental_Schedule_Generate__c){
        for(Units__c ut:Trigger.New){
            if((Trigger.isInsert && ut.Active__c) || (Trigger.isUpdate && ut.Active__c && ut.Active__c!=Trigger.oldMap.get(ut.Id).Active__c)){
                if(ut.Start_Date__c!=null && ut.End_Date__c!=null){
                    unitIds.add(ut.Id);                    
                    
                    //added by myat oct-28 for CT(%)
                    Property__c pp = mapProperty.get(ut.Property__c);
                    if(pp <> Null)                    
                     mapUnitIdCT.put(ut.Id,pp.Comm_Tax__c);
                    else
                     mapUnitIdCT.put(ut.Id,5.00);
                }
            }
        }        

        
        if(unitIds.size()>0){
            /*Map<Id,List<Lease_Charges__c>> unitToLeaseChargeMap = new Map<Id,List<Lease_Charges__c>>();
            List<Lease_Unit__c> LeaseUnitList = [Select id,Unit__c,(Select id,Start_Date__c,End_Date__c from Lease_Charges__r where Start_Date__c!=null and End_Date__c!=null) from Lease_Unit__c where Unit__c in:unitIds];
            for(Lease_Unit__c lu:LeaseUnitList){
                for(Lease_Charges__c chg: lu.Lease_Charges__r){
                    List<Lease_Charges__c> tempList = new List<Lease_Charges__c>();
                    if(unitToLeaseChargeMap.containsKey(lu.Unit__c)){
                        tempList.addAll(unitToLeaseChargeMap.get(lu.Unit__c));
                    }
                    tempList.add(chg);
                    unitToLeaseChargeMap.put(lu.Unit__c,tempList);
                }
            }*/
            List<Rent_Schedules__c> rentScheduleList = new List<Rent_Schedules__c>();
            for(Units__c ut:Trigger.New){
                if(unitIds.contains(ut.Id)){
                    Date endDate;
                    if(mapProperty.containsKey(ut.Property__c) && mapProperty.get(ut.Property__c).End_Year__c != null){
                        // Removed refrence to Custom setting Rent_Schedule_Configuration__c
                        // AS 4 April
                        endDate = Date.newInstance(Integer.valueOf(mapProperty.get(ut.Property__c).End_Year__c), ut.End_Date__c.month(), ut.End_Date__c.day());//ut.Start_Date__c.addYears(Integer.valueOf(scheduleConfig.Rental_Schedule_Period__c));
                    }else{
                        endDate = ut.End_Date__c;
                    }
                    
                    if(endDate>ut.End_Date__c){
                        endDate = ut.End_Date__c;
                    }
                    
                    Integer startMonth = ut.Start_Date__c.Month();
                    Integer startYear = ut.Start_Date__c.Year();
                    Integer endMonth = endDate.Month();
                    Integer endYear = endDate.Year();
                    
                    Integer IncMonth = startMonth;
                    Integer IncYear = startYear;
                    
                    While((IncMonth <= endMonth && IncYear <= endYear) || (incMonth>endMonth && incYear<endYear)){
                        Rent_Schedules__c rs = new Rent_Schedules__c();
                        //rs.Name = ut.Name + '-' + IncMonth+IncYear;
                        rs.Unit__c = ut.Id;
                        rs.Status__c = 'Vacancy';
                        rs.Comm_Tax__c = mapUnitIdCT.get(ut.Id); //added by myat oct-28 for CT(%)
                        if(incMonth==startMonth && incYear==startYear){
                            rs.Start_Date__c = date.NewInstance(incYear,incMonth,ut.Start_Date__c.day());
                        }else{
                            rs.Start_Date__c = date.NewInstance(incYear,incMonth,1);
                        }
                        system.debug('incMonth==='+incMonth+'   IncYear===='+incYear);
                        system.debug('StartDate==='+rs.Start_Date__c);
                        
                        if(incMonth==endMonth && incYear==endYear){
                            rs.End_Date__c = date.NewInstance(incYear,incMonth,ut.End_Date__c.day());
                        }else{
                            rs.End_Date__c = date.NewInstance(incYear,incMonth,Date.DaysInMonth(incYear,incMonth));
                        }
                        
                        if(incMonth==12){
                            incMonth = 1;
                            incYear++;
                        }else{
                            incMonth++;
                        }
                        
                        system.debug('NewincMonth==='+incMonth+'   IncYear===='+incYear);
                        rentScheduleList.add(rs);
                    }
                }
            }
            /*if(unitToLeaseChargeMap.size()>0){
                List<Rent_Schedules__c> newRentScheduleList = new List<Rent_Schedules__c>();
                for(Rent_Schedules__c rs:rentScheduleList){
                    if(unitToLeaseChargeMap.containsKey(rs.Unit__c)){
                        Integer rentStartDay = rs.Start_Date__c.Day();
                        Integer rentStartMonth = rs.Start_Date__c.Month();
                        Integer rentStartYear = rs.Start_Date__c.Year();
                        Integer rentEndDay = rs.End_Date__c.Day();
                        Integer rentEndMonth = rs.End_Date__c.Month();
                        Integer rentEndYear = rs.End_Date__c.Year();
                        for(Lease_Charges__c chg:unitToLeaseChargeMap.get(rs.Unit__c)){
                            Integer startDay = chg.Start_Date__c.Day();
                            Integer startMonth = chg.Start_Date__c.Month();
                            Integer startYear = chg.Start_Date__c.Year();
                            Integer endDay = chg.End_Date__c.Day();
                            Integer endMonth = chg.End_Date__c.Month();
                            Integer endYear = chg.End_Date__c.Year();
                            
                            Integer IncMonth = startMonth;
                            Integer IncYear = startYear;
                            While((IncMonth <= endMonth && IncYear <= endYear)){
                                if(incMonth==rentStartMonth && incYear==rentStartYear){
                                    if(incMonth==StartMonth && incYear==startYear){
                                        if(rentStartDay < startDay){
                                            rs.Start_Date__c = date.newInstance(incYear,incMonth,startDay);
                                            rs.Status__c = 'In-Tenancy';
                                            rs.Lease_Charge__c = chg.Id;
                                            
                                            Rent_Schedules__c newRs = new Rent_Schedules__c();
                                            newRs.Name = rs.Name;
                                            newRs.Unit__c = rs.Unit__c;
                                            newRs.Status__c = 'Vacancy';
                                            newRs.Start_Date__c = date.newInstance(incYear,incMonth,rentStartDay);
                                            newRs.End_Date__c = date.newInstance(incYear,incMonth,startDay-1);                                        
                                            newRentScheduleList.add(newRs);
                                        }else{
                                            rs.Status__c = 'In-Tenancy';
                                            rs.Lease_Charge__c = chg.Id;
                                        }
                                    }else if(incMonth==endMonth && incYear==endYear){
                                        if(rentEndDay > endDay){
                                            rs.End_Date__c = date.newInstance(incYear,incMonth,endDay);
                                            rs.Status__c = 'In-Tenancy';
                                            rs.Lease_Charge__c = chg.Id;
                                            
                                            Rent_Schedules__c newRs = new Rent_Schedules__c();
                                            newRs.Name = rs.Name;
                                            newRs.Unit__c = rs.Unit__c;
                                            newRs.Status__c = 'Vacancy';
                                            newRs.Start_Date__c = date.newInstance(incYear,incMonth,endDay+1);
                                            newRs.End_Date__c = date.newInstance(incYear,incMonth,rentEndDay);
                                            newRentScheduleList.add(newRs);
                                        }else{
                                            rs.Status__c = 'In-Tenancy';
                                            rs.Lease_Charge__c = chg.Id;
                                        }
                                    }else{
                                        rs.Status__c = 'In-Tenancy';
                                        rs.Lease_Charge__c = chg.Id;
                                    }
                                }
                                if(incMonth==12){
                                    incMonth = 1;
                                    incYear++;
                                }else{
                                    incMonth++;
                                }
                            }
                        }
                    }
                }
                
                if(newRentScheduleList.size()>0){
                    rentScheduleList.addAll(newRentScheduleList);
                }
            }*/
            
            insert rentScheduleList;
        }
    //}
}