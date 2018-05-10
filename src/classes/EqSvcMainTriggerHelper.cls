public class EqSvcMainTriggerHelper {
    
    public static void validateEqServiceContractNumber (List<Equipment_Service_Contract__c> triggerList, List<Equipment_Service_Contract__c> oldtriggerList){
        
        Map<Id,String> serviceContractNameMap = new Map<Id,String>();
        
        for(Equipment_Service_Contract__c sv: oldtriggerList){
            serviceContractNameMap.put(sv.Id, sv.Name);
        }
             
        for(Equipment_Service_Contract__c sv: triggerList){ 
            
            if(sv.Name!=serviceContractNameMap.get(sv.Id)){
                sv.addError('Equipment Service Contract Number is not allow to change.');
            }
        }
    }
    
    public static void setEqSeviceContractNumber(List<Equipment_Service_Contract__c> triggerList){
        Set<Id> propertyId = new Set<Id>();
        for(Equipment_Service_Contract__c sv:triggerList){
            propertyId.add(sv.Property_Id__c);
        }
        
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id, Eq_Svc_Contract_Index__c, Short_Code__c from Property__c where id in:propertyId]);
        
        string curYear = ''+system.today().Year();
        string curMonth = (system.today().month()<10?'0'+system.today().month():''+system.today().month());
  
        Map<Id,integer> propToIndexMap = new Map<Id,Integer>();
        for(Equipment_Service_Contract__c sv:triggerList){
                Property__c prop = new Property__c();
            	prop.Id = sv.Property_Id__c;
                if(propToIndexMap.containsKey(prop.Id)){
                    prop.Eq_Svc_Contract_Index__c = propToIndexMap.get(prop.Id);
                }else{
                    if(propMap.get(prop.Id).Eq_Svc_Contract_Index__c == null)
                        prop.Eq_Svc_Contract_Index__c = 1;
                    else
                        prop.Eq_Svc_Contract_Index__c = propMap.get(prop.Id).Eq_Svc_Contract_Index__c;                  
                }
                prop.Short_Code__c = propMap.get(prop.Id).Short_Code__c;
                Integer IntIndex = 1;
                if(prop.Eq_Svc_Contract_Index__c!=null && prop.Eq_Svc_Contract_Index__c>0){
                    intIndex = Integer.valueOf(prop.Eq_Svc_Contract_Index__c);
                }
                
                Integer indexSize = string.valueOf(intIndex).length();
                
                string index = '';
                for(integer i =1;i<=6-indexSize;i++){
                    index += '0';
                }
                index += string.valueOf(intIndex);
                prop.Eq_Svc_Contract_Index__c = intIndex + 1;
                propToIndexMap.put(prop.Id,intIndex + 1); 
                sv.Name = prop.Short_Code__c + '-ES-'+curYear+curMonth+'-'+index;
        }
        
        List<property__c> propList = new List<Property__c>();
        for(Property__c prop : propMap.values()){
            prop.Eq_Svc_Contract_Index__c = propToIndexMap.get(prop.Id);
            propList.add(prop);
        }
        
        update propList;
    }
    
    public static void createEquipmentServiceContract (List<Equipment_Service_Contract__c> triggerList){
        
        Map<Id,FM_Service_Contract__c> serviceContractMap = new Map <Id, FM_Service_Contract__c> ([Select Id, Service_Contract_Start_Date__c, Service_Contract_End_Date__c from FM_Service_Contract__c]);  
        
        for(Equipment_Service_Contract__c eqsc: triggerList){
            
            if(eqsc.start_date__c == null)
                eqsc.start_date__c = serviceContractMap.get(eqsc.FM_Service_Contract__c).Service_Contract_Start_Date__c;
            
            if(eqsc.end_date__c == null)
                eqsc.end_date__c = serviceContractMap.get(eqsc.FM_Service_Contract__c).Service_Contract_End_Date__c;
                     
        }
    }
    
    public static void createRequest(List<Equipment_Service_Contract__c> triggerList, List<Equipment_Service_Contract__c> oldtriggerList){
        
        List <Request__c> requestList = new List<Request__c> ();
        Map<Id,Equipment_Service_Contract__c> eqscMap = new Map <Id, Equipment_Service_Contract__c>(oldtriggerList);
       
        Id conId = [Select Id From Contact where Name = 'Operation'].Id;
            
        for(Equipment_Service_Contract__c eqsc: triggerList){
                
            if(eqsc.Create_Request__c == true && eqscMap.get(eqsc.Id).Create_Request__c == false && eqsc.Request_Start_Date__c != null){
                
                if(eqsc.property_id__c == null)
                  	return;

                List<Request__c> tempRecList = new List<Request__c>();
           		tempRecList = createRequestList (eqsc.end_date__c, eqsc.Request_Start_Date__c, eqsc);
            	requestList.addAll(tempRecList);  
                
            }
        } 
        insert requestList;
    }
    
    public static void eqscChangeDate(List<Equipment_Service_Contract__c> triggerList, List<Equipment_Service_Contract__c> oldtriggerList){
        
        Map<Id,Equipment_Service_Contract__c> eqscMap = new Map <Id, Equipment_Service_Contract__c>(oldtriggerList);
        List<Request__c> insertRequestList = new List<Request__c>();
        List<Request__c> deleteRequestList = new List<Request__c>();
        List<Request__c> tempRecList = new List<Request__c>();
        Map<Id,Date> eqEndDateMap = new Map<Id,Date>();
        Map<Id,Date> eqRequestStartDateMap = new Map<Id,Date>();
        Set<Id> eqSCId = new Set<Id>();

        for(Equipment_Service_Contract__c eqsc: triggerList){
            
            if(eqsc.Create_Request__c == true && eqsc.Request_Start_Date__c != null){
                
                if(eqsc.property_id__c == null)
                return;

                if(eqsc.Request_Start_Date__c != eqscMap.get(eqsc.Id).Request_Start_Date__c){
                    
                    if(eqsc.Request_Start_Date__c > eqscMap.get(eqsc.Id).end_date__c){
                        
                       tempRecList = createRequestList (eqsc.Request_Start_Date__c, eqsc.end_date__c, eqsc);
                       insertRequestList.addAll(tempRecList);  
                        
                    }else if(eqsc.Request_Start_Date__c > eqscMap.get(eqsc.Id).Request_Start_Date__c){
                        
                        eqRequestStartDateMap.put(eqsc.Equipment__c, eqsc.start_date__c);
                        eqSCId.add(eqsc.Id);                     
                    }                
                }
                
                if(eqsc.end_date__c != eqscMap.get(eqsc.Id).end_date__c){
                    
                    if(eqsc.end_date__c > eqscMap.get(eqsc.Id).end_date__c){
                       tempRecList = createRequestList (eqsc.end_date__c, eqscMap.get(eqsc.Id).end_date__c, eqsc);
                       insertRequestList.addAll(tempRecList); 
                    }else{
                        
                        eqEndDateMap.put(eqsc.Equipment__c, eqsc.end_date__c);
                        eqSCId.add(eqsc.Id);  
                    }
                }            
               
                List<Request__c> scRequestList = [Select Id, Action_Remarks__c, Date_Time_Opened__c, Equipment__c from request__c 
                                                  where Equipment_Service_Contract__c IN :eqSCId and Type__c = 'Scheduled'];
                
                for(Request__c req : scRequestList){
                    
                    if(req.Date_Time_Opened__c > eqEndDateMap.get(req.Equipment__c) || req.Date_Time_Opened__c < eqRequestStartDateMap.get(req.Equipment__c))
                        if(req.Action_Remarks__c == '' || req.Action_Remarks__c == null)
                            deleteRequestList.add(req);            
                } 
                
                delete deleteRequestList;
                insert insertRequestList;      
              }
                
           }     
    }
    
    private static List<Request__c> createRequestList (Date scEndDate, Date reqStartDate, Equipment_Service_Contract__c eqsc){
        Date tempDate =  reqStartDate;            
        Date endDate = scEndDate;
        String frequency = eqsc.Frequency__c;
        List <Request__c> requestList = new List<Request__c> ();
        
        requestList.add(createRequest(tempDate, eqsc));
        
        while(tempDate <= endDate){                   
            if(frequency == 'Daily')
                tempDate = tempDate.addDays(1);
            else if (frequency == 'Weekly')
                tempDate = tempDate.addDays(7);
            else if (frequency == 'Fortnightly')
                tempDate = tempDate.addDays(14);
            else if (frequency == 'Monthly')
                tempDate = tempDate.addMonths(1);
            else if (frequency == 'Bimonthly')
                tempDate = tempDate.addMonths(2);
            else if (frequency == 'Quarterly')
                tempDate = tempDate.addMonths(3);
            else if (frequency == 'Semiannually')
                tempDate = tempDate.addMonths(6);
            else if (frequency == 'Annually')
                tempDate = tempDate.addYears(1);
                    
            requestList.add(createRequest(tempDate, eqsc));
         } 
        
        return requestList;
        
    }
    
    private static Request__c createRequest (Date reqStartDate, Equipment_Service_Contract__c eqsc){

        Request__c req = new Request__c();
        req.Property__c = eqsc.Property_Id__c;
        req.Request_Origin__c = 'Web';
        req.Status__c = 'In Progress';
        req.Dept_in_Charge__c = eqsc.Department__c;
        req.Request_Type__c = eqsc.Job_Type__c;
        req.Type__c = 'Scheduled';
        req.Date_Time_Opened__c = reqStartDate;
        req.Severity__c = 'Medium';
        req.Mobile_Display__c = true;
        req.Description__c = eqsc.Description__c;
        req.Equipment__c = eqsc.Equipment__c;
        req.Checklist_Master__c = eqsc.Checklist_Id__c;
        req.Equipment_Service_Contract__c = eqsc.Id;
        
        return req;
    }
}