trigger renewLeaseStatus on Lease__c (after insert,before update,after update) {
    if(Trigger.isAfter){
        Set<Id> lsIds = new Set<Id>();
        for(Lease__c ls:Trigger.New){
            if(ls.Precedent_Lease__c!=null && (Trigger.isInsert || Trigger.oldMap.get(ls.Id).Precedent_Lease__c==null)){
                lsIds.add(ls.Precedent_Lease__c);
            }
        }
        if(lsIds.size()>0){
            List<Lease__c> lsList =[Select id,Lease_Status__c from Lease__c where id in:lsIds];
            for(Lease__c ls: lsList){
                ls.Lease_Status__c = 'Renewed';
            }
            update lsList;
        }
    }else if(Trigger.isBefore){
        Set<Id> lsIds = new Set<Id>();
        for(Lease__c ls:Trigger.New){
            if(ls.Lease_Status__c=='Expired' && Trigger.oldMap.get(ls.Id).Lease_Status__c!=ls.Lease_Status__c){
                lsIds.add(ls.Id);
            }
        }
        if(lsIds.size()>0){
            Map<Id,Boolean> renewLeaseCheckMap = new Map<Id,Boolean>();
            for(Lease__c ls:[Select id,Precedent_Lease__c from Lease__c where Precedent_Lease__c in:lsIds]){
                renewLeaseCheckMap.put(ls.Precedent_Lease__c,true);
            }
            
            for(Lease__c ls:Trigger.New){
                if(renewLeaseCheckMap.containsKey(ls.Id)){
                    ls.Lease_Status__c = 'Renewed';
                }
            }
        }
    }
}