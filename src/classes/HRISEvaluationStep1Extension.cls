public class HRISEvaluationStep1Extension{
    
    public Evaluation__c evaluation {get;set;}
    public Job_Description__c jobdes {get;set;}
    public Id jdId {get;set;}
    public Id requisiteId {get;set;}
    public Id propId {get;set;}
    public Id candadiateId {get;set;}
    public String headerValue {get;set;}
    public List<Evaluation__c> evaluationList {get;set;}
    
    public HRISEvaluationStep1Extension (ApexPages.standardController std) { 
       this.evaluation = (Evaluation__c) std.getRecord();
       //propId =ApexPages.currentpage().getParameters().get('propertyId');
       this.evaluation.Property__c = 'a1O7F000000MWxk';
       requisiteId = ApexPages.currentpage().getParameters().get('requisitionId');
       candadiateId = ApexPages.currentpage().getParameters().get('candadiateId');
       this.evaluation.Candidate_Name__c = candadiateId;
        
        if(propId != null && requisiteId != null){
           this.evaluation.Requisition_No__c = requisiteId;
           this.evaluation.Property__c = propId;
           jdId = [SELECT Job_Description__c FROM Requisition__c WHERE Id = :requisiteId].Job_Description__c;
           jobdes = [SELECT Job_Level__c, Cultural_Competency__c,Customer_Focus__c,Ethics_and_Values_Outcome__c,Execution__c, Generating_Talent_Org_Capability__c,
                     Innovation_Change__c, Innovation_and_Business_Acumen__c, Leadership__c, Managing_Execution__c, Self_Management__c,
                     Team_Work__c FROM Job_Description__c WHERE Id = :jdId];
           
            if(jobdes.Job_Level__c!= null && (jobdes.Job_Level__c == 'A-A- Corp Officer' || jobdes.Job_Level__c == 'A-B- Corp Officer' || jobdes.Job_Level__c == 'B1- Corp Sr Manager I' || jobdes.Job_Level__c == 'B2- Corp Sr Manager II' || jobdes.Job_Level__c == 'L1- Service Executive' || jobdes.Job_Level__c == '2- Sr Service Manager'))
                this.evaluation.RecordTypeId = [Select Id From RecordType where name='Level 3 - 5'].Id;
            else if(jobdes.Job_Level__c!= null && (jobdes.Job_Level__c == 'C1- Corp Manager I' || jobdes.Job_Level__c == 'C2- Corp Manager II' || jobdes.Job_Level__c == 'D1- Corp Staff I' || jobdes.Job_Level__c == 'D2- Corp Staff II' || jobdes.Job_Level__c == 'L3- Service Manager' || jobdes.Job_Level__c == 'L4- Service Leader' || jobdes.Job_Level__c == 'L5- Service Associate' || jobdes.Job_Level__c == 'L6- Trainee'))
                this.evaluation.RecordTypeId = [Select Id From RecordType where name='Level 1 - 2'].Id;
        }
    }
    
    
     
   public void search(){
       evaluationList = new List <Evaluation__c> ();
       headerValue = '';
       String query = 'Select Id, Name, Candidate_Name__c, PA_Id__c, Requisition_No__c, Position_Applied__c, Final_Interview_Recommendation__c, First_Interview_Recommendation__c, Second_Interview_Recommendation__c from Evaluation__c where property__c=\''+evaluation.Property__c+'\'';
       
       if(evaluation.Requisition_No__c != null)
           query = query + ' and Requisition_No__c=\''+evaluation.Requisition_No__c+'\'';
       if(evaluation.Candidate_Name__c != null)
           query = query + ' and Candidate_Name__c=\''+evaluation.Candidate_Name__c+'\'';
       
       query = query + ' and Final_Interview_Recommendation__c !=\'Hire\'';
       
       List<Evaluation__c> evaList = Database.query(query);
       
       if(evaList.isEmpty())
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No interview record.'));
       else{
           headerValue = 'Evaluation No';
           evaluationList = evaList;
       }
   }
    
   public PageReference createEvaluation(){
        
       if(evaluation.Requisition_No__c == null)
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Requisition No.'));
       else{
           Id jdId = [SELECT Job_Description__c FROM Requisition__c WHERE Id = :evaluation.Requisition_No__c ].Job_Description__c;
           String jobLvl = [SELECT Job_Level__c FROM Job_Description__c WHERE Id = :jdId].Job_Level__c;
           
           if(jobLvl!= null && (jobLvl == 'A-A- Corp Officer' || jobLvl == 'A-B- Corp Officer' || jobLvl == 'B1- Corp Sr Manager I' || jobLvl == 'B2- Corp Sr Manager II' || jobLvl == 'L1- Service Executive' || jobLvl == '2- Sr Service Manager')){
               
               PageReference MyNewPage = new PageReference('/apex/HRISEvaluationInterviewForm2?propertyId='+evaluation.Property__c+'&requisitionId='+evaluation.Requisition_No__c);          
               MyNewPage.setRedirect(true);
               return MyNewPage;
               
           }else if (jobLvl!= null && (jobLvl == 'C1- Corp Manager I' || jobLvl == 'C2- Corp Manager II' || jobLvl == 'D1- Corp Staff I' || jobLvl == 'D2- Corp Staff II' || jobLvl == 'L3- Service Manager' || jobLvl == 'L4- Service Leader' || jobLvl == 'L5- Service Associate' || jobLvl == 'L6- Trainee')){
               
               PageReference MyNewPage = new PageReference('/apex/HRISEvaluationInterviewForm1?propertyId='+evaluation.Property__c+'&requisitionId='+evaluation.Requisition_No__c);          
               MyNewPage.setRedirect(true);
               return MyNewPage;
           }          
       }
       return null;
   }
    
    public PageReference createCandidate(){
        
        if(evaluation.Requisition_No__c == null){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Requisition No.'));
        } else {
            PageReference MyNewPage = new PageReference('/apex/HRISEvaluationCreateCandidate?propertyId='+evaluation.Property__c + '&requisitionId=' + evaluation.Requisition_No__c);          
            MyNewPage.setRedirect(true);
            return MyNewPage;
        }
        
        return null;
  
   }
    
    public PageReference saveEva(){
         
        upsert this.evaluation;
 
        PageReference MyNewPage = new PageReference('/'+this.evaluation.Id);          
        MyNewPage.setRedirect(true);
        return MyNewPage;
        
    } 

}