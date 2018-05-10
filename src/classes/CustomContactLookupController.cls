/*
*    Name           :    Custom Contact Lookup controller Test 
*    Author         :    Prabhakar Joshi
*    Date           :    31/3/2017
*    Description    :    Controller for customised lookup to select contact as well as to insert new contact.
*/
/*
*    Edited By      :    Mohd Anas 
*    Description    :    Connected it with generateLOI vfpage for popping up Lookup window. 
*/
public class CustomContactLookupController {
    public string searchText{get;set;}
    public Contact cont{get;set;}
    public Boolean closeWindow {get;set;}
    public List<Contact> contactList{get;set;}
    id accId;
    
  ///-----------------------------constructor-------------------------------------------
    public CustomContactLookupController(){
        closeWindow=FALSE;
        cont=new Contact();
        accId=ApexPages.currentPage().getParameters().get('accId');
        searchText = System.currentPageReference().getParameters().get('lksrch');
        if(searchText != NULL && searchText.containsAny('\'')){
            searchText = String.escapeSingleQuotes(searchText);
        }
        search();
    }
    //-----------------------------------Save contacts----------------------------------
    public pagereference saveContact(){
      if(cont.LastName=='')
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Enter Required Field'));
        else{
          cont.accountId=accId;
          try{
            insert Cont;
          }
          catch(exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contact Insertion Failed'));
          }
          closeWindow=TRUE;
        }
       return null;
    }
    
    //------------------------------------for searching contact-----------------------------
    public pageReference search(){
        contactlist=new list<contact>();
        String query='select id,firstName,lastname,mobilephone,email,Contact_Roles__c from contact where accountId=:accId';
        
        if(searchText!='' && searchText!=NULL)
            query += ' AND name LIKE \'%' + searchText + '%\'';
        query +=' LIMIT 990';
        contactList=Database.query(query);
        
        if(contactList==null || contactList.size()==0)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Match Found'));
        return null;
    }
    
    //------------ used by vf page to send link to dom element---------------------
     public string getFormTag(){
        return System.currentpageReference().getParameters().get('frm');
    }
    
    //----------used by vf page to send link to dom element for the text box--------------
    public string getTextBox(){
        return System.currentpageReference().getParameters().get('txt');
    }
}