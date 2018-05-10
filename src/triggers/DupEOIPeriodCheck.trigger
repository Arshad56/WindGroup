trigger DupEOIPeriodCheck on Expression_of_Interest__c (before insert, before update) {
    Set<Id> untIds = new Set<Id>();
    for(Expression_of_Interest__c eoi:Trigger.New){
        if(eoi.Unit_No__c!=null){
            untIds.add(eoi.Unit_No__c);
        }
    }
    List<Lease_Unit__c>  listOfLU = [Select id,Name,Unit__c,Fit_Out_Date__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where Unit__c in:untIds and Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled'];
    List<LOI_Unit__c> listLOIUnit = [select Id, Name, LOI_Start_Date__c,LOI_End_Date__c,Unit__c from LOI_Unit__c where Unit__c =: untIds and LOI_Agreement_No__r.LOI_Status__c !='Expired' and LOI_Agreement_No__r.LOI_Status__c !='Cancelled'];
    //List<Expression_of_Interest__c> eoiList = [Select id,Name,Unit_No__c,Commencement_Date__c,Expiry_Date__c from Expression_of_Interest__c where Unit_No__c in:untIds];
    
    Map<Id,List<Lease_Unit__c>> unitToLeaseUntMap = new Map<Id,List<Lease_Unit__c>>();
    Map<Id,List<LOI_Unit__c>> unitToLOIUntMap = new Map<Id,List<LOI_Unit__c>>();
    //Map<Id,List<Expression_of_Interest__c>> unitToEOIUntMap = new Map<Id,List<Expression_of_Interest__c>>();
    
    Boolean errorPopulated = false; 
    
    /*for(Expression_of_Interest__c eoi:eoiList){
        List<Expression_of_Interest__c> tempList = new List<Expression_of_Interest__c>();
        if(unitToEOIUntMap.containsKey(eoi.Unit_No__c)){
            tempList.addAll(unitToEOIUntMap.get(eoi.Unit_No__c));
        }
        tempList.add(eoi);
        unitToEOIUntMap.put(eoi.Unit_No__c,tempList);
    }*/
    for(Lease_Unit__c lu:listOfLU){
        List<Lease_Unit__c> tempList = new List<Lease_Unit__c>();
        if(unitToLeaseUntMap.containsKey(lu.Unit__c)){
            tempList.addAll(unitToLeaseUntMap.get(lu.Unit__c));
        }
        tempList.add(lu);
        unitToLeaseUntMap.put(lu.Unit__c,tempList);
    }
    for(LOI_Unit__c lu:listLOIUnit){
        List<LOI_Unit__c> tempList = new List<LOI_Unit__c>();
        if(unitToLOIUntMap.containsKey(lu.Unit__c)){
            tempList.addAll(unitToLOIUntMap.get(lu.Unit__c));
        }
        tempList.add(lu);
        unitToLOIUntMap.put(lu.Unit__c,tempList);
    }
    
    for(Expression_of_Interest__c eoi:Trigger.New){
        if(eoi.Expiry_Date__c != null && eoi.Commencement_Date__c != null){
            //String tempEOIerror='';
            String tempLOIerror='';
            String tempLeaseerror='';
            /*if(unitToEOIUntMap.containsKey(eoi.Unit_No__c))
                for(Expression_of_Interest__c prevEOI:unitToEOIUntMap.get(eoi.Unit_No__c)){
                    if(prevEOI.name != eoi.name && (prevEOI.Commencement_Date__c <= eoi.Expiry_Date__c && eoi.Commencement_Date__c <= prevEOI.Expiry_Date__c) ){
                        If(tempEOIerror == '')
                            tempEOIerror = 'EOI for this duration already exist.';
                        //eoi.addError('LOI Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+loi.Id+'">'+loi.Name+'</a> to view details.',false);
                        tempEOIerror += '<br/><a target="_blank" href="/'+prevEOI.Id+'">'+prevEOI.Name+'</a> ';
                    }
                }*/
            if(unitToLOIUntMap.containsKey(eoi.Unit_No__c))
                for(LOI_Unit__c loi:unitToLOIUntMap.get(eoi.Unit_No__c)){
                    if((loi.LOI_Start_Date__c <= eoi.Expiry_Date__c && eoi.Commencement_Date__c <= loi.LOI_End_Date__c) ){
                        If(tempLOIerror == '')
                            tempLOIerror = 'LOI Unit for this duration already exist.';
                        //eoi.addError('LOI Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+loi.Id+'">'+loi.Name+'</a> to view details.',false);
                        tempLOIerror += '<br/><a target="_blank" href="/'+loi.Id+'">'+loi.Name+'</a> ';
                    }
                }
            if(unitToLeaseUntMap.containsKey(eoi.Unit_No__c))
                for(Lease_Unit__c lu:unitToLeaseUntMap.get(eoi.Unit_No__c)){
                    errorPopulated = false;
                    if((lu.Lease_Start_Date__c <= eoi.Expiry_Date__c && eoi.Commencement_Date__c <= lu.Lease_End_Date__c) ){
                        If(tempLeaseerror == '')
                            tempLeaseerror = 'Lease Unit for this duration already exist.';
                        tempLeaseerror += '<br/><a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a>';  
                        errorPopulated = true;
                        //eoi.addError('Lease Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a> to view details.',false);
                    }
                    if(!errorPopulated && lu.Fit_Out_Date__c != null && lu.Fit_Out_Date__c <= eoi.Expiry_Date__c && eoi.Commencement_Date__c <= lu.Lease_End_Date__c){
                        If(tempLeaseerror == '')
                            tempLeaseerror = 'Lease Unit for this duration already exist.';
                        tempLeaseerror += '<br/><a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a>';  
                        //eoi.addError('Lease Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a> to view details.',false);
                    }
                }
            if( tempLeaseerror != '' || tempLOIerror != ''){
                String fullError = '';
                //fullError += tempEOIerror;
                fullError += (tempLOIerror !='' && fullError!='')?'<br/>':'';
                fullError += tempLOIerror;
                fullError += (tempLeaseerror !='' && fullError!='')?'<br/>':'';
                fullError += tempLeaseerror;
                eoi.addError(fullError,false);
            }
        }
        
    }
    
}