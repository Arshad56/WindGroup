public class GenerateLpPropertyCmpController {
    @AuraEnabled
    public static List<string> getYearOptions(String recordId){
        List<string> yearOptions = new List<string>();
        
        Property__c prop = new Property__c();
        for(Property__c prp: [select Id,End_Year__c from Property__c where Id =: recordId]){
            prop = prp;
        }
        Integer tempYear = prop.End_Year__c != null ? Integer.valueOf(prop.End_Year__c):System.today().year()-1;
        
        for(Integer i=0; i<=15;i++){
            if(tempYear < 2030)
                yearOptions.add(++tempYear+'');
        }
        return yearOptions;
    }
    @AuraEnabled
    public static string updateProperty(String recordId, String selYear) {
        String msg = 'Success';
        try{
            Property__c prp = new Property__c(Id=recordId, End_Year__c=selYear);
            update prp;
        }catch(Exception e){
            msg = 'Error: '+e.getMessage();
        }
        return msg;
    }  
}