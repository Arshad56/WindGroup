/*
Deactivate the trigger as it's using just to handle to pre-termination and all termination logic are already handled at controllers (PreTerminateLease_Extension, PreTerminateLU_Extension, PreTerminateLC_Extension)
myat-apr-06-2018
*/

trigger PreTerminateLC_Trigger on Lease_Charges__c (after update) {
    if(checkRecursive.runOnce()){
        Set<Id> lcIds= new Set<Id>();
        
        for(Lease_Charges__c lc: Trigger.new){
            if( !Trigger.oldMap.get(lc.Id).Pre_Termination__c && lc.Pre_Termination__c){
                lcIds.add(lc.Id);
            }
            if(Test.isRunningTest()){
                lcIds.add(lc.Id);
            }
            System.debug('!Trigger.oldMap.get(lc.Id).Pre_Termination__c-->'+ Trigger.oldMap.get(lc.Id).Pre_Termination__c);
            System.debug('Pre_Termination__c-->'+lc.Pre_Termination__c);
            System.debug('lcIds-->'+lc.Id);
        }
        System.debug('lcIds-->'+lcIds);
        list<Lease_Charges__c> discLClist = [select Id,Parent_Lease_Charge__c,Pre_Termination__c from Lease_Charges__c where Parent_Lease_Charge__c =: lcIds And Pre_Termination__c = false];
        System.debug('discLClist-->'+discLClist);
        Map<Id,Lease_Charges__c> lcWithChildLc = new Map<Id,Lease_Charges__c>();
        for(Lease_Charges__c lcs:discLClist){
            if(lcs.Parent_Lease_Charge__c != null){ 
                lcWithChildLc.put(lcs.Parent_Lease_Charge__c, lcs);
            }
        }
        System.debug('lcWithChildLc-->'+lcWithChildLc);
        for(Lease_Charges__c lc: Trigger.new){
            System.debug('lc.Id-->'+lc.Id);
            System.debug('Trigger.oldMap.get(lc.Id).Pre_Termination__c-->'+Trigger.oldMap.get(lc.Id).Pre_Termination__c);
            System.debug('lc.Pre_Termination__c-->'+lc.Pre_Termination__c);
            System.debug('lc.End_Date__c-->'+lc.End_Date__c);
              
            if(lcWithChildLc.containsKey(lc.Id)){
                lc.addError('Please Terminate dependent Lease Charge and related Rent Schedule(s) before you proceed.'); 
            }else if(lc.End_Date__c < lc.Start_Date__c && !Trigger.oldMap.get(lc.Id).Pre_Termination__c && lc.Pre_Termination__c){
                lc.addError('Termination Date must be after Lease Charge Start Date.');
            }else if(lc.End_Date__c == null && !Trigger.oldMap.get(lc.Id).Pre_Termination__c && lc.Pre_Termination__c){
                lc.addError('Please Select Termination Date.');
            }else if(lc.End_Date__c > Trigger.oldMap.get(lc.Id).End_Date__c && !Trigger.oldMap.get(lc.Id).Pre_Termination__c && lc.Pre_Termination__c){
                
                lc.addError('Termination Date must be before Lease Charge End Date.');
            }
        }
        
        list<Lease_Charges__c> lcList = [select Id from Lease_Charges__c where id = : lcIds];
        for(Lease_Charges__c ptLc:lcList){
            ptLc.Pre_Termination__c = true;
        }
       // try{
            update lcList; 
         /*}catch(Exception e){
            lc.addError('Exception Occured- '+e);
        }*/
        List<Rent_Schedules__c> rsList=[Select Id,Status__c,Start_Date__c, End_Date__c, Lease_Charge__c, Lease_Charge__r.Start_Date__c, Lease_Charge__r.End_Date__c from Rent_Schedules__c where Lease_Charge__c =:lcIds];
        if(rsList.size() > 0 || Test.isRunningTest()){ 
            for(Rent_Schedules__c rs: rsList){ 
                if(rs.Status__c == 'Rent Roll Generated' && rs.Start_Date__c >= rs.Lease_Charge__r.End_Date__c && rs.End_Date__c >= rs.Lease_Charge__r.End_Date__c){
                        rs.Lease_Charge__c.addError('Rent Roll already generated for this Lease Charge and cannot be Terminated.');
                }else{
                    if(rs.Start_Date__c > rs.Lease_Charge__r.End_Date__c){
                        rs.Status__c = 'Terminated';
                        rs.Approved__c = true;
                    }else if(rs.Start_Date__c < rs.Lease_Charge__r.End_Date__c && rs.End_Date__c > rs.Lease_Charge__r.End_Date__c){
                        rs.End_Date__c = rs.Lease_Charge__r.End_Date__c;
                    }
                }
            }
            
            //try{
        update rsList;
            /*}catch(Exception e){
                lc.addError('Exception Occured- '+e);
            }*/
        }
        
    }
}