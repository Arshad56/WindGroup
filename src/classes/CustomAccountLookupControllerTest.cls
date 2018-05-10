/*
*    Name           :    Custom Account Lookup controller Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Custom Account Lookup controller.
*/
@isTest
public class CustomAccountLookupControllerTest {

    @isTest
    static void methodCustomLookup(){
        
        //-----------------------------Setting up parameters--------------------------
        Test.setCurrentPageReference(new PageReference('Page.CustomAccountLookup'));
        System.currentPageReference().getParameters().put('lksrch','te\'st');
        
        //---------------------------------controller---------------------------------
      	CustomAccountLookupController cntr= new CustomAccountLookupController();
        cntr.getFormTag();
        cntr.getTextBox();
        cntr.Search();
        cntr.saveRecord();
        
        cntr.acc.name='test';
       	cntr.saveRecord();
        
        cntr.con.firstName='test';
        cntr.saveRecord();
        
        cntr.con.lastName='test';
        cntr.saveRecord();
    }

}