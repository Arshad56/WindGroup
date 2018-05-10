/*
*    Name           :    Custom Contact Lookup controller Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Custom Contact Lookup controller.
*/
@isTest
public class CustomContactLookupControllerTest {
	@isTest
    static void methodCustomLookup(){
        
        //-----------------------------Setting up parameters--------------------------
        Test.setCurrentPageReference(new PageReference('Page.CustomContactLookup'));
        System.currentPageReference().getParameters().put('lksrch','te\'st');
        
        //---------------------------------controller---------------------------------
      	CustomContactLookupController cntr= new CustomContactLookupController();
        cntr.getFormTag();
        cntr.getTextBox();
        cntr.Search();
        cntr.saveContact();
    }
}