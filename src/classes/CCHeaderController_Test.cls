@isTest(seeAllData=false)
public with sharing class CCHeaderController_Test {
    static TestMethod void Test(){
        Test.startTest();
        
        CCHeaderController cc = new CCHeaderController();
        
        Test.stopTest();
    }
}