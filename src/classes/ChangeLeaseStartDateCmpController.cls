public class ChangeLeaseStartDateCmpController {
    @AuraEnabled
    public static List<string> getLeaseTenureMonths(){
        List <String> allOpts = new list <String> ();
        Sobject object_name = new Lease__c();
        String field_name = 'Lease_Tenure_Days__c';
        
        
        Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list            
            allOpts.add(a.getValue()); //add the value and label to our final list
        }
        
        return allOpts;
    }
    
    @AuraEnabled
    public static Lease__c getLease(String recordId){
        Lease__c ls = [select Id, Lease_Status__c, Lease_Tenure_Mths__c, Lease_Tenure_Days__c, Original_End_Date__c, Lease_Start_Date__c from Lease__c where Id =: recordId];
        ls.Lease_Start_Date__c = System.today();
        return ls;
    }
    
    @AuraEnabled
    public static String saveLeaseRec(Lease__c l){
        try{
            l.Change_Lease_Start_Date__c = true;
            update l;
            return 'Success';
        }catch(Exception e){            
            System.debug('###Lease Change Date Exception Occured:' + e.getMessage());
            return 'Error :'+e.getMessage();
        }
    }
}