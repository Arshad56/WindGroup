@isTest(seeAllData=false)
public with sharing class ContactRestAPI_Test {
    static testMethod void testGet() {
        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Contact';  
        req.addParameter('page', '0');
        req.addParameter('time', '1390296387');
        req.addParameter('hash', '1wer2547');

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        List<Contact> results = ContactRestAPI.getContact();

    }
    static testMethod void testPost() {
        //do request
        Account aa = new Account(Name='Test Account');
        insert aa;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Contact';  
        req.addParameter('lastName', 'abc');
        req.addParameter('email', 'a@b.com');
        req.addParameter('phone', '878778787');

        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Contact results = ContactRestAPI.createContact('abc','a@b.com','878778787');

    }
}