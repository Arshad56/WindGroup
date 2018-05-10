trigger MainTriggerRentRollDetails on Rent_Roll_Detail__c (after insert, after delete, after undelete, after update, before update) {
    Set<id> rentRollDetIdList = new Set<id>();
    Set<id> voidedIds = new Set<id>();
	if(Trigger.isAfter){
	    if(Trigger.isUndelete || Trigger.isUpdate || Trigger.isInsert){
	        for(Rent_Roll_Detail__c con1 : Trigger.new){
				System.debug('con1-->'+con1); 
	            if(Trigger.isUpdate && (con1.Rent_Roll__c == null || Trigger.oldMap.get(con1.id).Rent_Roll__c != con1.Rent_Roll__c)){
	                rentRollDetIdList.add(Trigger.oldMap.get(con1.id).Rent_Roll__c);
	                if(con1.Rent_Roll__c != null){
	                	rentRollDetIdList.add(con1.Rent_Roll__c);
	                }
	            }else{
	            	if(con1.Rent_Roll__c != null){
	                	rentRollDetIdList.add(con1.Rent_Roll__c);
	            	}
	            }
	            if(con1.Voided__c){
					voidedIds.add(con1.Id);
				}
	        }
	    }
	    if(Trigger.isDelete){
	        for(Rent_Roll_Detail__c con1 : Trigger.old){
	            rentRollDetIdList.add(con1.Rent_Roll__c);
	            if(con1.Voided__c){
					voidedIds.add(con1.Id);
				}
	        } 
	    }
	    if(rentRollDetIdList.size() > 0){
	    	MainTriggerRentRollDetails_Helper.rollupAmount(rentRollDetIdList);
	    }
	    if(voidedIds.size() > 0){
			MainTriggerRentRollDetails_Helper.makeRentScheduleBlank(voidedIds);
		}
    }
	
}