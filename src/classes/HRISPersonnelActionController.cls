public class HRISPersonnelActionController {
    
    public HRISPersonnelActionController(){
        
    }
    
    public static void createEmployeeChecklist(List <Personnel_Action__c> triggerList, List <Personnel_Action__c> oldtriggerList){
        List <Personnel_Action__c> paList = new List<Personnel_Action__c>();
        List <Master_Checklist_Item__c> onBoardingMCIList = HRISUtil.getMasterChecklistItembyType(HRISUtil.HRIS_Corporate_Onboarding);
        List <Master_Checklist_Item__c> offBoardingMCIList = HRISUtil.getMasterChecklistItembyType(HRISUtil.HRIS_Corporate_Offboarding);
        List <Employee_Checklist__c> ecList = new List<Employee_Checklist__c>();
        Map <Id, Personnel_Action__c> palistmap = null;
        
        if(oldtriggerList != null){
            palistmap = new Map <Id, Personnel_Action__c>(oldtriggerList);
            
            for(Personnel_Action__c pa : triggerList){
                if(pa.Approval_Status__c == HRISUtil.HRIS_Approval_Approved && (palistmap.get(pa.Id).Approval_Status__c != pa.Approval_Status__c)){
                    paList.add(pa);
                }     
            }   
        }
        
        for(Personnel_Action__c pa : paList){
            
            if(pa.Checklist_Type__c == HRISUtil.HRIS_Onboard){
                
                for(Master_Checklist_Item__c mci:onBoardingMCIList)
                {
                    Employee_Checklist__c hc = new Employee_Checklist__c();
                    hc.Job_Change__c = pa.Id;
                    hc.Attachment__c = mci.Attachment__c;
                    hc.Description__c = mci.Description__c;
                    hc.S_N__c = mci.S_N__c;
                    hc.Team_In_Charge__c = mci.Team_In_Charge__c;
                    hc.department__c = mci.Department__c;
                    hc.Assign_To_Team__c = mci.Assign_To_Team__c;
                    ecList.add(hc);           
                }
                
            }else if(pa.Checklist_Type__c == HRISUtil.HRIS_Offboard) {
                
                if(pa.Checklist_Type__c == HRISUtil.HRIS_Offboard){
                    for(Master_Checklist_Item__c mci:offBoardingMCIList)
                    {
                        Employee_Checklist__c hc = new Employee_Checklist__c();
                        hc.Job_Change__c = pa.Id;
                        hc.Attachment__c = mci.Attachment__c;
                        hc.Description__c = mci.Description__c;
                        hc.S_N__c = mci.S_N__c;
                        hc.Team_In_Charge__c = mci.Team_In_Charge__c;
                        hc.department__c = mci.Department__c;
                        hc.Assign_To_Team__c = mci.Assign_To_Team__c;
                        ecList.add(hc);           
                    }
                } 
            }
            
        }
        
        upsert ecList;
    }
    
    public static void insertContact(List <Personnel_Action__c> triggerList){

         for(Personnel_Action__c pa : triggerList){ 
             
             if(pa.Employee__c == null){
                 
                 Contact con = new Contact();

                 con.FirstName = pa.First_Name__c;
                 con.LastName = pa.Last_Name__c;
                 con.Division__c = pa.Division__c;
                 con.Department = pa.Department__c;
                 con.Position__c = pa.Position__c;
                 con.Job_Level__c = pa.Job_Level__c;
                 con.Date_Join__c = pa.Date_of_Join__c;
                 con.Employee_No__c = pa.Employee_No__c;
                 con.AccountId = HRISUtil.getAccountIdbyProperty(pa.Property__c);  
                 con.Company_Hotel_Name__c = HRISUtil.getCompanyHotelName(pa.Property__c);  
                 con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
                 insert con;
                 
                 pa.Employee__c = con.Id;
                 
             }
             
         }
    }
    
    public static void updateContact(List <Personnel_Action__c> triggerList, List <Personnel_Action__c> oldtriggerList){
        
        Map <Id, Personnel_Action__c> palistmap = new Map <Id, Personnel_Action__c>(oldtriggerList);
        List <Contact> conlist = new List<Contact>();
        
        for(Personnel_Action__c pa : triggerList){ 
            Contact con = new Contact();
            con.Id = pa.Employee__c;
            if(pa.Approval_Status__c == HRISUtil.HRIS_Approval_Approved && (palistmap.get(pa.Id).Approval_Status__c != pa.Approval_Status__c) && pa.Status__c != HRISUtil.HRIS_Job_Change)
                con.Employee_Status__c = HRISUtil.HRIS_Hire_Const;
            
            if(pa.Status__c == 'Accept Offer' && pa.Approval_Status__c == HRISUtil.HRIS_Approval_Approved){
                if(pa.Date_of_Join__c != palistmap.get(pa.Id).Date_of_Join__c){
                    con.Date_Join__c = pa.Date_of_Join__c;
                }
                
                if(pa.Employee_No__c != palistmap.get(pa.Id).Employee_No__c){
                    con.Employee_No__c = pa.Employee_No__c;
                }
            }
        }

        update conlist;
    }

    /*
    public static void submitForApproval(List <Personnel_Action__c> triggerList, List <Personnel_Action__c> oldtriggerList){
        
        Map <Id, Personnel_Action__c> palistmap = null;
        if(oldtriggerList != null){
            palistmap = new Map <Id, Personnel_Action__c>(oldtriggerList);
            for(Personnel_Action__c pa : triggerList){           
                if(pa.Approval_Status__c == 'New' && pa.Status__c == 'New'){
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(pa.Id);
                    Approval.ProcessResult result = Approval.process(psr); 
                }
            }
        }else{
            for(Personnel_Action__c pa : triggerList){           
                if(pa.Approval_Status__c == 'New' && pa.Status__c == 'Job Change'){
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(pa.Id);
                    Approval.ProcessResult result = Approval.process(psr); 
                }
            }
        }
    }*/
 
}