public class PreTerminate_Helper {
    public static Boolean checkSysAdm(){
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        
        if(MyProflieName == 'System Administrator')
            return true;
        return false;
    }
    public static Boolean validateRS(Date endDate,List<Rent_Schedules__c> rsList){
        
        for (Rent_Schedules__c rs: rsList) {
            System.debug(endDate + '--endDate-->'+rs+ ' '+(rs.Status__c == 'Rent Roll Generated') + ' '+(rs.Start_Date__c >= endDate) + ' '+(rs.End_Date__c >= endDate));
            if(rs.Status__c == 'Rent Roll Generated' && (rs.Start_Date__c >= endDate || rs.End_Date__c > endDate)){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Rent Roll already generated for this Lease Unit and cannot be Terminated.'));
                return true;
            }
        }
        System.debug( '--====================--');
        return false;
    }
    public static  void updateRS(Date endDate,List<Rent_Schedules__c> rsList){
        System.debug('endDate-->'+endDate);
        for (Rent_Schedules__c rs: rsList) {
            System.debug('rs-->'+rs);
            System.debug('111-->'+(rs.Start_Date__c > endDate) );
            System.debug('222-->'+(rs.Start_Date__c < endDate && rs.End_Date__c > endDate));
            if(rs.Status__c == 'Rent Roll Generated' && (rs.Start_Date__c >= endDate || rs.End_Date__c > endDate)){

            }else if (rs.Start_Date__c > endDate) {
                rs.Status__c = 'Terminated';
                rs.Approved__c = true;
            } else if (rs.Start_Date__c <= endDate && rs.End_Date__c >= endDate) {
                rs.End_Date__c = endDate;
            }
        }
        update rsList;
    }
}