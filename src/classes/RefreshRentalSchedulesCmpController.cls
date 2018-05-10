public class RefreshRentalSchedulesCmpController {
    @AuraEnabled
    public static String  refreshRentalShc(String recordId) {
        try{
            Rent_Schedules__c rs = new Rent_Schedules__c(Id = recordId);
            update rs;
            return 'Success';
        }catch(Exception e){
            return 'Error: '+e.getMessage();           
        }
    }
}