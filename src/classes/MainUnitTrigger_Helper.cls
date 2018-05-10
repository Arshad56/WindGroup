/*
*    Name             :     MainUnitTrigger_Helper 
*    Author           :     Arshad Shaikh
*    Date             :     3rd Oct 2017
*    Description      :     Helper Class to
							1. Check Duplicate Unit with same name, Gas, Phone, water and Electric Meter
							2. Validate no LU or LOI exist for Split Unit Creation
							3. Generate LP for Main Unit
							4. Generate LP for Split Unit
*/
public class MainUnitTrigger_Helper {
	public static void checkIsLUCreated(Map<Id,Units__c> newUnitList,Map<Id,Units__c> oldUnitList){
		List<Units__c> unitList = [select Id, (Select Id from Lease_Units__r where Lease_Unit_Status__c != 'Cancelled') from Units__c where id=:newUnitList.keySet()];
		for(Units__c un: unitList){
			if(un.Lease_Units__r.size() > 0 && (newUnitList.get(un.Id).NLA_SQF__c != oldUnitList.get(un.Id).NLA_SQF__c)){
				newUnitList.get(un.Id).addError('There is existing valid Lease. Please use Resurvey to update NLA.',false);
			}
		}
	}
	public static Boolean checkContains(String olMeter, String newMeter){
		System.debug('olMeter-->'+olMeter);
		System.debug('newMeter-->'+newMeter);
		List<String> olMeterNo = olMeter.split(';');
		List<String> newMeterNo = newMeter.split(';');
		System.debug('olMeterNo-->'+olMeterNo);
		System.debug('olMeterNo-->'+olMeterNo);
		for(String ol: olMeterNo){
			for(String nw: newMeterNo){
				System.debug(ol +' '+ nw+' (ol == nw)-->'+(ol == nw));
				if(ol == nw && ol != '' && nw != ''){
					return true;
				}
			}
		}
		return false;
	}
	
	public static void checkDuplicateForSplit(List<Units__c> unitist){
		Set<Id> mainUnitIds = new Set<Id>();
		for(Units__c un : unitist){
			if(un.Main_Unit__c != null){
				mainUnitIds.add(un.Main_Unit__c);
			}
		}
		Map<Id, Units__c> mainUnitLALOIMap = new Map<Id, Units__c>([select Id, Property__c, name, Start_Date__c, End_Date__c, (Select Id,name, Lease_Start_Date__c, Lease_End_Date__c,Fit_Out_Date__c From Lease_Units__r where Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled'), (Select Id,name, LOI_End_Date__c, LOI_Start_Date__c From LOI_Units__r where LOI_Agreement_No__r.LOI_Status__c !='Expired' and LOI_Agreement_No__r.LOI_Status__c !='Cancelled') From Units__c u where Id =: mainUnitIds]);
		
        String tempLeaseerror='';
        String tempLOIerror='';
		for(Units__c un : unitist){
			if(un.Main_Unit__c != null){
				for(Lease_Unit__c lu : mainUnitLALOIMap.get(un.Main_Unit__c).Lease_Units__r){
					Date stDate = (lu.Fit_Out_Date__c != null)?lu.Fit_Out_Date__c:lu.Lease_Start_Date__c;
					if((stDate <= un.End_Date__c && un.Start_Date__c <= lu.Lease_End_Date__c) ){
						If(tempLeaseerror == '')
                            tempLeaseerror = 'Lease Unit for this duration already exist Under Main Unit.';

                        tempLeaseerror += '<br/><a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a> ';
					}
				}
				for(LOI_Unit__c loi : mainUnitLALOIMap.get(un.Main_Unit__c).LOI_Units__r){
					if((loi.LOI_Start_Date__c <= un.End_Date__c && un.Start_Date__c <= loi.LOI_End_Date__c) ){
						If(tempLOIerror == '')
                            tempLOIerror = 'LOI Unit for this duration already exist Under Main Unit.';

                        tempLOIerror += '<br/><a target="_blank" href="/'+loi.Id+'">'+loi.Name+'</a> ';
					}
				}
			}
			if( tempLeaseerror != '' || tempLOIerror != ''){
                String fullError = '';
                //fullError += tempEOIerror;
                fullError += (tempLOIerror !='' && fullError!='')?'<br/>':'';
                fullError += tempLOIerror;
                fullError += (tempLeaseerror !='' && fullError!='')?'<br/>':'';
                fullError += tempLeaseerror;
                un.addError(fullError,false);
            }
		}
		
		
	}
	public static void checkDuplicateUnits(List<Units__c> unitist){
		
		Set<Id> propIds = new Set<Id>();
		Set<Id> unitids = new Set<Id>();
		for(Units__c un : unitist){
			unitids.add(un.Id);
			if(un.Property__c != null){
				propIds.add(un.Property__c);
			}
		}
		List<Units__c> oldUnitlIst = [select Id, Property__c, name, Start_Date__c, End_Date__c,Gas_Meter_No__c,Phone_Extension_No__c,Water_Meter_No__c, (Select Id,Name,Status__c,Meter_No__c,Unit__c From Electric_Meter_No__r where Status__c = 'Active') from Units__c where Active__c = true];//Property__c=: propIds And 
		List<Electric_Meter__c> eleMeterList = [Select Id,Name,Status__c,Meter_No__c,Unit__c From Electric_Meter__c where Unit__c = : unitids And Status__c = 'Active'];
		Map<String, Id> meterUnitMap = new Map<String, Id>();
		for(Electric_Meter__c ele:eleMeterList){
			meterUnitMap.put(ele.Meter_No__c,ele.Unit__c);
		}
		System.debug('meterUnitMap-->'+meterUnitMap);
		Boolean gasDuplicate;
		Boolean waterDuplicate;
		Boolean phoneDuplicate;
		for(Units__c unNw : unitist){
			
			if(unNw.Start_Date__c != null && unNw.End_Date__c != null && unNw.Active__c ){
				for(Units__c unOl :oldUnitlIst){
					gasDuplicate = false; 
					waterDuplicate = false; 
					phoneDuplicate = false;
					if(unNw.Id != unOl.Id){
						if(unNw.Property__c == unOl.Property__c && unOl.Property__c != null){
							if(unNw.name == unOl.name && (unNw.Start_Date__c <= unOl.End_Date__c && unOl.Start_Date__c <= unNw.End_Date__c) ){
								unNw.addError('Unit for this duration already exist.<br/>Please click on <a target="_blank" href="/'+unOl.Id+'">'+unOl.Name+'</a> to view details.',false);
								break;
							}
						}
						
						if(unOl.Gas_Meter_No__c != null && unNw.Gas_Meter_No__c != null ){
							 gasDuplicate = checkContains(unOl.Gas_Meter_No__c,unNw.Gas_Meter_No__c);
						}
						if(unOl.Phone_Extension_No__c != null && unNw.Phone_Extension_No__c != null ){
							 phoneDuplicate = checkContains(unOl.Phone_Extension_No__c,unNw.Phone_Extension_No__c);
						}
						if(unOl.Water_Meter_No__c != null && unNw.Water_Meter_No__c != null ){
							 waterDuplicate = checkContains(unOl.Water_Meter_No__c,unNw.Water_Meter_No__c);
						}
						
						if(gasDuplicate && (unNw.Start_Date__c <= unOl.End_Date__c && unOl.Start_Date__c <= unNw.End_Date__c)){
							unNw.addError('Gas Meter for this duration already exist.<br/>Please click on <a target="_blank" href="/'+unOl.Id+'">'+unOl.Name+'</a> to view details.',false);
							break;
						}
						if(phoneDuplicate  && (unNw.Start_Date__c <= unOl.End_Date__c && unOl.Start_Date__c <= unNw.End_Date__c)){
							unNw.addError('Phone Extension for this duration already exist.<br/>Please click on <a target="_blank" href="/'+unOl.Id+'">'+unOl.Name+'</a> to view details.',false);
							break;
						}
						if(waterDuplicate  && (unNw.Start_Date__c <= unOl.End_Date__c && unOl.Start_Date__c <= unNw.End_Date__c)){
							unNw.addError('Water Meter for this duration already exist.<br/>Please click on <a target="_blank" href="/'+unOl.Id+'">'+unOl.Name+'</a> to view details.',false);
							break;
						}
						System.debug('unOl.Electric_Meter_No__r-->'+unOl.Electric_Meter_No__r);
						for(Electric_Meter__c olEle: unOl.Electric_Meter_No__r){
							if(meterUnitMap.containsKey(olEle.Meter_No__c) && meterUnitMap.get(olEle.Meter_No__c) == unNw.Id){
								if (unNw.Start_Date__c <= unOl.End_Date__c && unOl.Start_Date__c <= unNw.End_Date__c){
									unNw.addError('Electric Meter: <a target="_blank" href="/'+olEle.Id+'">'+olEle.Meter_No__c+'</a> for this duration already exist.<br/>Please click on <a target="_blank" href="/'+unOl.Id+'">'+unOl.Name+'</a> to view details.',false);
									break;
								}
							} 
						}
					}
				} 
			}
		}
	}
    public static void createLeasePlans(List<Units__c> unitist){
        Integer totalMonths = 1;
        Set<Id> unitIds = new Set<Id>();
        Set<Id> propIds = new Set<Id>();
        for(Units__c un : unitist){
        	unitIds.add(un.Id);
        	propIds.add(un.Property__c);
        }
        Map<Id ,Property__c> mapOfProperties = new Map<Id, Property__c>([select Id,End_Year__c from Property__c where id = : propIds]);
        List<Lease_Plan__c > listExistingLp = [select Id, unit__c from Lease_Plan__c where unit__c In : unitIds ];
        Map<Id,Lease_Plan__c> mapOfLP = new Map<Id,Lease_Plan__c>();
        for(Lease_Plan__c lp : listExistingLp){
        	if(lp.unit__c != null)
        	mapOfLP.put(lp.unit__c,lp);
        }
        List<Lease_Plan__c > listLp= new List<Lease_Plan__c >();
        Lease_Plan__c lp;
        for(Units__c un : unitist){
        	if(!mapOfLP.containsKey(un.Id) && mapOfProperties.get(un.Property__c).End_Year__c != null ){
        		if(Integer.valueOf(mapOfProperties.get(un.Property__c).End_Year__c) >= un.Start_Date__c.year()){
	        		Date startDt = un.Start_Date__c;
		            Date endDt = un.End_Date__c; 
		            
		            Date propEndDate;
		            
		            if(mapOfProperties.containsKey(un.Property__c))
		            	if(mapOfProperties.get(un.Property__c).End_Year__c != null)
		            	    propEndDate = Date.newInstance(Integer.valueOf(mapOfProperties.get(un.Property__c).End_Year__c), 12, 31);
		           
		            Integer tempTotalMonths = 0;
		            
		            Date startMonth = Date.newInstance(startDt.year(), startDt.month(), 1);
                	
                	System.debug('11propEndDate-->'+propEndDate);
                	
                	propEndDate = (propEndDate != null && endDt > propEndDate)?propEndDate:un.End_Date__c;
	            	
	            	System.debug('un.Start_Date__c-->'+un.Start_Date__c);
                	System.debug('propEndDate-->'+propEndDate);
                	System.debug('endDt-->'+endDt);
                	System.debug('un.End_Date__c-->'+un.End_Date__c);
	            	
	            	while(startMonth <= propEndDate){
	                	tempTotalMonths++;
	                	startMonth = startMonth.addMonths(1);
	                	System.debug(tempTotalMonths +'startMonth-->'+startMonth);
	                }
		            
		            System.debug(un.Start_Date__c+'-'+un.End_Date__c+'-'+un.Start_Date__c.monthsBetween(un.End_Date__c)+'tempTotalMonths-->'+tempTotalMonths);
		            
		            System.debug('22tempTotalMonths-->'+tempTotalMonths);
		            for(Integer i = 1; i <= tempTotalMonths; i++){
		                lp =  new Lease_Plan__c();
		                lp.Start_Date__c = startDt;
		                Integer numberOfDays = Date.daysInMonth(startDt.year(), startDt.month());
		                Date lastDayOfMonth = Date.newInstance(startDt.year(), startDt.month(), numberOfDays);
		                if(i == (un.Start_Date__c.monthsBetween(propEndDate)+1)){
		                    lp.End_Date__c = endDt;
		                }else{
		                    lp.End_Date__c = lastDayOfMonth;
		                }
		                lp.Unit__c = un.Id;
		                lp.Status__c = 'Vacant';
		                lp.Vacant__c = true;
		                for(Integer j = 1; j <= 31; j++){
		                	if(j <= Date.daysInMonth(startDt.year(), startDt.month())){
		                		lp.put('Day_'+j+'__c',  date.NewInstance(startDt.year(),startDt.month(),j));
		                		lp.put('Status_'+j+'__c', 'Vacant');
		                	}else{
		                		lp.put('Status_'+j+'__c', 'N/A');
		                	}
		                }
		                listLp.add(lp);
		                startDt = Date.newInstance(startDt.year(), startDt.month()+1, 1);
		            }
	        	}	
        	}
        }
        try{
            insert listLp;
        }catch(Exception e){
            System.debug('Exception Occured-->'+e);
        }
    }
    public static void createLeasePlansForSplit(List<Units__c> unitist){
    	set<Id> MainUnitIds = new Set<Id>();
    	set<Id> splitUnitIds = new Set<Id>();
    	for(Units__c un: unitist){
    		MainUnitIds.add(un.Main_Unit__c);
    		splitUnitIds.add(un.Id);
    	}
    	Map<Id, Units__c> mapofUn = new Map<Id,Units__c>([Select Start_Date__c, Generate_Lease_Plans__c, End_Date__c, Active__c, Property__r.End_Year__c,
													    	(Select Id,Monthly_Budget__c,Unit__c,Start_Date__c,End_Date__c,Commited__c,Day_1__c,Day_2__c,Day_3__c,Day_4__c,Day_5__c,
															Day_6__c,Day_7__c,Day_8__c,Day_9__c,Day_10__c,
															Day_11__c,Day_12__c,Day_13__c,Day_14__c,Day_15__c,
															Day_16__c,Day_17__c,Day_18__c,Day_19__c,Day_20__c,
															Day_21__c,Day_22__c,Day_23__c,Day_24__c,Day_25__c,Day_26__c,
															Day_27__c,Day_28__c,Day_29__c,Day_30__c,Day_31__c,
															Status_1__c,Status_2__c,Status_3__c,Status_4__c,Status_5__c,Status_6__c,
															Status_7__c,Status_8__c,Status_9__c,Status_10__c,
															Status_11__c,Status_12__c,Status_13__c,Status_14__c,Status_15__c,
															Status_16__c,Status_17__c,Status_18__c,Status_19__c,Status_20__c,
															Status_21__c,Status_22__c,Status_23__c,Status_24__c,Status_25__c,
															Status_26__c,Status_27__c,Status_28__c,Status_29__c,Status_30__c,Status_31__c,
															Daily_Rate_1__c,Daily_Rate_2__c,Daily_Rate_3__c,Daily_Rate_4__c,Daily_Rate_5__c,Daily_Rate_6__c,
															Daily_Rate_7__c,Daily_Rate_8__c,Daily_Rate_9__c,Daily_Rate_10__c,
															Daily_Rate_11__c,Daily_Rate_12__c,Daily_Rate_13__c,Daily_Rate_14__c,Daily_Rate_15__c,
															Daily_Rate_16__c,Daily_Rate_17__c,Daily_Rate_18__c,Daily_Rate_19__c,Daily_Rate_20__c,
															Daily_Rate_21__c,Daily_Rate_22__c,Daily_Rate_23__c,Daily_Rate_24__c,Daily_Rate_25__c,
															Daily_Rate_26__c,Daily_Rate_27__c,Daily_Rate_28__c,Daily_Rate_29__c,Daily_Rate_30__c,Daily_Rate_31__c 
															From Lease_Plans__r) 
														From Units__c where id=:MainUnitIds]);
		Map<String,Lease_Plan__c> uniStrEndDtLP = new Map<String,Lease_Plan__c>();
		
		Map<Id,Date> unitWithLastLP = new Map<Id,Date>();
		
		//  Map of LP with Key MainUnit Id and Month year 
		//  Map of recent LP Start date
		for(Units__c un: mapofUn.values()){
			for(Lease_Plan__c mainUnLP:un.Lease_Plans__r){
				uniStrEndDtLP.put(un.Id+'-'+mainUnLP.Start_Date__c.month()+'-'+mainUnLP.Start_Date__c.year(),mainUnLP);
				if(!unitWithLastLP.containsKey(un.Id) || (unitWithLastLP.containsKey(un.Id) && unitWithLastLP.get(un.Id) < mainUnLP.Start_Date__c)){
					unitWithLastLP.put(un.Id,mainUnLP.Start_Date__c);
				}
			}
		}
		//----------
								
		Lease_Plan__c lp =  new Lease_Plan__c();	
		Lease_Plan__c lp1 = new Lease_Plan__c();
		List<Lease_Plan__c > listLp= new List<Lease_Plan__c >();	
		Set<String> mainKeySet = new Set<String>();				
		for(Units__c un: unitist){
			Integer totalMonths = 1;
			Date startDt = un.Start_Date__c;
			Date lastDateOfMainUnt = unitWithLastLP.get(un.Main_Unit__c);
			Date tempstartDt = Date.newInstance(startDt.year(), startDt.month()-1, 1);
			Date tempDate = (lastDateOfMainUnt!=null)?Date.newInstance(lastDateOfMainUnt.year(), lastDateOfMainUnt.month()+1, 1):un.Start_Date__c;
			System.debug(unitWithLastLP.get(un.Main_Unit__c)+' Max Date---Str Date '+startDt);
			
			// To create blank LP in between Slit LP start date and Last LP found  
			if(unitWithLastLP.get(un.Main_Unit__c) < startDt && (tempDate.year() < startDt.year() || (tempDate.month() < startDt.month() && tempDate.year() == startDt.year()))){
				 Date incrementDt = tempDate;
				 System.debug(tempDate.monthsBetween(startDt)+' incrementDt--> '+incrementDt);
				 for(Integer i = 0; i <= tempDate.monthsBetween(startDt); i++){
				 	lp1 = new Lease_Plan__c();
				 	lp1.Start_Date__c = Date.newInstance(incrementDt.year(), incrementDt.month(), 1);
					lp1.End_Date__c = Date.newInstance(incrementDt.year(), incrementDt.month(),  Date.daysInMonth(incrementDt.year(), incrementDt.month()));
    				lp1.Status__c = 'Vacant';
            		lp1.Vacant__c = true;
            		lp1.Unit__c = un.Main_Unit__c;
            		for(Integer j = 1; j <= 31; j++){
	                	if(j <= Date.daysInMonth(lp1.Start_Date__c.year(), lp1.Start_Date__c.month())){
	                		lp.put('Status_'+j+'__c', 'Vacant');
	                	}else{
	                		lp.put('Status_'+j+'__c', 'N/A');
	                	}
	                }
	                System.debug(' -lp1--> '+lp1);
	                if(!mainKeySet.contains(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year())){
	                	listLp.add(lp1);
	                	uniStrEndDtLP.put(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year(),lp1);
	                	mainKeySet.add(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year());
	                }
	                incrementDt = Date.newInstance(incrementDt.year(), incrementDt.month()+1, 1);
				 }
			}
			//----------
			
			Integer propEndYear = Integer.valueof(mapofUn.get(un.Main_Unit__c).Property__r.End_Year__c);
			System.debug(propEndYear+' End Year---> '+(propEndYear >= un.Start_Date__c.year()));
			System.debug(un.Start_Date__c.year()+' End11 Year---> '+un.Start_Date__c);
    		if(propEndYear >= un.Start_Date__c.year()){
    			Date endPropDay = Date.newInstance(propEndYear, 12, 31);
    			totalMonths = un.Start_Date__c.monthsBetween((un.End_Date__c <= endPropDay )?un.End_Date__c:endPropDay);
    			System.debug(' totalMonths---> '+totalMonths);
    			for(Integer i = 0; i <= totalMonths; i++){
    				// Create New LP for Split Unit
    				lp =  new Lease_Plan__c();
    				lp.Start_Date__c = (i == 0)?un.Start_Date__c:startDt;
    				lp.End_Date__c = (i == totalMonths && startDt.month() == un.End_Date__c.month() && startDt.year() == un.End_Date__c.year())?un.End_Date__c:startDt.addMonths(1).toStartofMonth().addDays(-1);
    				lp.Status__c = 'Vacant';
            		lp.Vacant__c = true;
            		lp.Unit__c = un.Id;
            		
            		// lp1 Get the existing LP or create New one Under Main Unit
            	    lp1 = new Lease_Plan__c();
            		if(uniStrEndDtLP.containsKey(un.Main_Unit__c+'-'+lp.Start_Date__c.month()+'-'+lp.Start_Date__c.year())){
    					lp1 = uniStrEndDtLP.get(un.Main_Unit__c+'-'+lp.Start_Date__c.month()+'-'+lp.Start_Date__c.year());
    				}else{
    					lp1.Start_Date__c = Date.newInstance(startDt.year(), startDt.month(), 1);
    					lp1.End_Date__c = Date.newInstance(startDt.year(), startDt.month(),  Date.daysInMonth(startDt.year(), startDt.month()));
	            		lp1.Unit__c = un.Main_Unit__c;
    				}
    				
    				lp1.Status__c = 'N/A';
    				
    				lp1.N_A__c = true;
    				System.debug(' lp1lp1---> '+lp1);
            		for(Integer j = 1; j <= 31; j++){
            			if(lp1.Id == null && j <= Date.daysInMonth(startDt.year(), startDt.month())){
		            		lp1.put('Status_'+j+'__c', 'Vacant');
		            		lp1.Status__c = 'Vacant';
		            		lp1.put('Day_'+j+'__c', (startDt+j)-1);
		            	}else if(lp1.Id == null && j > Date.daysInMonth(startDt.year(), startDt.month())){
		            		lp1.put('Status_'+j+'__c', 'N/A');
		            	}
		            	if(j <= Date.daysInMonth(startDt.year(), startDt.month()) && j >=  lp.Start_Date__c.day() && j<= lp.End_Date__c.day()){
		            		lp.put('Status_'+j+'__c', 'Vacant');
		            		lp.put('Day_'+j+'__c', (startDt+j)-1);
		            		
		            		lp1.put('Status_'+j+'__c', 'N/A');
		            		lp1.put('Day_'+j+'__c', null);
		            	}else{
		            		lp.put('Status_'+j+'__c', 'N/A');
		            	}
		            }
            		listLp.add(lp);
            		// Make sure no duplicate LP is created under Main Unit
            		if(!mainKeySet.contains(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year())){
            			listLp.add(lp1);
            			uniStrEndDtLP.put(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year(),lp1);
            			mainKeySet.add(un.Main_Unit__c+'-'+lp1.Start_Date__c.month()+'-'+lp1.Start_Date__c.year());
            		}
    				startDt = Date.newInstance(startDt.year(), startDt.month()+1, 1);
    			}
    		}
    	}
    	upsert listLp;
    	System.debug(' listLp---> '+listLp);
    }
}