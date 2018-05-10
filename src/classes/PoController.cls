/*
*    Name             :     PoContoller
*    Author           :     Mohd Anas
*    Date             :     29th June 2017 
*    Description      :     Controller class for triggers on purchase order.
*/

public with sharing class PoController {
    
      public static void PurchaseOrderThreeQuoteValidation(List<Purchase_order__c> triggerList){
        
        Map<Id,recordType> recordTypeMap = new Map<Id,recordType>([Select id,developerName from RecordType where sobjecttype='Purchase_order__c']);
        
        
        Map<Id,integer> poMapToPa = new Map<id,Integer>();
        for(Purchase_Order__c po : triggerList)
            if(recordTypeMap.containsKey(po.recordtypeId) && recordTypeMap.get(po.recordtypeId).DeveloperName=='One_Time'){
                poMapToPa.put(po.id,0);
            }
        
        List<PO_payment_Arrangement__c> poPaList = new List<PO_payment_Arrangement__c>();
        poPaList = [select id,purchase_order__c from PO_payment_Arrangement__c where purchase_order__c in :poMapToPa.keyset()];
        
        for(PO_payment_Arrangement__c  pa: poPaList){
            if(poMapToPa.containsKey(pa.purchase_order__c)){
                poMapToPa.put(pa.purchase_order__c,(poMapToPa.get(pa.purchase_order__c)+1));
            }
            else
                poMapToPa.put(pa.purchase_order__c,1);                 
        }
        
        
        for(Purchase_Order__c po : triggerList){
            if(recordTypeMap.containsKey(po.recordtypeId) && recordTypeMap.get(po.recordtypeId).DeveloperName=='One_Time'){
                if((po.Status__c == 'In-Approval' || po.Status__c == 'Issued') && po.PO_Amount__c>=Integer.valueOf(System.Label.Purchase_Order_Quote_Amount_Validation) && !po.X3_Quotes__c)
                    po.addError('Error : Kindly follow 3 Quote process as PO Amount exceed allocated budget. Please click on the browser back button to go back to PO record.', false);
            }
        }
    }
    
    public static void GeneratePurchaseOrderPDF(List<Purchase_order__c> triggerNewList,Map<id,Purchase_order__c> triggerOldMap){
        Set<Id> pOrderIdSet = new Set<Id>();
        for(Purchase_order__c pOrder : triggerNewList){
            Boolean oldState = triggerOldMap.get(pOrder.id).Generate_PO_PDF__c;
            System.debug('oldState--@@'+oldState);
            System.debug('pOrder.Generate_PO_PDF__c--@@'+pOrder.Generate_PO_PDF__c);
            if(pOrder.Generate_PO_PDF__c && pOrder.Generate_PO_PDF__c != oldState)
                pOrderIdSet.add(pOrder.Id);
        }
        
        if(pOrderIdSet.size()>0)
            DownloadPurchaseOrder.generatePDFAsAttachment(pOrderIdSet);
    }
    
    public static void CancelPurchaseOrder (List<Purchase_order__c> triggerNewList){
        Set<Id> pOrderIdSet = new Set<Id>();
        for(Purchase_order__c po : triggerNewList){
            if(po.Status__c.equals('Cancelled')){
                pOrderIdSet.add(po.Id);
            }
        }
        
        List<PO_Line_Item__c> poLineItemList = [SELECT Id, Quantity__c FROM PO_Line_Item__c WHERE Purchase_Order__c IN : pOrderIdSet]; 
        List<PO_Line_Item__c> newpoLineItemList = new List <PO_Line_Item__c>();
        for(PO_Line_Item__c polineitem : poLineItemList){
            polineitem.Quantity__c = 0;
            newpoLineItemList.add(polineitem);
        }
        update newpoLineItemList;
        
    }   
    
    public static void rollupAmountOnTheBasisOfStatus(List<Purchase_order__c> triggerNewList,Map<id,Purchase_order__c> triggerOldMap){
        Set<Id> purOrdrIds = new Set<Id>();
        
        for(Purchase_Order__c purOrdr : triggerNewList){
            if(purOrdr.Status__c != triggerOldMap.get(purOrdr.Id).Status__c)
                purOrdrIds.add(purOrdr.Id);
        }
        
        if(purOrdrIds.size() > 0){
            RollupPurchaseOrderItemHelper.rollupPurOrdrItmAmount(purOrdrIds);
        }
    }
    
    public static void PurchaseOrderTriggerForVendorUpdate (List<Purchase_order__c> triggerNewList,Map<id,Purchase_order__c> triggerOldMap){
        Set<id> poIdSet = new Set<id>();
        for(Purchase_Order__c po :triggerNewList){
            if(po.vendor_name__c != triggerOldMap.get(po.id).vendor_name__C)
                poIdSet.add(po.id);
        }
        System.debug('poIdSet---@@'+poIdSet);
        List<PO_payment_Arrangement__c> poPaymentArraList = new List<PO_payment_Arrangement__c>();
        if(poIdSet.size()>0)
            poPaymentArraList = [select id from PO_payment_Arrangement__c where Purchase_Order__c in :poIdSet];
        if(poPaymentArraList.size()>0)
            delete poPaymentArraList;
    }
    
    public static void setPOName (List<Purchase_order__c> triggerNewList){
        
        Set<Id> propIds = new Set<Id>();
        for(Purchase_Order__c po:triggerNewList){
            if(po.Property__c!=null){
                propIds.add(po.Property__c);
            }
        }
        
        if(propIds.size()>0){
            
            Map<Id,Property__c> propMap = new Map<Id,Property__c>([Select id,Purchase_Order_Index__c,Short_Code__c from Property__c where id in:propIds]);
            
            List<Property__c> propertyList = new List<Property__c>();
            Set<Id> dupCheck = new Set<Id>();
            for(Purchase_Order__c po:triggerNewList){
                if(po.Property__c!=null && propMap.containsKey(po.Property__c)){
                    property__c prop = propMap.get(po.Property__c);                    
                    Integer IntIndex = 1;
                    if(prop.Purchase_Order_Index__c!=null && prop.Purchase_Order_Index__c>0){
                        intIndex = Integer.valueOf(prop.Purchase_Order_Index__c);
                    }
                    
                    Integer indexSize = string.valueOf(intIndex).length();
                    
                    string index = '';
                    for(integer i =1;i<=6-indexSize;i++){
                        index += '0';
                    }
                    index += string.valueOf(intIndex);
                    po.Name = prop.Short_Code__c+'-PO-'+system.today().Year()+(system.today().Month()<10?'0'+system.today().Month():''+system.today().Month())+(system.today().Day()<10?'0'+system.today().Day():''+system.today().Day())+'-'+index;
                    prop.Purchase_Order_Index__c = intIndex + 1;
                    if(!dupCheck.contains(prop.Id)){
                        propertyList.add(prop);
                        dupCheck.add(prop.Id);
                    }
                }
            }
            
            if(propertyList.size()>0){
                update propertyList;
            }
        }
    }
    
    public static void setValidationByPass(List<Purchase_order__c> triggerNewList, Map<id,Purchase_order__c> triggerOldMap){
        for(Purchase_order__c po:triggerNewList){
            if(po.Status__c=='In-Approval' && po.Status__c!=triggerOldMap.get(po.Id).Status__c){
                po.PO_Line_Validation_Bypass__c = true;
            }
        }    
    }
    
    public static void createNewProduct(List<Purchase_order__c> triggerNewList, Map<id,Purchase_order__c> triggerOldMap){
        Set<Id> poIds = new Set<Id>();
        for(Purchase_order__c po:triggerNewList){
            if(po.Status__c =='In-Approval' && po.Status__c!=triggerOldMap.get(po.Id).Status__c){
                poIds.add(po.Id);
            }
        }
        if(poIds.size()>0){
            Map<Id,List<PO_Line_Item__c>> poToLineItmMap = new Map<Id,List<PO_Line_Item__c>>();
            for(PO_Line_Item__c pli:[Select id,Purchase_Order__c,Item_Name__c,Description__c,Amount__c,Product_Type__c,Department__c from PO_Line_Item__c where Purchase_Order__c in:poIds and Product_Catalogue__c=null and Item_Name__c!=null]){
                List<PO_Line_Item__c> tempList = new List<PO_Line_Item__c>();
                if(poToLineItmMap.containsKey(pli.Purchase_Order__c)){
                    tempList.addAll(poToLineItmMap.get(pli.Purchase_Order__c));
                }
                tempList.add(pli);
                poToLineItmMap.put(pli.Purchase_Order__c,tempList);
            }
            if(poToLineItmMap.size()>0){
                Map<string,Item_Catalogue__c> prodCatMap = new Map<string,Item_Catalogue__c>();
                for(Purchase_Order__c po:triggerNewList){
                    if(poIds.contains(po.Id) && poToLineItmMap.containsKey(po.Id)){
                        for(PO_Line_Item__c pli:poToLineItmMap.get(po.Id)){
                            Item_Catalogue__c prodCat = new Item_Catalogue__c();
                            prodCat.Name = pli.Item_Name__c;
                            prodCat.Description__c = pli.Description__c;
                            prodCat.Amount__c = pli.Amount__c;
                            prodCat.Vendor_Name__c = po.Vendor_Name__c;
                            prodCat.Expiry_Date__c = system.Today().addYears(1);
                            prodCat.Product_Type__c = pli.Product_Type__c;
                            prodCat.Department__c = pli.Department__c;
                            prodCat.Status__c = 'Active';
                            prodCatMap.put(prodCat.Name,prodCat);
                        }
                    }
                }
                if(prodCatMap.size()>0){
                    insert prodCatMap.values();
                    
                    List<PO_Line_Item__c> lineItemList = new List<PO_Line_Item__c>();
                    for(Purchase_Order__c po:triggerNewList){
                        if(poIds.contains(po.Id) && poToLineItmMap.containsKey(po.Id)){
                            for(PO_Line_Item__c pli:poToLineItmMap.get(po.Id)){
                                if(prodCatMap.containsKey(pli.Item_Name__c)){
                                    pli.Product_Catalogue__c = prodCatMap.get(pli.Item_Name__c).Id;
                                    lineItemList.add(pli);
                                }
                            }
                        }
                    }
                    if(lineItemList.size()>0){
                        update lineItemList;
                    }
                }
            }
        }
        List<Purchase_Order__c> updatePOList = new List<Purchase_Order__c>();
        for(Purchase_Order__c po:triggerNewList){
            if(poIds.contains(po.Id)){
                Purchase_Order__c updPO = new Purchase_Order__c();
                updPo.Id = po.Id;
                updPo.PO_Line_Validation_Bypass__c = false;
                updatePOList.add(updPo);
            }
        }
        if(updatePOList.size()>0){
            update updatePOList;
        }  
    }
    
    public static void createDOA(List<Purchase_order__c> triggerNewList, Map<id,Purchase_order__c> triggerOldMap){
        Set<Id> propId = new Set<Id>();
        Set<Id> poId = new Set<Id>();
        List <Purchase_order__c> ponewlist = new List <Purchase_order__c>();

        for(Purchase_order__c po: triggerNewList){
            propId.add(po.Property__c);
            ponewlist.add(po);
            if(triggerOldMap==null || triggerOldMap.get(po.Id) == null)
                ponewlist.add(po);
            else{
                if(po.Department__c != triggerOldMap.get(po.Id).Department__c){
                    poId.add(po.Id);
                    ponewlist.add(po);
                }
                    
            }
        }
        
        List <DOA__c> doaList = [Select Id, Approver__c, Approver_Email__c, Approver_Title__c, Condition__c, Department__c, Level__c, Property__c from DOA__c where Property__c in :propId and Purchase_Order__c = ''];
        List <DOA__c> doaPOList = [Select Id from DOA__c where Purchase_Order__c in :poId];
        List <DOA__c> daonewlist = new List <DOA__c> ();
        
        for(Purchase_order__c po: ponewlist){          
            for(DOA__c doa: doaList){
                if(doa.Property__c == po.Property__c && doa.Department__c == po.Department__c)
                {
                    DOA__c doa1 = new DOA__c();
                    doa1.Approver__c = doa.Approver__c;
                    doa1.Condition__c = doa.Condition__c;
                    doa1.Department__c = doa.Department__c;
                    doa1.Level__c = doa.Level__c;
                    doa1.Purchase_Order__c = po.Id; 
                    daonewlist.add(doa1);
                }
            } 
        }

        insert daonewlist;
        delete doaPOList;
        
    } 

}