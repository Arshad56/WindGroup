/*  
    Name         : PurchaseOrderLineItmController
    Author       : Rajesh 
    Created Date : 2nd Jun 2017   
    Description  : This trigger is used to rollup amount based on Status picklist field value in Purchase_Order__c object if picklist value is ‘IN-Approval’
                      then update total rollup amount in 'PO Pending',‘Issued’then update total rollup amount in 'PO Issued'.
                   //Relationship between PurchaseOrder and PurchaseOrderLineItem is Master details
*/

public with sharing class PoLineItemController {
    
    public static void poLineItemValidation(List<PO_Line_Item__c> triggerList){
        Set<String> textItemSet = new Set<String>();
        Set<Id> poLineItemIds = new Set<Id>();
        Set<Id> prodCatId = new Set<Id>();
        for(PO_Line_Item__c pli: triggerList){

            if(pli.Product_Catalogue__c==null && pli.Item_Name__c!=null){
                if(textItemSet.contains(pli.Item_Name__c)){
                    pli.addError('PO Line Item with same Product Name already exist.');
                }else{
                    textItemSet.add(pli.Item_Name__c);
                    if(Trigger.isUpdate){
                        poLineItemIds.add(pli.Id);
                    }
                }
            }else if(pli.Product_Catalogue__c!=null) {
                prodCatId.add(pli.Product_Catalogue__c);
            }
        }

        if(textItemSet.size()>0){
            Set<string> existingItemSet = new Set<string>();
            for(PO_Line_Item__c pli:[Select id,Item_Name__c from PO_Line_Item__c where Item_Name__c in:textItemSet and id not in:poLineItemIds]){
                existingItemSet.add(pli.Item_Name__c);
            }
            
            Set<string> existingProdCatSet = new Set<string>();
            for(Item_Catalogue__c ic:[Select id,Name from Item_Catalogue__c where Name in:textItemSet]){
                existingProdCatSet.add(ic.Name);
            }
            
            for(PO_Line_Item__c pli: triggerList){
                if(pli.Product_Catalogue__c==null && pli.Item_Name__c!=null){
                    if(existingItemSet.contains(pli.Item_Name__c)){
                        pli.addError('PO Line Item with same Product Name already exist.');
                    }else if(existingProdCatSet.contains(pli.Item_Name__c)){
                        pli.addError('Product Catalogue with same Product Name already exist.');
                    } 
                }
            }
        }
        
        if(prodCatId.size()> 0){
            Map<Id, Item_Catalogue__c> prodCat = new Map<Id, Item_Catalogue__c>([SELECT Id, Name, Product_Type__c, Amount__c, Description__c FROM Item_Catalogue__c WHERE Id IN :prodCatId]);
                
                for(PO_Line_Item__c newpli : triggerList){

                    if(String.isBlank(newpli.Description__c))
                        newpli.Description__c = prodCat.get(newpli.Product_Catalogue__c).Description__c;
                    
                    if(newpli.Amount__c == null || newpli.Amount__c == 0)
                        newpli.Amount__c =  prodCat.get(newpli.Product_Catalogue__c).Amount__c;
                    
                    if(String.isBlank(newpli.Product_Type__c))
                        newpli.Product_Type__c = prodCat.get(newpli.Product_Catalogue__c).Product_Type__c;
                    
                    newpli.Item_Name__c = prodCat.get(newpli.Product_Catalogue__c).Name;
            }
       }
        
    }
    
    public static void calPORollUpAmt(List<PO_Line_Item__c> triggerNewList, Map<id,PO_Line_Item__c> triggerOldMap){
        
        Set<Id> purOrdrIds = new Set<Id>();
        
        for(PO_Line_Item__c purOrdrItm : triggerNewList){
            PO_Line_Item__c oldRec = triggerOldMap.get(purOrdrItm.Id);
            
            if(purOrdrItm.COA_FY_Balance__c != oldRec.COA_FY_Balance__c || purOrdrItm.Quantity__c != oldRec.Quantity__c || purOrdrItm.Amount__c != oldRec.Amount__c)
                purOrdrIds.add(purOrdrItm.Purchase_Order__c);
            
            if(purOrdrItm.Purchase_Order__c != oldRec.Purchase_Order__c){
                purOrdrIds.add(purOrdrItm.Purchase_Order__c);
                purOrdrIds.add(oldRec.Purchase_Order__c);
            }
        }
        
        if(purOrdrIds.size() > 0)
            RollupPurchaseOrderItemHelper.rollupPurOrdrItmAmount(purOrdrIds);
        
    }
    
    public static void validationPOLineItemDelete(List<PO_Line_Item__c> triggerOldList){
        Set<id> poIdSet = new Set<id>();
        for(PO_Line_Item__c poL: triggerOldList)
            poIdSet.add(poL.purchase_order__c);

        List<Purchase_order__c> poList = new List<Purchase_order__c>();
        
        if(poIdSet.size()>0)
            poList = [SELECT id,Status__c from purchase_order__c where id in :poIdSet AND Status__c not in ('Draft','Rejected')];
     
      
       for(purchase_order__c po: poList)
           poIdSet.remove(po.id);
       
        
        for(PO_Line_Item__c poL: triggerOldList){
            if(!poIdSet.contains(poL.Purchase_Order__c))
                poL.addError('You can only delete this record when PO status is either Draft or Rejected');
        }
    }
    
    public static void updateCOAFYBalance(List<PO_Line_Item__c> triggerNewList){
        
        Map<id,String> purOrderTobudgetLine = new Map<id,String>();
        Set<string> departmentSet = new Set<String>();
        Map<Id,Set<String>> companyNameToDates = new Map<Id,Set<String>>();
        Map<id,COA_FY_Balance__c>  finalMap= new  Map<id,COA_FY_Balance__c>();
        
        for(PO_Line_Item__c po : triggerNewList){
            purOrderTobudgetLine.put(po.Purchase_Order__c,po.Budget_Line__c);
            departmentSet.add(po.Department__c);
        }
        
        
        for(Purchase_Order__c prOrd : [Select company_name__c,PO_Start_Date__c,PO_End_Date__c from Purchase_Order__c where id in :purOrderTobudgetLine.keySet()]){
            if(companyNameToDates.containsKey(prOrd.company_name__c)){
                Set<String> tempSet = companyNameToDates.get(prOrd.company_name__c);
                String str=prOrd.id+','+prOrd.PO_Start_Date__c;
                tempSet.add(str);
                companyNameToDates.put(prOrd.company_name__c,tempSet);
            }
            else{
                Set<String> temp = new Set<String>();
                String str=prOrd.id+','+prOrd.PO_Start_Date__c;
                temp.add(str);
                companyNameToDates.put(prOrd.company_name__c,temp);
            }
    
        }
        
        for(Operational_budget__c opr: [Select company_name__c,Budget_Line__c,(select id,Fiscal_Year__r.End_Date__c,Fiscal_Year__r.Start_Date__c,Budget_Balance__c from COA_FY_Balance__r) from Operational_budget__c where Budget_Line__c in : purOrderTobudgetLine.values() and Department__c in:departmentSet and company_name__c in :companyNameToDates.keyset()] ){
            if(companyNameToDates.containskey(opr.Company_Name__c)){
                for(String st :companyNameToDates.get(opr.company_name__c)){
                    List<String> tempPurchaseOrderMap = st.split(',');
                    for(COA_FY_Balance__c coaBal: opr.COA_FY_Balance__r){
                        if(String.valueOf(coaBal.Fiscal_Year__r.End_Date__c) >= tempPurchaseOrderMap[1] && String.valueOf(coaBal.Fiscal_Year__r.Start_Date__c) <= tempPurchaseOrderMap[1]){
                            finalMap.put(tempPurchaseOrderMap[0],coaBal);
                        }
                    }                
                 }
            }
        }
        
        for(PO_Line_Item__c po : triggerNewList){
            if(finalMap.containsKey(po.Purchase_order__c)){
                po.COA_FY_Balance__c = finalMap.get(po.Purchase_order__c).Id;
                Decimal totalAmount = (po.Amount__c!=null && po.Quantity__c!=null?po.Quantity__c*po.Amount__c:0);
                if(totalAmount > finalMap.get(po.Purchase_order__c).Budget_Balance__c){
                    po.addError('Total Amount should not exceed Budget of COA FY Balance record.');
                }
            }
        }
        
    }
    
}