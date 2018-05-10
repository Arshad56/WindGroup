/*
*  Developer Name: Arshad Shaikh
*  Date Created: Nov 1st 2017       Last updated : Nov-01-2017
*  Description: Trigger on Rent Schedule that calls helper methods to perform different operations
*  Test Class: 1. TestDiscountRsTriggers
*            2. TestCalcBaseRent
*            3. calPercentage_Test
*        4. CalcEstimatedGTO_Test
*/

trigger RSTrigger on Rent_Schedules__c ( after insert, after update, before insert, before update){
  
  // Constant variables for Charge Type field in Rent_Schedules__c
  private static final String GTOCHARGETYPE = 'GTO Rent';
  
  Set<Id> luIds = new Set<Id>();
  Set<Id> lcIds = new Set<Id>();
  set<Id> unitIds = new set<Id>();
  Date startDate = system.today();
    Date endDate = system.today();
    Map<Id, Rent_Schedules__c> rsFrmTrigger = new Map<Id, Rent_Schedules__c>();
  
  for(Rent_Schedules__c rs: Trigger.new){
    lcIds.add(rs.Lease_Charge__c);
    luIds.add(rs.Lease_Unit__c);
    unitIds.add(rs.Unit__c);
    rsFrmTrigger.put(rs.Id, rs);
    if(rs.Start_Date__c < startDate){
      startDate = rs.Start_Date__c;
    }
    if(rs.End_Date__c > endDate){
      endDate = rs.End_Date__c;
    }
  }
  
  if(RSTrigger_Helper.RSmap == null || RSTrigger_Helper.RSmap.size() == 0){
    RSTrigger_Helper.RSmap = (!(Trigger.isBefore && Trigger.isInsert))?RSTrigger_Helper.retrieveGtoRsDetailsByRsId(Trigger.newMap.keyset()):new Map<Id, Rent_Schedules__c>();
  }
  if(RSCalPercentage.LUmap == null || RSCalPercentage.LUmap.size() == 0){
    //System.debug('XXXXXX fetch LU');
    RSCalPercentage.LUmap = RSCalPercentage.retrieveLuLcDetailsByLuId(luIds);
  }
  if(RSCalPercentage.Unitmap == null || RSCalPercentage.Unitmap.size() == 0){
    //System.debug('XXXXXX fetch LU');
    RSCalPercentage.Unitmap = RSCalPercentage.retrieveUnitDetailsByUnitId(unitIds);
  }
  
  System.debug('Trigger.isBefore-->'+Trigger.isBefore);
  System.debug('Trigger.isAfter-->'+Trigger.isAfter);
  System.debug('Trigger.isInsert-->'+Trigger.isInsert);
  System.debug('Trigger.isUpdate-->'+Trigger.isUpdate);
  
  //System.debug('RSCalPercentage.LUmap-->'+RSCalPercentage.LUmap);
  //System.debug('RSTrigger_Helper.RSmap-->'+RSTrigger_Helper.RSmap);
    
   if(Trigger.isBefore){
       
      if(Trigger.isInsert){
      //System.debug('RSCalPercentage.LUmap 111-->'+RSCalPercentage.LUmap);
      //System.debug('RSTrigger_Helper.RSmap 111-->'+RSTrigger_Helper.RSmap);

         // Multi Currency Calculations on RS
         RSTrigger_Helper.calcMultiCurrencyAmount(Trigger.new, new Map<Id,Rent_Schedules__c>());
         // No of prorated Days calculation and GTO calculation By Lease unit (Individual)
         RSCalPercentage.calPercentage(Trigger.new);
      }  
      if(Trigger.isUpdate){
        //System.debug('RSCalPercentage.LUmap 222-->'+RSCalPercentage.LUmap);
      //System.debug('RSTrigger_Helper.RSmap 222-->'+RSTrigger_Helper.RSmap);
      
        RSTrigger_Helper.discountRsAmountCheck(Trigger.new);
        
      // Multi Currency Calculations on RS
         RSTrigger_Helper.calcMultiCurrencyAmount(Trigger.new, Trigger.oldMap);
        
          RSTrigger_Helper.calcConvertedBaseRent(Trigger.new);
          // No of prorated Days calculation and GTO calculation By Lease unit (Individual)
          RSCalPercentage.calPercentage(Trigger.new);
          //Calculate Est GTO for By Lease unit (Individual)
          RSTrigger_Helper.calcEstimatedGTOByLease(true, rsFrmTrigger, RSTrigger_Helper.RSmap, startDate, endDate);
      }
      //if(Trigger.isDelete){
          // Call class logic here!
      //}
  }
  
  if(Trigger.IsAfter && Utility.doGTO){
      if(Trigger.isInsert){
        //System.debug('RSCalPercentage.LUmap 333-->'+RSCalPercentage.LUmap);
      //System.debug('RSTrigger_Helper.RSmap 333-->'+RSTrigger_Helper.RSmap);
      
        // GTO calculation By Lease (Summary) And  By Lease (LU)
          RSCalPercentage.byLeaseCal(RSTrigger_Helper.RSmap.values());
          
          // Calculate Est GTO for By Lease (Summary) And By Lease (LU)
           RSTrigger_Helper.calcEstimatedGTOByLease(false, rsFrmTrigger, RSTrigger_Helper.RSmap, startDate, endDate);
          
      }
      if(Trigger.isUpdate){
        //System.debug('RSCalPercentage.LUmap 444-->'+RSCalPercentage.LUmap);
      //System.debug('RSTrigger_Helper.RSmap 444-->'+RSTrigger_Helper.RSmap);
      
        RSTrigger_Helper.discountChildRSAmtUpdate(Trigger.new, Trigger.oldMap);
          RSTrigger_Helper.calcChildBaseRent(Trigger.new, Trigger.oldMap);
          // GTO calculation By Lease (Summary) And  By Lease (LU)
          RSCalPercentage.byLeaseCal(RSTrigger_Helper.RSmap.values());
          
          // Calculate Est GTO for By Lease (Summary) And By Lease (LU)
           RSTrigger_Helper.calcEstimatedGTOByLease(false, rsFrmTrigger, RSTrigger_Helper.RSmap, startDate, endDate);
      }
      //if(Trigger.isDelete){
          // Call class logic here!
      //}
  }
}