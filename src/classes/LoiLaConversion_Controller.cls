public with sharing class LoiLaConversion_Controller {
    public Lease__c leaseOnUI{get;set;}
    public String loiId{get;set;}
    public String messageOnScreen{get;set;}
    public Boolean closePage{get;set;}
    
    public LoiLaConversion_Controller(){
        leaseOnUI = new Lease__c();
        loiId = ApexPages.currentpage().getParameters().get('loiId');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Please select precedent lease if applicable'));
    }
    public void convertToLA(){
        //leaseOnUI.Precedent_Lease__c
        try{
            messageOnScreen = LOIConversionController.convert(loiId,leaseOnUI.Precedent_Lease__c);
            closePage = true;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Please select precedent lease if applicable'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
        
    }
    
}