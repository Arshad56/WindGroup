public with sharing class RentScheduleCalculations_Helper {
    static Map<String, List<Date>> mapIdWithMinDates;
    static Map<String, List<Date>> mapIdWithMaxDates;
    public static void setMinMaxDate(Set<Id> rentScheduleIds){
        mapIdWithMinDates = new Map<String, List<Date>>();
        mapIdWithMaxDates = new Map<String, List<Date>>();
        
        List<AggregateResult> eleTr = [SELECT MIN(From_Date__c) minD1, MAX(To_Date__c) maxD2,Rent_Schedule__c FROM Electric_Transaction__c where Rent_Schedule__c = : rentScheduleIds GROUP BY Rent_Schedule__c];
        if(eleTr != null){
            RentScheduleCalculations_Helper.addDatesToList(eleTr);
        }
        List<AggregateResult> wtrTr = [SELECT MIN(From_Date__c) minD1, MAX(To_Date__c) maxD2,Rent_Schedule__c FROM Water_Transaction__c where Rent_Schedule__c = : rentScheduleIds GROUP BY Rent_Schedule__c];
        if(wtrTr != null){
            RentScheduleCalculations_Helper.addDatesToList(wtrTr);
        }
        List<AggregateResult> gasTr = [SELECT MIN(From_Date__c) minD1, MAX(To_Date__c) maxD2,Rent_Schedule__c FROM Gas_Transaction__c where Rent_Schedule__c = : rentScheduleIds GROUP BY Rent_Schedule__c];
        if(gasTr != null){
            RentScheduleCalculations_Helper.addDatesToList(gasTr);
        }
        List<AggregateResult> phnTr = [SELECT MIN(From_Date__c) minD1, MAX(To_Date__c) maxD2,Rent_Schedule__c FROM Phone_Transaction__c where Rent_Schedule__c = : rentScheduleIds GROUP BY Rent_Schedule__c];
        if(phnTr != null){
            RentScheduleCalculations_Helper.addDatesToList(phnTr);
        }
        Map<Id, Rent_Schedules__c> mapOfRentSchedule = new Map<Id, Rent_Schedules__c>([Select id,Transaction_Start_Date__c,Transaction_End_Date__c,Transaction_Status__c from Rent_Schedules__c where id =: rentScheduleIds]);
        for(String mp: mapIdWithMinDates.keySet()){
            mapIdWithMinDates.get(mp).sort();
        }
        for(String mp: mapIdWithMaxDates.keySet()){
            mapIdWithMaxDates.get(mp).sort();
        }
        for(Id mp: mapOfRentSchedule.keySet()){
            if(mapIdWithMinDates.get(mp) != null){
                mapOfRentSchedule.get(mp).Transaction_Start_Date__c = mapIdWithMinDates.get(mp)[0];
            }
            if(mapIdWithMinDates.get(mp) != null){
                mapOfRentSchedule.get(mp).Transaction_End_Date__c = mapIdWithMaxDates.get(mp)[mapIdWithMaxDates.get(mp).size()-1];
            }
            mapOfRentSchedule.get(mp).Transaction_Status__c = 'Applicable - Imported';
        }
        try{
            update mapOfRentSchedule.values();
        }catch(Exception e){
            System.debug('exception-->  '+e);
        }   
    }
    public static void addDatesToList(List<AggregateResult> listOfAgr){
        for(AggregateResult ag: listOfAgr){
            String idRS = String.valueof(ag.get('Rent_Schedule__c'));
            if((Date)ag.get('minD1') != null && idRS != null){
                if(RentScheduleCalculations_Helper.mapIdWithMinDates.containsKey(idRS)) {
                    List<Date> tempMinDateList = RentScheduleCalculations_Helper.mapIdWithMinDates.get(idRS);
                    tempMinDateList.add((Date)ag.get('minD1'));
                    RentScheduleCalculations_Helper.mapIdWithMinDates.put(idRS, tempMinDateList);
                } else {
                    RentScheduleCalculations_Helper.mapIdWithMinDates.put(idRS, new List<Date> { (Date)ag.get('minD1') });
                }
            }
            if((Date)ag.get('maxD2') != null && idRS != null){
                if(RentScheduleCalculations_Helper.mapIdWithMaxDates.containsKey(idRS)) {
                    List<Date> tempMaxDateList = RentScheduleCalculations_Helper.mapIdWithMaxDates.get(idRS);
                    tempMaxDateList.add((Date)ag.get('maxD2'));
                    RentScheduleCalculations_Helper.mapIdWithMaxDates.put(idRS, tempMaxDateList);
                } else {
                    RentScheduleCalculations_Helper.mapIdWithMaxDates.put(idRS, new List<Date> { (Date)ag.get('maxD2') });
                }
            }
        }
    }
}