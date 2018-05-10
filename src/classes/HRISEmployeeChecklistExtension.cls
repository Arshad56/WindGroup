public class HRISEmployeeChecklistExtension {
    
    public Personnel_Action__c pa {get;set;}
    public List <Employee_Checklist__c> employeeChecklist{get;set;}
    
    public HRISEmployeeChecklistExtension (ApexPages.standardController std) { 
       this.pa = (Personnel_Action__c) std.getRecord();

        employeeChecklist = new List <Employee_Checklist__c>();     
        employeeChecklist = HRISUtil.getHireChecklistbyId(this.pa.Id);       
    }
    
    public PageReference updateChecklist(){
        upsert employeeChecklist;
        
        return HRISUtil.getMyNewPage('HRISEmployeeChecklist', this.pa.Id);
    }

}