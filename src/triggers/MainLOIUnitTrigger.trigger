trigger MainLOIUnitTrigger on LOI_Unit__c (after insert, after update) { 
    if(Trigger.isAfter){
        Set<Id> loiUnitIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        for(LOI_Unit__c loi: Trigger.new){
            if(Trigger.isInsert && loi.Update_LOI_Plans__c){
                loiUnitIds.add(loi.Id); 
                unitIds.add(loi.Unit__c);
            }else if(Trigger.isUpdate && !Trigger.oldMap.get(loi.Id).Update_LOI_Plans__c  && loi.Update_LOI_Plans__c){
                loiUnitIds.add(loi.Id);  
                unitIds.add(loi.Unit__c);
            }
        }
        MainLOIUnitTrigger_Helper.updateLeasePlans(loiUnitIds,unitIds);
    }
}