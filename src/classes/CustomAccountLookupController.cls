/*
*    Name           :    Custom Account Lookup controller
*    Author         :    Mohd Anas
*    Date           :    31/3/2017
*    Description    :    Controller for customised lookup to select account as well as to insert new account with one contact.
*/
public class CustomAccountLookupController {
    public String accSearchString{get;set;}
    public Account acc{get;set;}
    public Contact con{get;set;}
    public Boolean closeWindow {get;set;}
    public List<Account> accSearchResult{get;set;}
    
    //------------------------Constructor------------------------    
    public CustomAccountLookupController(){
        acc=new Account();
        con=new Contact();
        closeWindow=false;
        accSearchString = System.currentPageReference().getParameters().get('lksrch');
        if(accSearchString != NULL && accSearchString.containsAny('\'')){
            accSearchString = String.escapeSingleQuotes(accSearchString);
        }
        runAccSearch();    
    }
    
    //--------------------------Starts the search for account-----------------------
    private void runAccSearch(){
        String query = 'select id, name,Trade_Category__c,Sub_Trade_Category__c,account_type__c,Shop_Name_Printed__c,Account_Short_Name__c,Phone,billingcity,billingState,billingStreet,BillingPostalCode  from account';
        if (accSearchString != '' && accSearchString != null)
            query += ' Where name LIKE \'%' + accSearchString + '%\'';
         query +=' LIMIT 50';
        accSearchResult = Database.query(query);
        accSearchResult.sort();
        if (accSearchResult.size()==0 || accSearchResult.size()<0)
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No records found.'));

    }  
    //---------------------
    public string getFormTag(){
        return System.currentpageReference().getParameters().get('frm');
    }
    //-------------------------
    public string getTextBox(){
        return System.currentpageReference().getParameters().get('txt');
    }
    
    //--------------------Search called by the Search button-----------------------
    public pageReference Search(){
        runAccSearch();
        return null;
    }
    //------------------------Save Account & contact-----------------------
    public pageReference saveRecord(){
        if(acc.name!=NULL && acc.name!='')
            if((con.firstName!='' && con.firstName!=NULL)||(con.Phone!='' && con.Phone!=NULL) || (con.email!='' && con.email!=NULL) || (con.lastname!='' && con.lastName!=NULL))
                if(con.lastname!='' && con.lastName!=NULL){
                
                    try{
                        insert acc;
                    }
                    catch(exception e){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Info, 'Account Insert Error:'));
                    }
                    con.accountId=acc.id;
                    try{
                        insert con;
                        closeWindow=true;
                    }
                    catch(Exception e){}
                 }
                 else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Last Name of Contact is Mandatory'));
            else{
                insert acc;
                closeWindow=true;
            }
        else
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account Name field is Mandatory.'));
        
        return null;
    }
}