trigger CalcRentScheduleAmount on Rent_Roll__c (after update) {
    Map<Id,Rent_Roll__c> rentRollMap = new Map<Id,Rent_Roll__c>();
    for(Rent_Roll__c rr:Trigger.New){
        if(rr.Total_Diesel_Rate__c!=null && rr.Total_Leased_Area_Sq_Ft__c!=null && (rr.Total_Diesel_Rate__c!=Trigger.oldMap.get(rr.Id).Total_Diesel_Rate__c || rr.Total_Leased_Area_Sq_Ft__c!=Trigger.OldMap.get(rr.Id).Total_Leased_Area_Sq_Ft__c)){
            rentRollMap.put(rr.Id,rr);
        }
    }
    if(rentRollMap.size()>0){
        List<Rent_Schedules__c> rentSchList = [Select id,Rent_Roll__c,Amount__c,Area_ft__c from Rent_Schedules__c where Rent_Roll__c in:rentRollMap.keyset() and Area_ft__c!=null and Lease_Charge__r.Charge_Type__c='Generator' and Lease_Charge__r.Type__c='Special'];
        for(Rent_Schedules__c rs:rentSchList){
            if(rentRollMap.containsKey(rs.Rent_Roll__c)){
                Rent_Roll__c rntRl = rentRollMap.get(rs.Rent_Roll__c);
                rs.Amount__c = (rntRl.Total_Diesel_Rate__c/rntRl.Total_Leased_Area_Sq_Ft__c)*rs.Area_ft__c;
            }
        }
        update rentSchList;
    }
}