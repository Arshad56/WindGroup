@isTest(seeAllData=false)
public with sharing class NewUnitConditionControllerTest {
    static testMethod void Test(){
    	property__c pr=new property__c();
        pr.name='test Property';
        pr.LOI_Unit_Index__c=2;
        pr.LOI_Index__c=2;
        pr.Deposit_Index__c=2;
        pr.short_code__c='ABC';
        pr.Witholding_Tax__c = 3;
        pr.Witholding_Tax_Limit__c = 10;
        insert pr;
        
    	Level__c le=new Level__c();
        le.name='test level';
        le.Property__c=pr.id;
        insert le;
        
        Units__c unt=new Units__c();
        unt.name='Test Unit';
        unt.Space_Type__c='Shop'; 
        unt.Property__c=pr.id;
        unt.Level__c=le.id;
        unt.NLA_SQF__c=234.32;
        unt.rent_hurdle__c = 100;
        unt.Rent_Hurdle_Lower_Limit__c = 10;
        unt.Rent_Hurdle_Upper_Limit__c = 20;
        unt.Charge_Method__c='Monthly Rate - CL';
        insert unt;
        
        Checklist_Master__c checkMasterRec = new Checklist_Master__c(Description__c='Sample');
        insert checkMasterRec;
        Checklist__c checkRec = new Checklist__c(Unit__c=unt.Id,Checklist_Master__c=checkMasterRec.Id,Last_Updated_From__c='SF',Last_Update_Date_Time__c=null,Backend_Last_Updated_DateTime__c=System.now(),Type__c='Takeover');
        insert checkRec;
         
        Conditions__c cd=new Conditions__c();
        cd.Condition__c='testConditin';
        cd.Description__c='testCondition Description';       
        cd.Unit__c=unt.Id;
        cd.S_N__c = 1;
        cd.Number__c = '1';
        cd.Item_Type__c = 'Wall';
        
        
    	ApexPages.StandardController sc = new ApexPages.StandardController(cd);
        NewUnitConditionController condContr = new NewUnitConditionController(sc);
        
        PageReference pageRef = Page.NewUnitCondition;
        pageRef.getParameters().put('id', String.valueOf(cd.Id));
        condContr.save();
        condContr.cancel();
        Test.setCurrentPage(pageRef);
    }
}