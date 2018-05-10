public class NewUnitConditionController{
    public Conditions__c condition{get;set;}
    public NewUnitConditionController(Apexpages.StandardCOntroller sc){
        condition = new Conditions__c();
        condition = (Conditions__c)sc.getRecord();
    }
    
    public pageReference save(){
        try{
            insert condition;
            List<Checklist__c> checkLists = [Select id from Checklist__c where Unit__c=:condition.Unit__c and Type__c like '%Takeover%'];
            if(checkLists.size()>0){
                List<Checklist_Item__c> cliList = new List<Checklist_Item__c>();
                for(Checklist__c chl:checkLists){
                    Checklist_Item__c cli = new Checklist_Item__c();
                    cli.Condition__c = condition.Condition__c;
                    cli.Description__c = condition.Description__c;
                    cli.Item_Type__c = condition.Item_Type__c;
                    cli.Issue_Types__c = condition.Issue_Types__c;
                    cli.Number__c = condition.Number__c;
                    cli.SN__c = (condition.S_N__c!=null?String.valueOf(condition.S_N__c):'');
                    cli.Handover_Condition__c= condition.Id;
                    cli.Checklist__c = chl.Id;
                    cliList.add(cli);
                }
                insert cliList;
            }
            return new pageReference('/'+condition.Id);
        }catch(Exception e){
            Apexpages.AddMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));
        }
        return null;
    }
    
    public pageReference cancel(){
        if(condition.Unit__c!=null){
            return new pageReference('/'+condition.Unit__c);
        }
        return null;
    }
}