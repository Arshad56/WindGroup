public class HRISEvaluationExtension {
    
    public Contact contact {get;set;}
    public Id requisiteId {get;set;}
    public Id propId {get;set;}
    public Id acctId {get;set;}
    public Id recordId {get;set;}
    public Id conId {get;set;}
    public String headerValue {get;set;}
    public String headerValue1 {get;set;}
    public String joblvl {get;set;}
    public String position {get;set;}
    public String division {get;set;}
    public String department {get;set;}
    public String employmentType {get;set;}
    public Integer rowIndex {get;set;}
    public Integer rowNumber {get;set;}
    public Blob fileBody {get;set;}
    public List <Contact> candidateList {get;set;}
    
    public HRISEvaluationExtension () { 
       rowNumber = 0;
       contact = new Contact();
       propId =ApexPages.currentpage().getParameters().get('propertyId');
       requisiteId = ApexPages.currentpage().getParameters().get('requisitionId');
       
       if(propId != null && requisiteId != null){
           candidateList = new List <Contact>();
           position = [Select Job_Description__r.Position__c from Requisition__c where Id =: requisiteId].Job_Description__r.Position__c;
           division = [Select Division__c from Requisition__c where Id =: requisiteId].Division__c;
           department = [Select Department__c from Requisition__c where Id =: requisiteId].Department__c;
           joblvl = [Select Job_Description__r.Job_Level__c from Requisition__c where Id =: requisiteId].Job_Description__r.Job_Level__c;
           employmentType = [Select Employment_Type__c from Requisition__c where Id =: requisiteId].Employment_Type__c;
           acctId = [Select ParentCompany__c from Property__c where Id = :propId].ParentCompany__c;
           recordId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
       }
        
       contact.Department = department;
       contact.Division__c = division;
       contact.Position__c = position;
       contact.Job_Level__c = joblvl;
       contact.AccountId = acctId;
       contact.Employment_Type__c = employmentType;
       contact.Employee_Status__c = 'Candidate';
       contact.RecordTypeId = recordId;
        

    }
   
    public void add(){

        if(contact.Chinese_Name_PinYin__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Last Name.'));
        }else if(contact.FirstName == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter First Name.'));
        }else{
            contact.LastName = contact.Chinese_Name_PinYin__c;
            contact.Chinese_Name_PinYin__c= '';
            candidateList.add(contact);
            headerValue = 'Action';
            headerValue1 = 'Last Name';
            contact = new Contact();
            contact.Department = department;
            contact.Division__c = division;
            contact.Position__c = position; 
            contact.Job_Level__c = joblvl;
            contact.AccountId = acctId;
            contact.Employment_Type__c = employmentType;
            contact.Employee_Status__c = 'Candidate';
            contact.RecordTypeId = recordId;    
        }
    }
    
    public PageReference complete(){

        upsert candidateList;
        conId = candidateList.get(0).Id;
        headerValue = '';
        headerValue1 ='';
        rowNumber = 0;
        return null;

    }
    
    public void deleteRow() {
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        candidateList.remove(rowIndex);
        rowNumber = 0;
        if(candidateList.isEmpty()){
            rowNumber = 0;
            headerValue = '';
            headerValue1 = '';
        }
            
   }
    
   public PageReference createEvaluation(){
             
       PageReference MyNewPage = new PageReference('/apex/HRISEvaluationInterviewForm1?propertyId=a1O7F000000MWxk&candadiateId='+conId+'&requisiteId='+requisiteId);          
       MyNewPage.setRedirect(true);
       return MyNewPage;

   }


}