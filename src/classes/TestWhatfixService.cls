@isTest
Class TestWhatfixService{
    Static TestMethod void Test(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/whatfix';
        req.HttpMethod = 'GET';
        RestContext.request = req;
        RestContext.Response = res;
               
        Test.startTest();
        WhatfixService.fetchUserProfile();
        Test.StopTest();
    }
}