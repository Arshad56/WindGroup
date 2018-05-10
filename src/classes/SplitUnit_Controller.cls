public class SplitUnit_Controller {
    public Units__c unitOnUI{get;set;}
    Units__c selectedUnit{get;set;}
    public List<Units__c> splitUnits{get;set;}
    public String unitId{get;set;}
    public Integer noOfSplit{get;set;}
    public Boolean error{get;set;}
    public Boolean splitGenerated{get;set;}
    public Boolean closePage{get;set;}
    
    public SplitUnit_Controller(){
    	
    	splitUnits =new List<Units__c>();
    	
        unitOnUI = new Units__c();
        unitId = ApexPages.currentpage().getParameters().get('unitId');
        
        noOfSplit = 0;
        
        selectedUnit = new Units__c();
        selectedUnit = [Select Water_Meter_No__c, Unit_No__c, Unique_Selling_Point__c, UOM__c, Type_of_License__c, 
	        			Trade_Category__c, Trade_Category_3__c, Trade_Category_2__c, Trade_Category_1__c, Target_Rental__c, 
	        			Takeover_Date__c, Sub_Trade_Category__c, Sub_Trade_Category_3__c, Sub_Trade_Category_2__c, 
	        			Sub_Trade_Category_1__c, Sub_Space_Type__c, Sub_Meter_No__c, Start_Date__c, Space_Type__c, Shop_Front__c, 
	        			Rental_Budget_per_UOM__c, Rent_Hurdle__c, Rent_Hurdle_Upper_Limit__c, Rent_Hurdle_Lower_Limit__c, 
	        			Rent_Hurdle_Amount__c, Rent_Hurdle_3__c, Rent_Hurdle_2__c, Rent_Hurdle_1__c, Property__c, 
	        			Property_Short_Code__c, Project_In_Charge__c, Previous_Month_Sub_Meter_End_Unit__c, 
	        			Previous_Month_CT_Meter_End_Unit__c, Power_Factor__c, Phone_Extension_No__c, Person_In_Charge__c, 
	        			Person_In_Charge_2__c, Partition__c, No__c, Name, NLA_SQM__c, NLA_SQF__c, Mobile_Module__c, Main_Unit__c, 
	        			Location__c, Line_Loss__c, Level__c, IsDeleted, Id, Horse_Power__c, Generate_Lease_Plans__c, 
	        			Generate_CheckList__c, Gas_Meter_No__c, Forecast_Charge__c, Floor__c, Floor_Plan__c, End_Date__c, 
	        			Description__c,  Charge_Method__c, CT_Meter_No__c, Authorised_Person__c, Authorised_Person_2__c, Active__c 
        				From Units__c  where Id =: unitId];
        unitOnUI.NLA_SQF__c = selectedUnit.NLA_SQF__c;
        unitOnUI.Name = selectedUnit.Name;
    }
    public void validateFilter(){
        if(unitOnUI.start_Date__c > unitOnUI.End_Date__c){
    	    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Split Start Date cant exceed Split End Date'));
        }
        if(unitOnUI.start_Date__c < selectedUnit.start_Date__c || unitOnUI.start_Date__c > selectedUnit.End_Date__c){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Split Start Date should be in between Main Unit Start End Date'));
        }
        if(unitOnUI.End_Date__c < selectedUnit.start_Date__c || unitOnUI.End_Date__c > selectedUnit.End_Date__c){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Split End Date should be in between Main Unit Start End Date'));
        }
        if(noOfSplit <= 1){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid split number'));
        }
        
        Map<Id, Units__c> mainUnitLALOIMap = new Map<Id, Units__c>([select Id, Property__c, name, Start_Date__c, End_Date__c, (Select Id,name, Lease_Start_Date__c, Lease_End_Date__c,Fit_Out_Date__c From Lease_Units__r where Lease_Unit_Status__c != 'Vacant' and Lease_Unit_Status__c !='Cancelled'), (Select Id,name, LOI_End_Date__c, LOI_Start_Date__c From LOI_Units__r where LOI_Agreement_No__r.LOI_Status__c !='Expired' and LOI_Agreement_No__r.LOI_Status__c !='Cancelled') From Units__c u where Id =: selectedUnit.Id]);
    	
		if(unitOnUI.Start_Date__c != null && unitOnUI.End_Date__c!= null){
			String tempLeaseerror='';
       		String tempLOIerror=''; 
			for(Lease_Unit__c lu : mainUnitLALOIMap.get(selectedUnit.Id).Lease_Units__r){
				Date stDate = (lu.Fit_Out_Date__c != null)?lu.Fit_Out_Date__c:lu.Lease_Start_Date__c;
				if((stDate <= unitOnUI.End_Date__c && unitOnUI.Start_Date__c <= lu.Lease_End_Date__c) ){
					If(tempLeaseerror == '')
                    tempLeaseerror = 'Lease Unit for this duration already exist Under Main Unit.';
                	tempLeaseerror += '<br/><a target="_blank" href="/'+lu.Id+'">'+lu.Name+'</a> ';
				}
			}
			for(LOI_Unit__c loi : mainUnitLALOIMap.get(selectedUnit.Id).LOI_Units__r){
				if((loi.LOI_Start_Date__c <= unitOnUI.End_Date__c && unitOnUI.Start_Date__c <= loi.LOI_End_Date__c) ){
					If(tempLOIerror == '')
                    tempLOIerror = 'LOI Unit for this duration already exist Under Main Unit.';
                    tempLOIerror += '<br/><a target="_blank" href="/'+loi.Id+'">'+loi.Name+'</a> ';
				}
			}
			if( tempLeaseerror != '' || tempLOIerror != ''){
		        String fullError = '';
		        //fullError += tempEOIerror;
		        fullError += (tempLOIerror !='' && fullError!='')?'<br/>':'';
		        fullError += tempLOIerror;
		        fullError += (tempLeaseerror !='' && fullError!='')?'<br/>':'';
		        fullError += tempLeaseerror;
		        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,fullError));
		    }
		}
    }
    public void  generateSplit() {
        validateFilter();
        splitUnits =new List<Units__c>();
        splitGenerated = false;
        if(ApexPages.getMessages().size() > 0){
        	//unitOnUI.End_Date__c.addError('multiple messages');
        }else{
        	splitGenerated = true;
        	
        	for(Integer i= 1; i<= noOfSplit; i++){
        	    Units__c tempUnit = new Units__c();
        	    tempUnit = selectedUnit.clone(false, true);
        	    splitUnits.add(tempUnit); 
        	}
        	
        	String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZA';
        	String tempName = selectedUnit.name;
        	String tempDateStr = unitOnUI.start_Date__c.year()+''+((unitOnUI.start_Date__c.month() < 10)?'0':'')+unitOnUI.start_Date__c.month()+''+((unitOnUI.start_Date__c.day() < 10)?'0':'')+unitOnUI.start_Date__c.day();
        	Integer j=0;
        	
        	for(Units__c un: splitUnits){ 
        	    un.Name = tempName +'-'+tempDateStr+ '-'+ ((j < 26)?key.substring(j, j+1):'');
        	    system.debug('un.Name-->'+un.Name);
        	    un.Main_Unit__c = selectedUnit.Id;
        	    un.start_Date__c = unitOnUI.start_Date__c;
        	    un.End_Date__c = unitOnUI.End_Date__c;
        	    un.NLA_SQF__c =  (unitOnUI.NLA_SQF__c != null )?unitOnUI.NLA_SQF__c.setScale(2) / noOfSplit:0;
        	    un.NLA_SQF__c = un.NLA_SQF__c.setScale(2);
        	    un.Gas_Meter_No__c = null;
        	    un.Phone_Extension_No__c = null;
        	    un.Water_Meter_No__c = null;
        	    j++;
        	}
        }
        
    }
    public pageReference saveSplit(){
    	Decimal nlaSqTotal=0;
    	for(Units__c un: splitUnits){ 
    		system.debug('un-->'+un);
    		nlaSqTotal += un.NLA_SQF__c;
    		if(nlaSqTotal > unitOnUI.NLA_SQF__c){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Total NLA (SQF) cant exceed Main Unit NLA (SQF): '+unitOnUI.NLA_SQF__c));
    			return null;
    		}
    	}
    	try{
    		insert splitUnits;
    		closePage = true;
    	}catch(Exception e){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Exception occured: '+e));
    	}
    	return null;
    }
}