/*
*    Name           :    Custom LOI Unit Template Lookup controller Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Custom LOI Unit Template Lookup controller.
*/
@isTest
public class CustomLOIUnitTemplateLookupContrTest {
	@isTest
    static void methodCustomLookup(){
        //-------------------------Data Insert----------------------------------------
        property__c pr=new property__c();
        pr.name='test Property';
        insert pr;
        
        Level__c le=new Level__c();
        le.name='test level';
        le.Property__c=pr.id;
        insert le;
        
        Units__c unt=new Units__c();
        unt.name='test unit';
        unt.Property__c=pr.id;
        unt.Level__c=le.id;
        insert unt;
    
        //-----------------------------Setting up parameters--------------------------
        Test.setCurrentPageReference(new PageReference('Page.CustomLOIUnitTemplateLookup'));
        System.currentPageReference().getParameters().put('lksrch','te\'st');
        System.currentPageReference().getParameters().put('untId',unt.id);
  	    System.currentPageReference().getParameters().put('prop',pr.id);
      	
        //---------------------------------controller---------------------------------
        CustomLOIUnitTemplateLookupController cntr= new CustomLOIUnitTemplateLookupController();
        cntr.getFormTag();
        cntr.getTextBox();
        cntr.Search();
        
    }
}