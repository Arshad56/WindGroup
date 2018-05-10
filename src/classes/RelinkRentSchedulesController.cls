public class RelinkRentSchedulesController{
    public Electric_Meter__c elecMeter{get;set;}
    public Electric_Meter__c elecMtrUIDt{get;set;}
    public date startDate{get;set;}
    public date endDate{get;set;}
    public Boolean success{get;set;}
    public string oldMeterNo{get;set;}
    public Boolean isError{get;set;}
    public string errorMsg{get;set;}
    
    public List<SelectOption> getStatus() {
        List<SelectOption> choices = new List<SelectOption>();
        choices.add(new SelectOption('Active','Link'));
        choices.add(new SelectOption('Inactive','Unlink'));
        return choices;
    }
    public RelinkRentSchedulesController(){
        isError = false;
        success = false;
        //startDate = system.today();
        
        elecMeter = new Electric_Meter__c();
        
        elecMtrUIDt = new Electric_Meter__c();
        elecMtrUIDt.Start_Date__c = system.today();
        
        for(Electric_Meter__c em:[Select id,Meter_No__c,Unit__c,Status__c,Meter_Type__c from Electric_Meter__c where id=:Apexpages.currentPage().getParameters().get('Id')]){
            elecMeter = em;
            oldMeterNo = em.Meter_No__c;
        }
    }
    public RelinkRentSchedulesController(String recId){
        isError = false;
        success = false;
        //startDate = system.today();
        
        elecMeter = new Electric_Meter__c();
        
        elecMtrUIDt = new Electric_Meter__c();
        elecMtrUIDt.Start_Date__c = system.today();
        
        for(Electric_Meter__c em:[Select id,Meter_No__c,Unit__c,Status__c,Meter_Type__c from Electric_Meter__c where id=:recId]){
            elecMeter = em;
            oldMeterNo = em.Meter_No__c;
        }
    }
    public String save(){
        isError = false;
        errorMsg = '';
        if(elecMtrUIDt.Start_Date__c!=null && elecMtrUIDt.End_Date__c!=null){
              startDate = elecMtrUIDt.Start_Date__c;
              endDate = elecMtrUIDt.End_Date__c;
           }else{
            isError = true;
            errorMsg = 'Please enter Start and End Date.';
            return errorMsg;
        }
        if(elecMeter.Status__c=='Active'){
            
                if(startDate<endDate){
                    if(oldMeterNo!=elecMeter.Meter_No__c){//this is to process if user wants to update meter no and the meter no is already linked in the RS. by myat apr-06-2018
                        List<Rent_Schedules__c> rsList = [Select id,Electric_Meter_Number__c,Start_Date__c,End_Date__c,(Select id from Electric_Transactions__r) from Rent_Schedules__c where Unit__c =: elecMeter.Unit__c And Charge_Type__c=:elecMeter.Meter_Type__c And Electric_Meter_Number__c like: ('%'+oldMeterNo+'%') and Status__c='In-Tenancy' and ((Start_Date__c>=:startDate and End_Date__c<=:endDate) or (End_Date__c>=:startDate and End_Date__c<=:endDate) or (Start_Date__c<:endDate and End_Date__c>:endDate))];
                        List<Rent_Schedules__c> updateRSList = new List<Rent_Schedules__c>();
                            for(Rent_Schedules__c rs:rsList){
                                if(rs.Electric_Transactions__r.size()==0 && (rs.Start_Date__c <=endDate && startDate <= rs.End_Date__c)){
                                    rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.replace(oldMeterNo,elecMeter.Meter_No__c); 
                                    updateRSList.add(rs);                                
                                }
                            }
                        if(updateRSList.size()>0){
                            update updateRSList;
                        }else{//this is to process if user wants to update meter no and the meter no is not linked in any the RS. by myat apr-06-2018
                            rsList = [Select id,Electric_Meter_Number__c,Start_Date__c,End_Date__c,(Select id from Electric_Transactions__r) from Rent_Schedules__c where  Unit__c =: elecMeter.Unit__c And Charge_Type__c=:elecMeter.Meter_Type__c and  Status__c='In-Tenancy' and ((Start_Date__c>=:startDate and End_Date__c<=:endDate) or (End_Date__c>=:startDate and End_Date__c<=:endDate) or (Start_Date__c<:endDate and End_Date__c>:endDate))];
                            if(rslist.size()>0){
                                for(Rent_Schedules__c rs:rsList){
                                    if(rs.Electric_Transactions__r.size()==0 && (rs.Start_Date__c <=endDate && startDate <= rs.End_Date__c)){
                                        if(rs.Electric_Meter_Number__c!=null && rs.Electric_Meter_Number__c.trim().length()>0){
                                            rs.Electric_Meter_Number__c += ';'+elecMeter.Meter_No__c;
                                        }else{
                                            rs.Electric_Meter_Number__c = elecMeter.Meter_No__c;
                                        }
                                        rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.replace(oldMeterNo,elecMeter.Meter_No__c); //since this code part is to update meter no, this line of code make sure to 
                                                                                                                                            //replace   oldmeter no with new meter. myat-apr-06-2018
                                    }
                                }
                                update rsList;
                            }                            
                        }
                        elecMeter.remarks__c = 'Meter No changed from '+oldMeterNo+' to '+elecMeter.Meter_No__c+ ' on '+system.today().day()+'/'+system.today().month()+'/'+system.today().Year();
                    }else{
                        List<Rent_Schedules__c> rsList = [Select id,Electric_Meter_Number__c,Start_Date__c,End_Date__c,(Select id from Electric_Transactions__r) from Rent_Schedules__c where  Unit__c =: elecMeter.Unit__c And Charge_Type__c=:elecMeter.Meter_Type__c and Status__c='In-Tenancy' and ((Start_Date__c>=:startDate and End_Date__c<=:endDate) or (End_Date__c>=:startDate and End_Date__c<=:endDate) or (Start_Date__c<:endDate and End_Date__c>:endDate))];
                        if(rslist.size()>0){
                            for(Rent_Schedules__c rs:rsList){
                                if(rs.Electric_Transactions__r.size()==0 && (rs.Start_Date__c <=endDate && startDate <= rs.End_Date__c)){
                                    if(rs.Electric_Meter_Number__c!=null && rs.Electric_Meter_Number__c.trim().length()>0){
                                        if(!rs.Electric_Meter_Number__c.contains(elecMeter.Meter_No__c)){
                                            rs.Electric_Meter_Number__c += ';'+elecMeter.Meter_No__c;
                                        }
                                    }else{
                                        rs.Electric_Meter_Number__c = elecMeter.Meter_No__c;
                                    }
                                    //rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.replace(oldMeterNo,elecMeter.Meter_No__c); //commented this code since this is redundent. by myat - apr-06-2018
                                }
                            }
                            update rsList;
                        }                            
                    }
                }else{
                    isError = true;
                    errorMsg = 'End Date should be greater than Start Date.';
                    return errorMsg;
                }
           
        }else{
            if(oldMeterNo!=elecMeter.Meter_No__c){
                isError = true;
                errorMsg = 'You cannot change Meter No while its Inactive.';
                return errorMsg;
            }
            List<Rent_Schedules__c> deleteRsList = new List<Rent_Schedules__c>();
            List<Rent_Schedules__c> updateRsList = new List<Rent_Schedules__c>();
            List<Rent_Schedules__c> rsList = [Select id,Electric_Meter_Number__c,Status__c,Start_Date__c,End_Date__c,(Select id from Electric_Transactions__r) from Rent_Schedules__c where  Unit__c =: elecMeter.Unit__c And Charge_Type__c=:elecMeter.Meter_Type__c And Electric_Meter_Number__c like: ('%'+elecMeter.Meter_No__c+'%') and Status__c='In-Tenancy' and ((Start_Date__c>=:startDate and End_Date__c<=:endDate) or (End_Date__c>=:startDate and End_Date__c<=:endDate) or (Start_Date__c<:endDate and End_Date__c>:endDate))];
            
            System.debug('rsList--->'+rsList);
            System.debug('startDate--->'+startDate);
            System.debug('endDate-->'+endDate);
            if(rsList.size()>0){  
                for(Rent_Schedules__c rs:rsList){
                    System.debug('rs.Start_Date__c--->'+rs.Start_Date__c);
                    System.debug('rs.End_Date__c--->'+rs.End_Date__c);
                    System.debug('1111--->'+(rs.Start_Date__c <=endDate));
                    System.debug('2222--->'+(startDate <= rs.End_Date__c));
                    if(rs.Electric_Transactions__r.size()==0 && (rs.Start_Date__c <=endDate && startDate <= rs.End_Date__c)){
                        if(rs.Electric_Meter_Number__c.contains(elecMeter.Meter_No__c+';')){
                            rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.replace(elecMeter.Meter_No__c+';','');
                            updateRsList.add(rs);
                        }else if(rs.Electric_Meter_Number__c.contains(';'+elecMeter.Meter_No__c)){
                            rs.Electric_Meter_Number__c = rs.Electric_Meter_Number__c.replace(';'+elecMeter.Meter_No__c,'');
                            updateRsList.add(rs);
                        }else if(rs.Electric_Meter_Number__c==elecMeter.Meter_No__c){
                            rs.Electric_Meter_Number__c='';
                            updateRsList.add(rs);
                        }
                    }
                }
                if(updateRsList.size()>0){
                    update updateRsList;
                }
                /* //commented by myat-apr-06-2018 as it's redundent.
                if(deleteRsList.size()>0){
                   // delete deleteRsList;
                }*/
            }
        }
        //update elecMeter;  
        success = true;
        return 'Success';
    }
}