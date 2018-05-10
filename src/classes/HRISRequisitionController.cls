public class HRISRequisitionController{
    
    public HRISRequisitionController(){
        
    }
    
    public static void setJobDescriptionInfo(List<Requisition__c> triggerList){
        Map<Id, Job_Description__c> jdmap = new Map <Id, Job_Description__c>([Select Other_please_specify__c, Job_Requirements__c, Cantonese__c, English__c, Other_languages__c, Computer_Skills__c from Job_Description__c]);
        
        for(Requisition__c r: triggerList){
            if(r.Job_Requirements__c == null)
                r.Job_Requirements__c = jdmap.get(r.Job_Description__c).Job_Requirements__c;
            if(r.English__c == null)
                r.English__c = jdmap.get(r.Job_Description__c).English__c;
            if(r.Cantonese__c == null)
                r.Cantonese__c = jdmap.get(r.Job_Description__c).Cantonese__c;
            if(r.Other_languages__c == null)
                r.Other_languages__c = jdmap.get(r.Job_Description__c).Other_languages__c;
            if(r.Computer_Skills__c == null)
                r.Computer_Skills__c = jdmap.get(r.Job_Description__c).Computer_Skills__c;
            if(r.Other_please_specify__c == null)
                r.Other_please_specify__c = jdmap.get(r.Job_Description__c).Other_please_specify__c;
        }
    } 
    
    public static void setRequisitionNumber(List<Requisition__c> triggerList){
        Set<Id> propertyId = new Set<Id>();
        for(Requisition__c rc:triggerList){
            propertyId.add(rc.Property__c);
        }
        
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id, Requisition_Index__c, Short_Code__c from Property__c where id in:propertyId]);
        
        String curYear = ''+system.today().Year();
        String curMonth = (system.today().month()<10?'0'+system.today().month():''+system.today().month());
        
        Map<Id,property__c> propertyMap = new Map<Id,property__c>();
        Map<Id,integer> propToIndexMap = new Map<Id,Integer>();
        for(Requisition__c rc:triggerList){
            Property__c prop = new Property__c();
            prop.Id = rc.Property__c;
            if(propToIndexMap.containsKey(prop.Id)){
                prop.Requisition_Index__c = propToIndexMap.get(prop.Id);
            }else{
                if(propMap.get(prop.Id).Requisition_Index__c == null)
                    prop.Requisition_Index__c = 1;
                else
                    prop.Requisition_Index__c = propMap.get(prop.Id).Requisition_Index__c;                  
            }
            prop.Short_Code__c = propMap.get(prop.Id).Short_Code__c;
            Integer IntIndex = 1;
            if(prop.Requisition_Index__c!=null && prop.Requisition_Index__c>0){
                intIndex = Integer.valueOf(prop.Requisition_Index__c);
            }
            
            Integer indexSize = string.valueOf(intIndex).length();
            
            string index = '';
            for(integer i =1;i<=6-indexSize;i++){
                index += '0';
            }
            index += string.valueOf(intIndex);
            prop.Requisition_Index__c = intIndex + 1;
            propToIndexMap.put(prop.Id,intIndex + 1); 
            
            propertyMap.put(prop.Id,prop);
            
            rc.Name = prop.Short_Code__c + '-RC-'+curYear+curMonth+'-'+index;
        }

        update propertyMap.values();
    }
    
    public static void checkHeadcount(List <Requisition__c> triggerList){
        Requisition__c req = triggerList.get(0);
        if(req.Number_of_Employed__c == 0)
            req.addError('Please enter Number of Employed'); 
        
        List <Headcount_Budget__c> hbList= HRISUtil.getHeadcountBudgetList(req.Property__c, req.Division__c, req.Department__c);
        if(hbList != null && !hbList.isEmpty()){
            for(Headcount_Budget__c hb :hbList){
                if(req.Department__c == hb.department__c && req.division__c == hb.division__c && req.Property__c == hb.Property__c){
                    if(req.Number_of_Employed__c > hb.Available_Headcount__c){
                        req.addError('Requisite headcount has exceeded approved headcount'); 
                    }
                }
            }
        }}
    
    public static void addHeadcountBudgetDetail(List <Requisition__c> triggerList){
        
        List <Headcount_Budget_Detail__c> hbdList = new List <Headcount_Budget_Detail__c>();
        
        for(Requisition__c r : triggerList){
            List <Headcount_Budget__c> hbList = HRISUtil.getHeadcountBudgetList(r.Property__c, r.Division__c, r.Department__c);    
            if(hbList!= null && !hbList.isEmpty()){
                Headcount_Budget_Detail__c hbd = new Headcount_Budget_Detail__c();
                hbd.Headcount_Budget__c = hbList.get(0).Id;
                hbd.Number_of_Employed__c = r.Number_of_Employed__c;
                hbd.Status__c = 'New';
                hbd.Requisition__c = r.Id;
                hbdList.add(hbd);
                
            }            
        }
        insert hbdList;
    }
    
    public static void updateHeadCountDeStatus(List <Requisition__c> triggerList, List <Requisition__c> oldtriggerList){
        
        Map <Id, Requisition__c> oldTriggerMap = new Map<Id, Requisition__c>(oldtriggerList);
        Set <Id> reqId = new Set <Id>();
        
        for(Requisition__c r : triggerList){
            if(r.Approval_Status__c == 'Approved' && r.Approval_Status__c != oldTriggerMap.get(r.Id).Approval_Status__c){
                reqId.add(r.Id);
            }
        }
        
        List <Headcount_Budget_Detail__c> hbdList = [Select Id, Status__c From Headcount_Budget_Detail__c where Requisition__c IN :reqId];
        
        if(hbdList!= null & !hbdList.isEmpty()){
            for(Headcount_Budget_Detail__c hbd: hbdList){
                hbd.Status__c = 'Approved';
            }
            
            update hbdList;
        }
        
    }
    
    public static void submitApproval(List <Requisition__c> triggerList){
        
        for(Requisition__c re: triggerList){
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.setObjectId(re.Id);
            Approval.ProcessResult result = Approval.process(psr);
        }
    }
    
    
}