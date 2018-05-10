trigger ManageInventoryTrigger on GR_Line_Item__c (after insert) {
    Set<Id> poLineItmIds = new Set<Id>();
    for(GR_Line_Item__c gli:Trigger.New){
        poLineItmIds.add(gli.PO_Line_Item__c);
    }
    
    Set<Id> productIds = new Set<Id>();
    Map<Id,Id> LineItmToProductMap = new Map<Id,Id>();
    Map<Id,PO_Line_Item__c> poLineItemMap = new Map<Id,PO_Line_Item__c>();
    for(PO_Line_Item__c pli:[Select id,Product_Catalogue__c,Purchase_Order__r.Property__c,Purchase_Order__r.Property__r.Equipment_Index__c,Purchase_Order__r.Property__r.Short_Code__c from PO_Line_Item__c where id in:poLineItmIds and Product_Catalogue__r.Product_Type__c in('Consumable','Equipment') and Product_Catalogue__c!=null]){
        productIds.add(pli.Product_Catalogue__c);
        poLineItemMap.put(pli.id,pli);
        LineItmToProductMap.put(pli.Id,pli.Product_Catalogue__c);
    }
    
    if(productIds.size()>0){
        Map<Id,Item_Catalogue__c> prodCatMap = new Map<Id,Item_Catalogue__c>([Select id,Name,Amount__c,Department__c,Description__c, Product_Type__c,(Select id,Stock_Warehouse__c from Inventory__r where Default__c=true) from Item_Catalogue__c where id in:productIds]);
        
        if(prodCatMap.size()>0){
            List<Stock__c> defaultStock = [Select id from Stock__c where Default__c= true limit 1];
            Map<id,InventoryWrapper> prodInvWrapMap = new Map<id,InventoryWrapper>();
            List<Inventory__c> inventoryList = new List<Inventory__c>();
            Map<Id,Property__c> propMap = new Map<Id,Property__c>();
            for(GR_Line_Item__c gli:Trigger.New){
                if(LineItmToProductMap.containsKey(gli.PO_Line_Item__c) && prodCatMap.containsKey(LineItmToProductMap.get(gli.PO_Line_Item__c))){
                    Item_Catalogue__c prodCat = prodCatMap.get(LineItmToProductMap.get(gli.PO_Line_Item__c));
                    
                    InventoryWrapper invWrap = new InventoryWrapper();
                    if(prodInvWrapMap.containsKey(prodCat.Id)){
                        invWrap = prodInvWrapMap.get(prodCat.Id);
                    }
                    if(prodCat.Inventory__r.size()==0){
                        if(defaultStock.size()>0){
                            invWrap.Inv.Stock_Warehouse__c = defaultStock[0].Id;
                        }
                        invWrap.inv.Product_Name__c = prodCat.Id;
                        invWrap.inv.Product_Decription__c = prodCat.Description__c;
                        invWrap.inv.Status__c = 'Active';
                        invWrap.inv.Property__c = poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__c;
                        if(prodCat.Product_Type__c=='Equipment')
                            invWrap.inv.RecordTypeId = Schema.SObjectType.Inventory__c.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
                        else if (prodCat.Product_Type__c=='Consumable')
                            invWrap.inv.RecordTypeId = Schema.SObjectType.Inventory__c.getRecordTypeInfosByName().get('Consumable').getRecordTypeId();
                        inventoryList.add(invWrap.inv);
                    }else{
                        invWrap.inv = prodCat.Inventory__r[0];
                    }
                                        
                    Inventory_Tracking__c invTrack = new Inventory_Tracking__c();
                    invTrack.Action__c = 'New';
                    invTrack.IN_OUT__c = 'In';
                    invTrack.GR_Line_Item__c = gli.Id;
                    invTrack.Product_Name__c = prodCat.Id;
                    invTrack.Quantity__c = gli.Quantity__c;
                    invTrack.Remarks__c = gli.description__c;
                    invTrack.Stock_Warehouse__c = invWrap.Inv.Stock_Warehouse__c;
                    invWrap.invTrackList.add(invTrack);
                    
                    if(prodCat.Product_Type__c=='Equipment' && gli.Quantity__c > 0){
                        for(Integer i=1;i<=gli.Quantity__c;i++){
                            Equipment__c eqt = new Equipment__c();
                            eqt.Name = prodCat.Name;
                            eqt.Product_Name__c = prodcat.Id;
                            eqt.GR_Line_Item__c = gli.Id;
                            invWrap.equipmentList.add(eqt);
                            if(poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__c!=null && prodCat.Department__c!=null){
                                Integer IntIndex = 1;
                                if(poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__r.Equipment_Index__c!=null && poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__r.Equipment_Index__c>0){
                                    intIndex = Integer.valueOf(poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__r.Equipment_Index__c);
                                }
                                
                                Integer indexSize = string.valueOf(intIndex).length();
                                
                                string index = '';
                                for(integer j =1;j<=6-indexSize;j++){
                                    index += '0';
                                }
                                index += string.valueOf(intIndex);
                                
                                eqt.Name = poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__r.Short_Code__c+'-';
                                if(prodCat.Department__c=='Operations'){
                                    eqt.Name += 'OP-EQ-'+index;
                                }else if(prodCat.Department__c=='Leasing'){
                                    eqt.Name += 'LS-EQ-'+index;
                                }else if(prodCat.Department__c=='Marketing'){
                                    eqt.Name += 'MK-EQ-'+index;
                                }else if(prodCat.Department__c=='Finance'){
                                    eqt.Name += 'FI-EQ-'+index;
                                }else if(prodCat.Department__c=='IT'){
                                    eqt.Name += 'IT-EQ-'+index;
                                }
                                
                                property__c prop = new Property__c();
                                prop.Id = poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__c;
                                prop.Equipment_Index__c = intIndex + 1;
                                poLineItemMap.get(gli.PO_Line_Item__c).Purchase_Order__r.Property__r.Equipment_Index__c = prop.Equipment_Index__c;
                                propMap.put(prop.Id,prop);
                            }
                        }
                    }
                    
                    prodInvWrapMap.put(prodCat.Id,invWrap);
                }
            }
            update propMap.values();
            if(inventoryList.size()>0){
                insert inventoryList;
            }
            
            if(prodInvWrapMap.size()>0){
                List<Inventory_Tracking__c> invTrackList = new List<Inventory_Tracking__c>();
                List<Equipment__c> equipList = new List<Equipment__c>();
                for(Id prId:prodInvWrapMap.keyset()){
                    InventoryWrapper invWrap = prodInvWrapMap.get(prId);
                    if(invWrap.inv.Id!=null){
                        for(Inventory_Tracking__c invTrack:invWrap.invTrackList){
                            invTrack.Inventory_ID__c = invWrap.inv.Id;
                            invTrackList.add(invTrack);
                        }
                        
                        for(Equipment__c eqt:invWrap.equipmentList){
                            eqt.Inventory_ID__c = invWrap.inv.Id;
                            equipList.add(eqt);
                        }
                    }
                }
                
                insert invTrackList;
                
                if(equipList.size()>0){
                    insert equipList;
                }
            }
        }
    }
    
    Class InventoryWrapper{
        Inventory__c inv;
        List<Inventory_Tracking__c> invTrackList;
        List<Equipment__c> equipmentList;
        InventoryWrapper(){
            inv = new Inventory__c();
            invTrackList = new List<Inventory_Tracking__c>();
            equipmentList = new List<Equipment__c>();
        }
    }
}