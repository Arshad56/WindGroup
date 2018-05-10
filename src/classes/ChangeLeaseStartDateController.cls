public class ChangeLeaseStartDateController {
      
    public ChangeLeaseStartDateController(){
        
    }
    
    public void executeBeforeUpdate(Lease__c[] oldLeaseList, Lease__c[] newLeaseList)
    {
        Set<Id> leaseUnitIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        Map<Id, Date> leaseUnitEndDateMap = new Map<Id, Date>();     

        for(Integer i=0; i<newLeaseList.size(); i++)
        {
            boolean reGenerateRs = true;
            boolean updateLeaseUnit = true;

            if(changeLeaseStartDate(oldLeaseList.get(i), newLeaseList.get(i))){

                newLeaseList.get(i).Original_End_Date__c = newLeaseList.get(i).Lease_End_Date__c;
				newLeaseList.get(i).Change_Lease_Start_Date__c = false;
               
                List <Lease_Unit__c> leaseUnitList = [select Id, Name, Lease_Start_Date__c, Lease_End_Date__c, Unit__c from Lease_Unit__c where Lease_Agreement_No__c = :newLeaseList.get(i).Id];
                
                for(Lease_Unit__c leaseUnit : leaseUnitList){
                    
                    if(leaseUnit.Lease_Start_Date__c != oldLeaseList.get(i).Lease_Start_Date__c){
                        newLeaseList.get(i).addError('Lease Unit Lease Start Date is different, changing of Lease Start Date is not allowed.');
                        reGenerateRs = false;
                        break;
                    }

                    leaseUnit.Lease_Start_Date__c = newLeaseList.get(i).Lease_Start_Date__c;
                    leaseUnit.Lease_End_Date__c = getLeaseUnitEndDate(oldLeaseList.get(i), newLeaseList.get(i), leaseUnit);
                    leaseUnit.Original_End_Date__c = leaseUnit.Lease_End_Date__c;

                    leaseUnitIds.add(leaseUnit.Id);
                    unitIds.add(leaseUnit.Unit__c);
                    leaseUnitEndDateMap.put(leaseUnit.Id, leaseUnit.Lease_End_Date__c);
                
                }
                
                List <Rent_Schedules__c> rslist = [select Id, Rent_Roll_Detail__c, Lease_Charge__c, POS_Transaction_Count__c, Ele_Transaction_Count__c, Water_Transaction_Count__c,  Phone_transaction_Count__c, Gas_Transaction_Count__c from Rent_Schedules__c where Lease_Unit__r.Id IN :leaseUnitIds];
                Map<Id, Id> leaseChargeIdMap = getLeaseChargeIdMap(rslist);
                if(leaseChargeIdMap == null)
                    reGenerateRs = false;
                updateLeaseUnit = validateUnit(leaseUnitList, unitIds);
            
                if(reGenerateRs && updateLeaseUnit){
                    Savepoint sp = Database.setSavepoint();
                    try{
                        
                        delete rslist;
                        update leaseUnitList;
                        updateLeaseCharge(leaseUnitIds, leaseChargeIdMap, newLeaseList.get(i).Lease_Start_Date__c, leaseUnitEndDateMap);
                        updateLeasePlan(unitIds, leaseUnitList);
                                                
                    } catch(Exception e) {
                        Database.rollback(sp);
                        System.debug(Logginglevel.ERROR, '###Change Lease Start Date Exception Occured: ' + e.getStackTraceString() + '\n' +e.getMessage());
                    }

                } else {
                    for(Lease__c lease : newLeaseList){
                        if(!reGenerateRs)
                        	lease.addError('Invoice or Transaction is created, changing of Lease Start Date is not allowed.');
                        if(!updateLeaseUnit)
                            lease.addError('Lease Unit is not meeting the update criteria, changing of Lease Start Date is not allowed.');
                    }
                    return;
                }
            }
        }
    }
    
    private void updateLeasePlan(Set<Id> untIds, List <Lease_Unit__c> leaseUnitList){
 
        List<Lease_Plan__c> leasePlanList = [Select Id,Start_Date__c,End_Date__c, Lease_Unit__c, Unit__c, Status__c from Lease_Plan__c where Unit__c in:untIds];
        
        for(Lease_Unit__c lu: leaseUnitList){
            
            for(Lease_Plan__c lp: leasePlanList){
                
                if(lp.Unit__c == lu.Unit__c){

                    if(lp.Lease_Unit__c == lu.Id){
                        if(lp.End_Date__c < lu.Lease_Start_Date__c || lp.Start_Date__c > lu.Lease_End_Date__c){
                            lp.Status__c = 'Vacant';
                            lp.Lease_Unit__c = null;
                    	}
                    }else{
                        if(lp.End_Date__c > lu.Lease_Start_Date__c && lp.Start_Date__c < lu.Lease_End_Date__c){
                            lp.Status__c = 'Committed';
                            lp.Lease_Unit__c = lu.Id;
                    	} 
                    }
                }
            }            
        }
        
        update leasePlanList;     
    }
    
    private Map<Id, Id> getLeaseChargeIdMap(List <Rent_Schedules__c> rslist){
        
        Map<Id, Id> leaseChargeIdMap = new Map<Id, Id>();

        for(Rent_Schedules__c rs : rslist){
            
            if(rs.Rent_Roll_Detail__c != null || rs.POS_Transaction_Count__c>0 || rs.Ele_Transaction_Count__c>0 || rs.Water_Transaction_Count__c >0 || rs.Phone_transaction_Count__c > 0 || rs.Gas_Transaction_Count__c > 0){
                leaseChargeIdMap = null;
                break;
            }
            leaseChargeIdMap.put(rs.Lease_Charge__c, rs.Lease_Charge__c);
        } 
        
        return leaseChargeIdMap;
                
    }
    
    @future
    private static void updateLeaseCharge(Set<Id> leaseUnitIds, Map<Id, Id> leaseChargeIdMap, Date newleaseStartDate,  Map<Id, Date> leaseUnitEndDateMap){
        
        List <Lease_Charges__c> lclist = [select Id, Lease_Unit__c, Billing_Days__c, Cap_Applicable__c, RecordTypeId, Type__c, GTO_Cap__c, Multiple_Rental_Schedule__c, Generate_Rent_Schedule__c, Lease_Type__c, Currency_Code__c, Due_Month_Formula__c, Expected_Charge__c, Frequency__c,Charge_Type__c, Start_Date__c, Commercial_Tax_Apply__c, End_Date__c, Billing_Terms__c from Lease_Charges__c where Lease_Unit__c IN :leaseUnitIds];
        List <Lease_Charges__c> templclist = new List <Lease_Charges__c>();
        
        for(Lease_Charges__c lc: lclist)
        {
            lc.Generate_Rent_Schedule__c = false;
            lc.Start_Date__c =newleaseStartDate;
            lc.End_Date__c = leaseUnitEndDateMap.get(lc.Lease_Unit__c);
            
            if(leaseChargeIdMap.containsKey(lc.Id)){
                //************** Update Generate Rent Schedule Status ***********************
                Lease_Charges__c newlc = new Lease_Charges__c();
                newlc.Id = lc.Id;
                newlc.Generate_Rent_Schedule__c = true;
                templclist.add(newlc);
            }
        }
        
        update lclist;
        Utility.firstRun = true;    
        update templclist;
        
    }
      
    private boolean changeLeaseStartDate(Lease__c oldLease, Lease__c newLease){
     
        if(oldLease.Lease_Start_Date__c != newLease.Lease_Start_Date__c || oldLease.Lease_Tenure_Mths__c != newLease.Lease_Tenure_Mths__c || oldLease.Lease_Tenure_Days__c != newLease.Lease_Tenure_Days__c){
            if (oldLease!= null && !oldLease.Lease_Status__c.equals('New') && !oldLease.Lease_Status__c.equals('Renewal'))
                newLease.addError('Only active lease is allow to change Lease Start Date.');
            else if(!newLease.Change_Lease_Start_Date__c)
                newLease.addError('Please click on the Change Lease Start Date button for Lease Start Date modification.');
            else if(newLease.Change_Lease_Start_Date__c)
                return true;
        }
           
        return false;
    }
    
    private date getLeaseUnitEndDate(Lease__c oldLease, Lease__c newLease, Lease_Unit__c leaseUnit){
        
        date newLeaseUnitEndDate = null;
        
        if(oldLease.Lease_Tenure_Mths__c != newLease.Lease_Tenure_Mths__c || oldLease.Lease_Tenure_Days__c != newLease.Lease_Tenure_Days__c){
           
            if(leaseUnit.Lease_End_Date__c == oldLease.Lease_End_Date__c){
                if(Integer.valueOf(newLease.Lease_Tenure_Mths__c) != null && Integer.valueOf(newLease.Lease_Tenure_Mths__c) != 0){
                    newLeaseUnitEndDate = newLease.Lease_Start_Date__c.addMonths(Integer.valueOf(newLease.Lease_Tenure_Mths__c));
                    newLeaseUnitEndDate = newLeaseUnitEndDate.addDays(-1);
                }
                 
                if(Integer.valueOf(newLease.Lease_Tenure_Days__c) != null && Integer.valueOf(newLease.Lease_Tenure_Days__c) != 0){
                    if(newLeaseUnitEndDate != null)
                        newLeaseUnitEndDate = newLeaseUnitEndDate.addDays(Integer.valueOf(newLease.Lease_Tenure_Days__c));
                    else
                        newLeaseUnitEndDate = newLease.Lease_Start_Date__c.addDays(Integer.valueOf(newLease.Lease_Tenure_Days__c));
                }
                    
            } else if(leaseUnit.Lease_End_Date__c != oldLease.Lease_End_Date__c){
                 newLease.addError('Only same Lease Unit End Date is allow to change Lease Tenure Mths and Days.');
            }
  
        }else{
            if(leaseUnit.Lease_End_Date__c == oldLease.Lease_End_Date__c){
                  newLeaseUnitEndDate = newLease.Lease_End_Date__c;
                  
            } else if(leaseUnit.Lease_End_Date__c != oldLease.Lease_End_Date__c){
                Integer diffStartDays = oldLease.Lease_Start_Date__c.daysBetween(newLease.Lease_Start_Date__c);
                newLeaseUnitEndDate = leaseUnit.Lease_End_Date__c.addDays(diffStartDays);
            }
        }
       					              
        return newLeaseUnitEndDate;
    }
    
    private boolean validateUnit(List <Lease_Unit__c> leaseunitlist, Set<Id> untIds){
   		Map<Id,Units__c> unitMap = new Map<Id,Units__c>([Select Id,Start_Date__c,End_Date__c, Name from Units__c where id in:untIds]);
        List<Lease_Unit__c> lsUntList = [Select id,Name,Unit__c,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where Unit__c in:untIds and Lease_Unit_Status__c!='Cancelled'];
        Map<Id,List<Lease_Unit__c>> unitToLeaseUntMap = new Map<Id,List<Lease_Unit__c>>();
  
        if(lsUntList.size()>0){
            for(Lease_Unit__c lu:lsUntList){
                List<Lease_Unit__c> tempList = new List<Lease_Unit__c>();
                if(unitToLeaseUntMap.containsKey(lu.Unit__c)){
                    tempList.addAll(unitToLeaseUntMap.get(lu.Unit__c));
                }
                tempList.add(lu);
                unitToLeaseUntMap.put(lu.Unit__c,tempList);
            }
        }
        
        for(Lease_Unit__c lu: leaseunitlist)
        {
            Units__c unit = unitMap.get(lu.Unit__c);

            if(lu.Lease_Start_Date__c<unit.Start_Date__c || lu.Lease_Start_Date__c>unit.End_Date__c || lu.Lease_End_Date__c<unit.Start_Date__c || lu.Lease_End_Date__c>unit.End_Date__c){
                System.debug('Lease Unit: '+unit.Name+ ' Start and End Date should be within Unit Start and End Date.');
                return false;
            }
            
            if(unitToLeaseUntMap.containsKey(lu.Unit__c)){
                for(Lease_Unit__c prevLeaseUnit:unitToLeaseUntMap.get(lu.Unit__c)){
                    if(lu.Id!=prevLeaseUnit.Id && ((lu.Lease_Start_Date__c<=prevLeaseUnit.Lease_Start_Date__c && lu.Lease_End_Date__c<=prevLeaseUnit.Lease_End_Date__c && lu.Lease_End_Date__c>=prevLeaseUnit.Lease_Start_Date__c) || (lu.Lease_Start_Date__c>=prevLeaseUnit.Lease_Start_Date__c && lu.Lease_Start_Date__c<=prevLeaseUnit.Lease_End_Date__c && lu.Lease_End_Date__c>=prevLeaseUnit.Lease_End_Date__c) || (lu.Lease_Start_Date__c<prevLeaseUnit.Lease_Start_Date__c && lu.Lease_End_Date__c>prevLeaseUnit.Lease_End_Date__c) || (lu.Lease_Start_Date__c>=prevLeaseUnit.lease_Start_Date__c && lu.Lease_End_Date__c<=prevLeaseUnit.Lease_End_Date__c))){
                        System.debug('Lease Unit for this duration already exist.');
                        return false;
                    }
                }
            }            
        }
        return true;
    }
    
}