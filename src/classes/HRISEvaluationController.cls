public class HRISEvaluationController {
    
    public HRISEvaluationController (){
        
    }
    
    public static void createPersonnelAction (List <Evaluation__c> triggerList, List <Evaluation__c> oldtriggerList){
        
        Map<Id, Evaluation__c> oldTriggerMap = new Map<Id, Evaluation__c>(oldtriggerList);

        List <Evaluation__c> hirelist = new List<Evaluation__c>();
        
        for(Evaluation__c ev:triggerList){
            if(ev.Final_Interview_Recommendation__c == 'Hire' && ev.Final_Interview_Recommendation__c != oldTriggerMap.get(ev.Id).Final_Interview_Recommendation__c){
                hirelist.add(ev);
            }
        }
        
        if(!hirelist.isEmpty()){
            List <Requisition__c> reqList = new List <Requisition__c>();
            List <Personnel_Action__c> paList = new List <Personnel_Action__c>();
            for(Evaluation__c ev:hirelist){
                
                Requisition__c req = [SELECT Id, Status__c FROM Requisition__c WHERE Id = :ev.Requisition_No__c limit 1];
                req.Status__c = 'Hire';
                reqList.add(req);
                
                Personnel_Action__c pc = new Personnel_Action__c();
                pc.Employee__c = ev.Candidate_Name__c;
                pc.Requisition_No__c = ev.Requisition_No__c;
                pc.Approval_Status__c = 'New';
                pc.Property__c = ev.Property__c;
                pc.Position__c = ev.Position_Applied__c;
                pc.Employment_Type__c = [Select Employment_Type__c from Requisition__c where Id =:ev.Requisition_No__c].Employment_Type__c;
                pc.Status__c = 'New'; 
                paList.add(pc);
                
            }
            update reqList;
            insert paList;
        }
            
     }

}