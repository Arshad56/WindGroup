global class GenerateCOABalance_Batch implements Database.batchable<sObject>
{
    String query,field,value;
    List<Fiscal_Period__c> fpList = new List<Fiscal_Period__c>();
    global GenerateCOABalance_Batch(Id tenantId,Id coaGrpId, Id FYId){
        field = tenantId;
        value = FYId;
        query = 'Select Id,name FROM COA_Master__c where COA_Group__c = \''+coaGrpId+'\'';
        fpList = [Select Id, name, Fiscal_Year__r.Company__r.Id from Fiscal_Period__c where Fiscal_Year__c =: FYId];
        System.debug('query--> '+query);
        System.debug('fpList--> '+fpList);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<COA_Master__c> scope){
        //Insert list for the COA_Master_FY_Balance__c
        List<COA_Master_FY_Balance__c> listCOAMastBalance = new List<COA_Master_FY_Balance__c>();
        
        List<COA_Balance__c> listCOABalance = new List<COA_Balance__c>();
        COA_Balance__c  coaBal = new COA_Balance__c();
        
        for(COA_Master__c s : scope){
        
            //Filling master object
            COA_Master_FY_Balance__c coaMstObj = new COA_Master_FY_Balance__c(
                                                 COA_Master__c = s.Id,
                                                 Fiscal_Year__c = value);
            listCOAMastBalance.add(coaMstObj); 
             
            for(Fiscal_Period__c fp: fpList){
                 coaBal = new COA_Balance__c();
                 coaBal.COA_Master_FY_Balance__r = coaMstObj; 
                 coaBal.name = fp.name+'-'+s.name;
                 coaBal.Company__c = fp.Fiscal_Year__r.Company__r.Id;
                 coaBal.COA_Master__c = s.Id;
                 coaBal.Fiscal_Period__c = fp.Id;
                 listCOABalance.add(coaBal); 
            }
        }
        if(listCOAMastBalance.size() > 0)
            insert listCOAMastBalance;
        
        if(listCOABalance.size() > 0){
            for(COA_Balance__c coBal: listCOABalance)
                coBal.COA_Master_FY_Balance__c = coBal.COA_Master_FY_Balance__r.Id; 
            
            insert listCOABalance;
            System.debug('listCOABalance.size--> '+listCOABalance.size());
            System.debug('listCOABalance--> '+listCOABalance);
        }
    }
   
    global void finish(Database.BatchableContext BC){
    }
   
}