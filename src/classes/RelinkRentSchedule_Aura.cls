public class RelinkRentSchedule_Aura {
    @AuraEnabled
    public static Electric_Meter__c initRelink(String recordId) {
    	Electric_Meter__c elecMtrUIDt = new Electric_Meter__c();
    	elecMtrUIDt = [Select id,Meter_No__c,Unit__c,Status__c,Meter_Type__c from Electric_Meter__c where id=:recordId];
    	elecMtrUIDt.Start_Date__c = System.today();
    	return elecMtrUIDt;
    }
     @AuraEnabled
    public static String relinkRSSave(String recordId, String startDate, String endDate, String status,String oldMeterNo, String newMeterNo) {
    	System.debug('recordId-->'+recordId);
    	System.debug('startDate-->'+startDate);
    	System.debug('endDate-->'+endDate);
    	System.debug('status-->'+status);
    	
    	System.debug('oldMeterNo-->'+oldMeterNo);
    	System.debug('newMeterNo-->'+newMeterNo);
    	
    	RelinkRentSchedulesController rsc = new RelinkRentSchedulesController( recordId);
    	rsc.elecMeter = [Select id,Meter_No__c,Unit__c,Status__c,Meter_Type__c from Electric_Meter__c where id=:recordId];
    	rsc.elecMtrUIDt = new Electric_Meter__c();
    	rsc.elecMtrUIDt.Start_Date__c=Date.valueOf(startDate);
    	rsc.elecMtrUIDt.End_Date__c=Date.valueOf(endDate);
    	rsc.elecMeter.Status__c = status;
    	rsc.oldMeterNo = oldMeterNo;
    	
    	String tempStr = rsc.save();
    	tempStr = (tempStr != null)?tempStr:'Error';
    	return tempStr;
    }
}