/*
*    Name             :     MainUnitTrigger 
*    Author           :     Arshad Shaikh 
*    Date             :     3rd Oct 2017
*    Description      :     1. Check Duplicate Unit with same name, Gas, Phone, water and Electric Meter
                            2. Validate no LU or LOI exist for Split Unit Creation
                            3. Generate LP for Main Unit
                            4. Generate LP for Split Unit
*/
trigger MainUnitTrigger on Units__c (after insert, after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<Units__c> listMainUnits = new List<Units__c>();
        List<Units__c> listSplitUnits = new List<Units__c>();
        for(Units__c un: Trigger.new){
            System.debug('un.Active__c-->'+un.Active__c);
            if(un.Active__c){
                Boolean tempCheck = (Trigger.isInsert && un.Start_Date__c != null && un.End_Date__c != null && un.Generate_Lease_Plans__c);
                System.debug('tempCheck-->'+tempCheck);
                if(tempCheck && un.Main_Unit__c == null){
                    listMainUnits.add(un);
                }else if(tempCheck && un.Main_Unit__c != null){
                    listSplitUnits.add(un);
                }
                System.debug('listMainUnits-->'+listMainUnits);
                System.debug('listSplitUnits-->'+listSplitUnits);
                tempCheck = (Trigger.isUpdate && !Trigger.oldMap.get(un.Id).Generate_Lease_Plans__c && un.Generate_Lease_Plans__c  && un.Start_Date__c != null && un.End_Date__c != null);
                
                System.debug('tempCheck1-->'+tempCheck);
                if(tempCheck && un.Main_Unit__c == null){
                    listMainUnits.add(un);
                }else if(tempCheck && un.Main_Unit__c != null){
                    listSplitUnits.add(un);
                }
                System.debug('listMainUnits1-->'+listMainUnits);
                System.debug('listSplitUnits1-->'+listSplitUnits);
            }
        }
        System.debug('listMainUnits-->'+listMainUnits);
        System.debug('listSplitUnits-->'+listSplitUnits);
        if(listMainUnits.size() > 0)
            MainUnitTrigger_Helper.createLeasePlans(listMainUnits);
        if(listSplitUnits.size() > 0)
            MainUnitTrigger_Helper.createLeasePlansForSplit(listSplitUnits);
        
        MainUnitTrigger_Helper.checkDuplicateUnits(Trigger.new);
        MainUnitTrigger_Helper.checkDuplicateForSplit(Trigger.new);
    }
}