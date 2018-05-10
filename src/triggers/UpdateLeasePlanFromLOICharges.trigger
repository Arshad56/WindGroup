trigger UpdateLeasePlanFromLOICharges on LOI_Charges__c (after insert, after update) {
    Map<Id,Lease_Plan__c> leasePlanMap = new Map<Id,Lease_Plan__c>();
    for(LOI_Charges__c loic:Trigger.New){
        if(loic.Start_Date__c!=null && loic.End_Date__c!=null && loic.Lease_Plan__c!=null && ((Trigger.isInsert) || (Trigger.isUpdate &&  loic.Charge_Rate__c!=Trigger.OldMap.get(loic.Id).Charge_Rate__c))){
            Lease_Plan__c lp = new Lease_Plan__c();
            if(leasePlanMap.containsKey(loic.Lease_Plan__c)){
                lp = leasePlanMap.get(loic.Lease_Plan__c);
            }else{
                lp.Id = loic.Lease_Plan__c;
            }
            
            for(Date dt=loic.Start_Date__c;dt<=loic.End_Date__c;dt=dt+1){
                lp.put('Daily_LOI_Rate_'+dt.Day()+'__c',loic.Charge_Rate__c);
            }
            leasePlanMap.put(lp.Id,lp);
        }  
    }
    if(leasePlanMap.size()>0){ 
        update leasePlanMap.values();
    }
}