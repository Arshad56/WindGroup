@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRestAPI {
	@HttpGet
    global static List<Contact> getContact(){
    	return new List<Contact>();
    }
    @HttpPost
    global static Contact createContact(String lastName, String email, String phone){
    	return new Contact();
    }
  /*  
    @HttpGet
    global static List<Contact> getContact(){
        List<Contact> contacts = [select Id, Name, Email, Phone, Contact_Roles__c, NRIC__c, Password__c, Region__c, Username__c from Contact];
        
        return contacts;
    }
    
    @HttpPost
    global static Contact createContact(String lastName, String email, String phone){
        Account acc = [select Id from Account where Name = 'Test Account'];
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = lastName;
        con.Email = email;
        con.Phone = phone;
        
        insert con;
        return con;
    }
    */
}