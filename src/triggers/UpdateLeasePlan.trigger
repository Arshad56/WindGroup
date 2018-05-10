trigger UpdateLeasePlan on Lease_Charges__c (after insert,after update) {
    Map<Id,Lease_Plan__c> leasePlanMap = new Map<Id,Lease_Plan__c>();
    for(Lease_Charges__c lc:Trigger.New){
        if(lc.Start_Date__c!=null && lc.End_Date__c!=null && lc.Lease_Plan__c!=null && ((Trigger.isInsert) || (Trigger.isUpdate && lc.Generate_Rent_Schedule__c==true && (lc.Generate_Rent_Schedule__c!=Trigger.OldMap.get(lc.Id).Generate_Rent_Schedule__c || lc.Charge_Rate__c!=Trigger.OldMap.get(lc.Id).Charge_Rate__c)))){
            Lease_Plan__c lp = new Lease_Plan__c();
            if(leasePlanMap.containsKey(lc.Lease_Plan__c)){
                lp = leasePlanMap.get(lc.Lease_Plan__c);
            }else{
                lp.Id = lc.Lease_Plan__c;
            }
            
            for(Date dt=lc.Start_Date__c;dt<=lc.End_Date__c;dt=dt+1){
                lp.put('Daily_Committed_Rate_'+dt.Day()+'__c',lc.Charge_Rate__c);
            }
            leasePlanMap.put(lp.Id,lp);
        }  
    }
    if(leasePlanMap.size()>0){ 
        update leasePlanMap.values();
    }
}