/*  
    Name         : RollupPurchaseOrderItemHelper 
    Author       : Rajesh 
    Created Date : 2nd Jun 2017    
    Description  : This class call from two trigger 1.Purchase order trigger and 2. Purchase Order line item triger   
                   1. This trigger Helper class is used to rollup amount based on Status picklist field value in Purchase_Order__c object if picklist value is ‘IN-Approval’
                   then update total rollup amount in 'PO Pending',‘Issued’then update total rollup amount in 'PO Issued'.
                   
*/
public class RollupPurchaseOrderItemHelper{
    
    public static void rollupPurOrdrItmAmount(Set<Id> purOrdrIds){
         Map<Id,Map<String,Decimal>> rollUpMap = new Map<Id,Map<String,Decimal>>();
        
        for(AggregateResult agRes : [SELECT COA_FY_Balance__c,Purchase_Order__r.Status__c status,sum(Total_Amount__c)totSum 
                                      FROM PO_Line_Item__c 
                                      WHERE COA_FY_Balance__c != null 
                                      GROUP BY COA_FY_Balance__c,Purchase_Order__r.Status__c]){
                                      
            Map<String,Decimal> tempInnerMap = new Map<String,Decimal>();
            Id coaBalId = (Id)agRes.get('COA_FY_Balance__c');   
            String status = (String)agRes.get('status');
            Double totAmt = (Double)agRes.get('totSum');
            
            if(rollUpMap.containsKey(coaBalId))
                tempInnerMap =  rollUpMap.get(coaBalId);
                
            tempInnerMap.put(status, totAmt); 
            rollUpMap.put(coaBalId, tempInnerMap); 
        }
        
        if(rollUpMap.size() > 0){
            List<COA_FY_Balance__c> updCOABalLst = new List<COA_FY_Balance__c>();
            for(Id caBalId : rollUpMap.keySet()){
                COA_FY_Balance__c coaObj = new COA_FY_Balance__c();
                coaObj.Id = caBalId;
                coaObj.PO_Pending__c = 0;
                coaObj.PO_Issued__c = 0;
                
                Map<String,Decimal> tempInnerMap = rollUpMap.get(caBalId);
                
                if(tempInnerMap != null){
                    if(tempInnerMap.containsKey('In-Approval'))
                        coaObj.PO_Pending__c = tempInnerMap.get('In-Approval');
                    
                    if(tempInnerMap.containsKey('Issued'))
                        coaObj.PO_Issued__c = tempInnerMap.get('Issued');
                    
                    if(tempInnerMap.containsKey('Closed')){
                        if(coaObj.PO_Issued__c!=null){
                            coaObj.PO_Issued__c += tempInnerMap.get('Closed');
                        }else{
                            coaObj.PO_Issued__c = tempInnerMap.get('Closed');
                        }
                    }
                    
                     if(tempInnerMap.containsKey('Cancel In-Approval'))
                        coaObj.PO_Issued__c = tempInnerMap.get('Issued') + tempInnerMap.get('Cancel In-Approval');
                    
                }
                
                updCOABalLst.add(coaObj); 
            }
            
            if(updCOABalLst.size() > 0)
                update updCOABalLst;
        }
    }
}