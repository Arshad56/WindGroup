public with sharing class LoiCancellationController{
    public LOI__c loi{get;set;}
   
   // public string remarks{get;set;}
   // public id loiId{get;set;}
    
    public LoiCancellationController(){
    loi=[select id,name,Tenant__c,Property__c,LOI_Status__c,LOI_Start_Date__c,LOI_End_Date__c,Reason_for_Termination__c
          from LOI__c where id=:apexpages.currentpage().getparameters().get('loiId')];
       // loi=;
          //system.debug('loi-->'+loi);
     }
    public pageReference cancel(){
    
        loi.LOI_Status__c='Cancelled';
        update loi;
        return new PageReference('/' + loi.Id);
    }
}