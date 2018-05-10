/*
*    Name           :    Custom Unit Lookup controller Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Custom Unit Lookup controller.
*/
@isTest
public class CustomUnitLookupControllerTest {
    @isTest
    static void methodCustomLookup(){
        //-------------------------Data Insert----------------------------------------
        
        property__c pr=new property__c();
        pr.name='test Property';
        pr.Short_Code__c='test';
        insert pr;
        
      
        Level__c lvl=new Level__c();
        lvl.Name='Test-Billing';
        lvl.Property__c=pr.Id;
        insert lvl;
        
        Units__c un=new Units__c();
        un.Name='115-A';
        un.Property__c=pr.Id;
        un.Level__c=lvl.Id;
        un.Charge_Method__c='Daily Rate';
        un.Start_Date__c=date.newInstance(2017,04,20);
        un.End_Date__c=date.newInstance(2017,12,20);
        un.Space_Type__c='shop';
        insert un;
        
       //-----------------------------Setting up parameters--------------------------
       Test.setCurrentPageReference(new PageReference('Page.CustomUnitLookup'));
        system.currentPageReference().getParameters().put('prop',pr.id);
        system.currentPageReference().getParameters().put('lksrch','te\'st');
        system.currentPageReference().getParameters().put('sdate','21/09/2017');
        system.currentPageReference().getParameters().put('edate','21/12/2017');
        system.debug(String.valueOf(un.End_Date__c));
        //---------------------------------controller---------------------------------
        CustomUnitLookupController cntr= new CustomUnitLookupController();
        cntr.getFormTag();
        cntr.getTextBox();
        cntr.Search();
        
    }
    @isTest static void myTest(){
        property__c pr=new property__c();
        pr.name='test Property';
        pr.Short_Code__c='test';
        insert pr;
        
        Level__c lvl=new Level__c();
        lvl.Name='Test-Billing';
        lvl.Property__c=pr.Id;
        insert lvl;
        
        Units__c un=new Units__c();
        un.Name='115-A';
        un.Property__c=pr.Id;
        un.Level__c=lvl.Id;
        un.Charge_Method__c='Daily Rate';
        un.Start_Date__c=date.newInstance(2017,04,20);
        un.End_Date__c=date.newInstance(2017,12,20);
        un.Space_Type__c=null;
        insert un;
        
        
        
       //-----------------------------Setting up parameters--------------------------
       Test.setCurrentPageReference(new PageReference('Page.CustomUnitLookup'));
        system.currentPageReference().getParameters().put('prop',pr.id);
        system.currentPageReference().getParameters().put('lksrch','te\'st');
        system.currentPageReference().getParameters().put('sdate','21/09/2017');
        system.currentPageReference().getParameters().put('edate','21/12/2017');
        system.debug(String.valueOf(un.End_Date__c));
        //---------------------------------controller---------------------------------
        CustomUnitLookupController cntr= new CustomUnitLookupController();
        cntr.getFormTag();
        cntr.getTextBox();
        cntr.Search();
        
    }
}