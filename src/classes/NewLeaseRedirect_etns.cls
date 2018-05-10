public with sharing class NewLeaseRedirect_etns {
    
    private ApexPages.StandardController ctrl;
    public NewLeaseRedirect_etns(ApexPages.StandardController controllerParam){
       ctrl = controllerParam;
    }
    public PageReference Init(){
        Lease__c parentLease;
        Schema.DescribeSObjectResult s = Lease__c.SObjectType.getDescribe() ;
        String keyPrefix = s.getKeyPrefix();
        
        //Create Base Url
        String baseUrl ='/'+keyPrefix+'/e?';
        String url = baseUrl + 'Name=-- System Generated --&nooverride=1';
            
        //Property and Tenant
        String propId = 'CF00N2800000C5HbG';
        String tenId = 'CF00N2800000C5IAy';
        //String lsId = 'CF00NO0000002hf01';
        
        String recFieldId;
        //Check for parameters in url and find lookup
        for(String str:apexpages.currentpage().getparameters().keyset()){
            System.debug('Str==>'+str);
            if(str.contains('_lkid'))
                recFieldId = str.substringBefore('_lkid');
        }
        if(recFieldId == null)
            return new ApexPages.PageReference(url).SetRedirect(true);

        String recId = ApexPages.CurrentPage().GetParameters().Get(recFieldId+'_lkid');
        String recName = ApexPages.CurrentPage().GetParameters().Get(recFieldId);
        
        //If url from object other than Lease Object        
        if(Id.valueOf(recId).getSObjectType().getDescribe().getName() != 'Lease__c'){
            url += '&'+recFieldId+'='+recName+'&'+recFieldId+'_lkid'+'='+recId;
            return new ApexPages.PageReference(url).SetRedirect(true);
        }
            
        //If url from Lease then populate three fields
        parentLease = [select Id,Name,Property__c,Property__r.Name,Tenant__c,Tenant_Name__c from Lease__c where id =: recId];
        url += '&'+propId+'='+parentLease.Property__r.Name+'&'+propId+'_lkid'+'='+parentLease.Property__c;
        url += '&'+tenId+'='+parentLease.Tenant_Name__c+'&'+tenId+'_lkid'+'='+parentLease.Tenant__c;
        url += '&'+recFieldId+'='+recName+'&'+recFieldId+'_lkid'+'='+recId;
        return new ApexPages.PageReference(url).SetRedirect(true);
    }
    
}