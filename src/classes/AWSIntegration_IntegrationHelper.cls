/*
Description  : This class is created to have methods to help integration process
Date Created : 2nd Oct 2016
*/
public class AWSIntegration_IntegrationHelper
{
    public static String getAccessToken(Boolean isTestRunning, String actionType)
    {
        try{
        // Return variables
        String access_token;
        String token_type;
        String expires_in;
        String refresh_token;
        
        // AWS Credentials Variables
        String grant_type='';
        String clientid='';
        String clientsecret='';
        String username='';
        String password='';
        String EndPoint='';
        for(AWS_Credentials__c awsRec : AWS_Credentials__c.getAll().Values())
        {
            grant_type=awsRec.grant_type__c;
            clientid=awsRec.clientid__c;
            clientsecret=awsRec.clientsecret__c;
            if(actionType == 'POS')
                EndPoint=awsRec.POSEndPoint__c;
            else
            	EndPoint=awsRec.EndPoint__c;
            password=awsRec.password__c;
            username=awsRec.username__c;
        }
        if(username=='' || clientid=='' || EndPoint=='' || password=='' || clientsecret=='')
        return 'INVALID_CREDENTIALS';
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(EndPoint);
        req.setTimeout(90000); // timeout in milliseconds - this is one minute
        HttpResponse res = null;
       
         if(isTestRunning==false)
          res = h.send(req);
          else
          {
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"06ItrN57By64rx5ewACDDPRcXVB6ZeyqJhikvL9H","token_type":"Bearer","expires_in":3600,"refresh_token":"apUnV8IgA2QKU373LtKZKwWFbbAat4eggkyuHFh1"}');
            res.setStatusCode(200);
          }
        
         System.debug(res.getbody());
        // Parse JSON response to get all the totalPrice field values.
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
        (parser.getText() == 'access_token')) {
        // Get the value.
        parser.nextToken();
        // Compute the grand total price for all invoices.
        access_token= parser.getText();
        }
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
        (parser.getText() == 'token_type')) {
        // Get the value.
        parser.nextToken();
        // Compute the grand total price for all invoices.
        token_type= parser.getText();
        }
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
        (parser.getText() == 'expires_in')) {
        // Get the value.
        parser.nextToken();
        // Compute the grand total price for all invoices.
        expires_in= parser.getText();
        }
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
        (parser.getText() == 'refresh_token')) {
        // Get the value.
        parser.nextToken();
        // Compute the grand total price for all invoices.
        refresh_token= parser.getText();
        }
        }
        system.debug('access_token=' + access_token);
        system.debug('token_type=' + token_type);
        system.debug('expires_in=' + expires_in);
        system.debug('refresh_token=' + refresh_token);
        return access_token;
       }catch(Exception e)
       {
           system.debug('Exception :'+e.getMessage());
           return 'EXCEPTION:'+e.getMessage();
       } 
    }
}