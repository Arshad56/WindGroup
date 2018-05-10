public class MainMeterTrigger_Helper {
    public static void preventUpdateManually(List<Electric_Meter__c> meterList,Map<Id, Electric_Meter__c> meterMap){
    	Boolean isSysAdmin = PreTerminate_Helper.checkSysAdm();
        Set<String> meterNos = new Set<String>();
        Set<Id> unitIds = new Set<Id>();
        for(Electric_Meter__c mtr : meterList){
            if(mtr.Meter_No__c != meterMap.get(mtr.Id).Meter_No__c ||
                mtr.Status__c != meterMap.get(mtr.Id).Status__c ||              
                mtr.Unit__c != meterMap.get(mtr.Id).Unit__c ||
                mtr.Meter_Type__c != meterMap.get(mtr.Id).Meter_Type__c ||
                mtr.Start_Date__c != meterMap.get(mtr.Id).Start_Date__c || 
                mtr.End_Date__c != meterMap.get(mtr.Id).End_Date__c){
                    
                meterNos.add('%'+meterMap.get(mtr.Id).Meter_No__c+'%');
                unitIds.add(meterMap.get(mtr.Id).Unit__c);
                
            }
        }       
        System.debug('meterNos-->'+meterNos);
        System.debug('unitIds-->'+unitIds);
        List<Rent_Schedules__c> rsList = [Select id,Electric_Meter_Number__c,Start_Date__c,End_Date__c,Charge_Type__c from Rent_Schedules__c where Unit__c =: unitIds and Electric_Meter_Number__c like: meterNos and Status__c='In-Tenancy' ];
                                    
        Map<String, List<Rent_Schedules__c>> meterWithRSList = new Map<String, List<Rent_Schedules__c>>();
        Map<Id,Units__c> unitMap = new Map<Id, Units__c>([select Id,Start_Date__c,End_Date__c from Units__c where Id =: unitIds]);
        
        for(Rent_Schedules__c rs : rsList){
        	System.debug('rs-->'+rs);
            for(String mtr: rs.Electric_Meter_Number__c.split(';')){
                String mtrChrg = mtr+'-'+rs.Charge_Type__c;
                List<Rent_Schedules__c> temp = new List<Rent_Schedules__c>();
                if(meterWithRSList.containsKey(mtrChrg))
                    temp.addAll(meterWithRSList.get(mtrChrg));
                temp.add(rs);
                
                meterWithRSList.put(mtrChrg,temp);
                System.debug('meterWithRSList-->'+mtrChrg +' --->'+ meterWithRSList.get(mtrChrg).size());
            }
        }
        
        for(Electric_Meter__c mtr : meterList){
        	Date startDt = (meterMap.get(mtr.Id).Start_Date__c == null)?unitMap.get(meterMap.get(mtr.Id).Unit__c).Start_Date__c:meterMap.get(mtr.Id).Start_Date__c;
        	Date endDt = (meterMap.get(mtr.Id).End_Date__c == null)?unitMap.get(meterMap.get(mtr.Id).Unit__c).End_Date__c:meterMap.get(mtr.Id).End_Date__c;
           
            if(mtr.Meter_No__c != meterMap.get(mtr.Id).Meter_No__c ||
            mtr.Status__c != meterMap.get(mtr.Id).Status__c ||              
            mtr.Unit__c != meterMap.get(mtr.Id).Unit__c ||
            mtr.Meter_Type__c != meterMap.get(mtr.Id).Meter_Type__c ||
            ((mtr.Start_Date__c != meterMap.get(mtr.Id).Start_Date__c || 
            mtr.End_Date__c != meterMap.get(mtr.Id).End_Date__c) && 
            !isSysAdmin)){
            	System.debug('mtr-->'+mtr);
                String mtrStr = meterMap.get(mtr.Id).Meter_No__c+'-'+meterMap.get(mtr.Id).Meter_Type__c;
                System.debug(meterWithRSList.containsKey(mtrStr) + '-mtrStr-->'+mtrStr);
                if(meterWithRSList.containsKey(mtrStr)){
                    for(Rent_Schedules__c rs: meterWithRSList.get(mtrStr)){
                    	System.debug('mtrStr-->'+mtrStr);
                        if(rs.Start_Date__c <= endDt && startDt <= rs.End_Date__c){
                            mtr.addError('There are Rent Schedules linked with the meter no. Please use "Relink Rent Schedules" to update Rent Schedules first, and then update.',false);  
                            break; 
                        }
                    }   
                }
            }/*else if(((mtr.Start_Date__c != meterMap.get(mtr.Id).Start_Date__c || mtr.End_Date__c != meterMap.get(mtr.Id).End_Date__c)) &&
                PreTerminate_Helper.checkSysAdm()){
                //pls show confirmation pop up message box  
                //"There are Rent Schedules linked with the meter no. Please make sure all Rent Schedules are settled before Update. Update now?""
            }*/
        }
    }
    public static void checkDuplicateMeters(List<Electric_Meter__c> meterList){
        Set<String> meterNo = new Set<String>();
        Set<Id> mtrIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        for(Electric_Meter__c mtr : meterList){
            if(mtr.Meter_No__c != null && mtr.Status__c == 'Active'){
                meterNo.add(mtr.Meter_No__c);
            }
            if(mtr.Unit__c != null ){
                unitIds.add(mtr.Unit__c);
            }
            mtrIds.add(mtr.Id);
        }
        System.debug('meterNo-->'+meterNo);
        System.debug('mtrIds-->'+mtrIds);
        
        Map<Id, Electric_Meter__c> allMeter = new Map<Id, Electric_Meter__c>([select Id, Name,Meter_Type__c, Meter_No__c,Unit__c, Start_Date__c, End_Date__c from Electric_Meter__c where (Id=: mtrIds OR Meter_No__c =: meterNo) And Status__c = 'Active' And Unit__r.Active__c = true  And (Start_Date__c != null OR End_Date__c != null)]);
        Map<Id, Units__c> unitMap = new Map<Id, Units__c>([select Id, Start_Date__c, End_Date__c, Active__c from Units__c where id =: unitIds And Active__c = true]);
        
        System.debug('unitMap-->'+unitMap);
        for(Electric_Meter__c mtrNw : meterList){
            System.debug('mtrNw-->'+mtrNw);
            if(mtrNw.Unit__c != null && mtrNw.Status__c == 'Active' && unitMap.containsKey(mtrNw.Unit__c)){
                for(Electric_Meter__c mtrOl :allMeter.values()){
                    System.debug('mtrNw.Unit__c-->'+mtrNw.Unit__c);
                    if(mtrNw.Start_Date__c != null && mtrNw.End_Date__c != null && mtrOl.Start_Date__c!= null && mtrOl.End_Date__c != null){
                        System.debug('mtrOl.Id-->'+mtrOl.Id);
                        System.debug('mtrOl.Meter_No__c-->'+mtrOl.Meter_No__c);
                        System.debug('mtrNw.Start_Date__c-->'+mtrNw.Start_Date__c);
                        System.debug('mtrOl.Start_Date__c-->'+mtrOl.Start_Date__c);
                        System.debug('mtrNw.End_Date__c-->'+mtrNw.End_Date__c);
                        System.debug('mtrOl.End_Date__c-->'+mtrOl.End_Date__c);
                         
                        if(mtrNw.Id != mtrOl.Id && mtrNw.Meter_No__c == mtrOl.Meter_No__c && mtrNw.Meter_Type__c == mtrOl.Meter_Type__c){
                            if(mtrNw.Start_Date__c <= mtrOl.End_Date__c && mtrOl.Start_Date__c  <= mtrNw.End_Date__c){
                                mtrNw.addError('Meter: "'+mtrOl.Meter_No__c+'" for this duration is already active.<br/>Please click on <a target="_blank" href="/'+mtrOl.Id+'">'+mtrOl.Name+'</a> to view details.',false);
                            }
                        }   
                    }
                } 
            }
        }
    }
}