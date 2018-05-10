@isTest
//global class RentRollupBatch implements Database.Batchable<sObject>,Schedulable 
public class RentRollupBatch{/*
    global void execute(SchedulableContext sc){
        Database.executeBatch(new RentRollupBatch(),Integer.valueOf(label.RentRollBatchSize));
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer currentMonth = system.today().Month();
        Integer currentYear = system.today().Year();
        return Database.getQueryLocator([Select id,Rent_Roll__c,Amount__c,Unit__r.Property__c,Property__c,recordType.Name,Billing_Date__c from Rent_Schedules__c where Calendar_Month(Billing_Date__c)=:currentMonth and Calendar_Year(Billing_Date__c)=:currentYear and Rent_Roll__c=null order by Property__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<Rent_Schedules__c> scope) {
        Set<Id> PropIds = new Set<Id>();
        Map<Date,Map<Id,List<Rent_Schedules__c>>> DateToPropRentSchMap = new Map<Date,Map<Id,List<Rent_Schedules__c>>>();
        for(Rent_Schedules__c rs:Scope){
            Map<Id,List<Rent_Schedules__c>> tempMap = new Map<Id,List<Rent_Schedules__c>>();
            if(DateToPropRentSchMap.containsKey(rs.Billing_Date__c)){
                tempMap = DateToPropRentSchMap.get(rs.Billing_Date__c);
            }
            List<Rent_Schedules__c> tempList = new List<Rent_Schedules__c>();
            if(tempMap.containsKey(rs.Unit__r.Property__c)){
                tempList.addAll(tempMap.get(rs.Unit__r.Property__c));
            }
            tempList.add(rs);
            tempMap.put(rs.Unit__r.Property__c,tempList);
            PropIds.add(rs.Unit__r.Property__c);
            DateToPropRentSchMap.put(rs.billing_Date__c,tempMap);
        }
        
        if(DateToPropRentSchMap.size()>0){
            Map<Id,decimal> propToAreaMap = new Map<Id,Decimal>();
            List<Lease_Unit__c> leaseUnits = [Select id,Area_Sq_Ft__c,Unit__r.Property__c from Lease_Unit__c where Unit__r.Property__c in:PropIds and Area_Sq_Ft__c!=null];
            for(Lease_Unit__c lu:leaseUnits){
                decimal tempValue = 0;
                if(propToAreaMap.containsKey(lu.Unit__r.Property__c)){
                    tempValue = propToAreaMap.get(lu.Unit__r.Property__c);
                }
                tempValue += lu.Area_Sq_Ft__c;
                propToAreaMap.put(lu.Unit__r.Property__c,tempValue);
            }
            List<RentWrapper> rentWrapList = new List<RentWrapper>();
            for(Date dt:DateToPropRentSchMap.keyset()){
            for(Id propId:DateToPropRentSchMap.get(dt).keyset()){
                Rent_Roll__c rrRent = new Rent_Roll__c();
                rrRent.Property__c = propId;
                rrRent.Rent_Roll_Date__c = dt;
                if(propToAreaMap.containsKey(propId)){
                    rrRent.Total_Leased_Area_Sq_Ft__c = propToAreaMap.get(propId);
                }
                
                rrRent.Total_Amount__c = 0;
                
                Rent_Roll__c rrUtility = new Rent_Roll__c();
                rrUtility.Property__c = propId;
                rrUtility.Rent_Roll_Date__c = dt;
                if(propToAreaMap.containsKey(propId)){
                    rrUtility.Total_Leased_Area_Sq_Ft__c = propToAreaMap.get(propId);
                }
                
                rrUtility.Total_Amount__c = 0;
                
                RentWrapper rw = new RentWrapper();
                for(Rent_Schedules__c rs:DateToPropRentSchMap.get(dt).get(propId)){
                    if(rrRent.Name==null){
                        rrRent.Name = rs.Property__c + '-' + dt.format() + '-'+label.RentScheduleRentRecordType;
                    }
                    if(rrUtility.Name==null){
                        rrUtility.Name = rs.Property__c + '-' + dt.format() + '-'+label.RentScheduleMonthlyRecordType;
                    }
                    if(rs.recordType.Name==label.RentScheduleRentRecordType){
                        if(rs.Amount__c!=null){
                            rrRent.Total_Amount__c += rs.Amount__c;
                        }
                        rw.rentSchedulesForRent.add(rs); 
                    }else if(rs.recordType.Name==label.RentScheduleMonthlyRecordType){
                        if(rs.Amount__c!=null){
                            rrUtility.Total_Amount__c += rs.Amount__c;
                        }
                        rw.rentSchedulesForUtility.add(rs); 
                    }
                }
                                
                rw.rentRollForRent = rrRent;
                rw.rentRollForUtility = rrUtility;
                
                rentWrapList .add(rw);
            }
            }
            
            if(rentWrapList.size()>0){
                List<Rent_Roll__c> rentRollList = new List<Rent_Roll__c>();
                for(RentWrapper rw:rentWrapList){
                    rentRollList.add(rw.rentRollForRent);
                    rentRollList.add(rw.rentRollForUtility);
                }
                insert rentRollList;
                
                List<Rent_Schedules__c> rentSchList = new List<Rent_Schedules__c>();
                for(RentWrapper rw:rentWrapList){                
                    if(rw.rentRollForRent.Id!=null){
                        for(Rent_Schedules__c rs:rw.rentSchedulesForRent){
                            rs.Rent_Roll__c = rw.rentRollForRent.Id;
                            rentSchList.add(rs);
                        }
                    }
                    if(rw.rentRollForUtility.Id!=null){
                        for(Rent_Schedules__c rs:rw.rentSchedulesForUtility){
                            rs.Rent_Roll__c = rw.rentRollForUtility.Id;
                            rentSchList.add(rs);
                        }
                    }
                }
                update rentSchList;
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){}
    
    class RentWrapper{
        Rent_Roll__c rentRollForRent;
        Rent_Roll__c rentRollForUtility;
        List<Rent_Schedules__c> rentSchedulesForRent;
        List<Rent_Schedules__c> rentSchedulesForUtility;
        rentWrapper(){
            rentRollForRent = new Rent_Roll__c();
            rentRollForUtility = new Rent_Roll__c();
            rentSchedulesForRent = new List<Rent_Schedules__c>();
            rentSchedulesForUtility = new List<Rent_Schedules__c>();
        }
    }*/
}