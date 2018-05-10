public class ProductReplaceController{
    public Equipment__c prodLookup{get;set;}
    public Date replaceDate{get;set;}
    public string remarks{get;set;}
    public Item_Catalogue__c product{get;set;}
    public Boolean success{get;set;}
    Set<Id> stockIds = new Set<Id>();
    Map<Id,Inventory__c> invMap = new Map<Id,Inventory__c>();
    public ProductReplaceController(){
        success= false;
        replaceDate = system.Today();
        prodLookup = new Equipment__c();
        product = new Item_Catalogue__c();
        string prodId = Apexpages.CurrentPage().getParameters().get('Id');
        for(Item_Catalogue__c ic:[select id,Name,Product_Type__c,(Select id,Name,Available_Qty__c,Stock_Warehouse__c from Inventory__r where Available_Qty__c > 0) from Item_Catalogue__c where id=:prodId limit 1]){
            product = ic;
            for(Inventory__c inv:ic.Inventory__r){
                invMap.put(inv.Id,inv);
                stockIds.add(inv.Stock_Warehouse__c);
            }
        }
    }
    
    public void replace(){
        success= false;
        if(product.Id!=null){
            if(stockIds.size()>0){
                if(prodLookup.Product_Name__c!=null){
                    if(product.Id==prodLookup.Product_Name__c){
                        Apexpages.AddMessage(new Apexpages.message(APexpages.Severity.Error,'Please select different product.'));
                        return;
                    }
                    Map<Id,Inventory__c> stockToInvMap = new Map<Id,Inventory__c>();
                    for(Inventory__c inv:[Select id,Name,Available_Qty__c,Stock_Warehouse__c,Product_Name__c from Inventory__c where Product_Name__c=:prodLookup.Product_Name__c and Stock_Warehouse__c in:stockIds]){
                        stockToInvMap.put(inv.Stock_Warehouse__c,inv);
                    }
                    if(stockToInvMap.size()!=stockIds.size()){
                        List<Inventory__c> invList = new List<Inventory__c>();
                        for(Id sId:stockIds){
                            if(!stockToInvMap.containsKey(sId)){
                                Inventory__c inv = new Inventory__c();
                                inv.Product_Name__c = prodLookup.Product_Name__c;
                                inv.Stock_Warehouse__c = sId;
                                invList.add(inv);
                            }
                        }
                        
                        if(invList.size()>0){
                            insert invList;
                            for(Inventory__c inv:[Select id,Name,Available_Qty__c,Stock_Warehouse__c,Product_Name__c from Inventory__c where Product_Name__c=:prodLookup.Product_Name__c and Stock_Warehouse__c in:stockIds]){
                                stockToInvMap.put(inv.Stock_Warehouse__c,inv);
                            }
                        }
                    }
                    
                    if(product.Product_Type__c=='Consumable'){
                        List<Inventory_Tracking__c> invTrackList = new List<Inventory_Tracking__c>();
                        for(Inventory__c inv:product.Inventory__r){
                            Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                            invTrack1.Action__c = 'Replace';
                            invTrack1.Date__c = replaceDate;
                            invTrack1.IN_OUT__c = 'Out';
                            invTrack1.Product_Name__c = product.Id;
                            invTrack1.Quantity__c = inv.Available_Qty__c;
                            if(stockToInvMap.containsKey(inv.Stock_Warehouse__c)){
                                invTrack1.Remarks__c = 'Replaced to '+stockToInvMap.GET(inv.Stock_Warehouse__c).Name;
                            }
                            invTrack1.Inventory_ID__c = inv.Id;
                            invTrackList.add(invTrack1);
                            
                            if(stockToInvMap.containsKey(inv.Stock_Warehouse__c)){
                                Inventory__c newInv = stockToInvMap.get(inv.Stock_Warehouse__c);
                                Inventory_Tracking__c invTrack2 = new Inventory_Tracking__c();
                                invTrack2.Action__c = 'Replace';
                                invTrack2.Date__c = replaceDate;
                                invTrack2.IN_OUT__c = 'In';
                                invTrack2.Product_Name__c = prodLookup.Product_Name__c;
                                invTrack2.Quantity__c = inv.Available_Qty__c;
                                invTrack2.Remarks__c = 'Replaced from '+inv.Name;
                                invTrack2.Inventory_ID__c = newInv.Id;
                                invTrackList.add(invTrack2);
                            }                            
                        }
                        insert invTrackList;
                        product.Status__c = 'Replaced';
                        update product;                                                
                        success = true;
                    }else if(product.Product_Type__c=='Equipment'){
                        List<Equipment__c> equipments = [Select id,Inventory_ID__c,Inventory_ID__r.Stock_Warehouse__c,Inventory_ID__r.Name from Equipment__c where Inventory_ID__c in:invMap.keyset() and Status__c='Active'];
                        List<Inventory_Tracking__c> invTrackList = new List<Inventory_Tracking__c>();
                        for(Equipment__c eqp:equipments){
                            Inventory_Tracking__c invTrack1 = new Inventory_Tracking__c();
                            invTrack1.Action__c = 'Replace';
                            invTrack1.Date__c = replaceDate;
                            invTrack1.IN_OUT__c = 'Out';
                            invTrack1.Product_Name__c = product.Id;
                            invTrack1.Quantity__c = 1;
                            if(stockToInvMap.containsKey(eqp.Inventory_ID__r.Stock_Warehouse__c)){
                                invTrack1.Remarks__c = 'Replaced to '+stockToInvMap.GET(eqp.Inventory_ID__r.Stock_Warehouse__c).Name;
                            }
                            invTrack1.Inventory_ID__c = eqp.Inventory_ID__c;
                            invTrack1.Equipment__c = eqp.Id;
                            invTrackList.add(invTrack1);
                            
                            if(stockToInvMap.containsKey(eqp.Inventory_ID__r.Stock_Warehouse__c)){
                                Inventory__c newInv = stockToInvMap.get(eqp.Inventory_ID__r.Stock_Warehouse__c);
                                Inventory_Tracking__c invTrack2 = new Inventory_Tracking__c();
                                invTrack2.Action__c = 'Replace';
                                invTrack2.Date__c = replaceDate;
                                invTrack2.IN_OUT__c = 'In';
                                invTrack2.Product_Name__c = prodLookup.Product_Name__c;
                                invTrack2.Quantity__c = 1;
                                invTrack2.Remarks__c = 'Replaced from '+eqp.Inventory_ID__r.Name;
                                invTrack2.Inventory_ID__c = newInv.Id;
                                invTrack2.Equipment__c = eqp.Id;
                                invTrackList.add(invTrack2);
                                
                                eqp.Inventory_ID__c = newInv.Id;
                                eqp.Product_Name__c = prodLookUp.Product_Name__c;
                                eqp.Remarks__c = remarks;
                            }
                            
                            
                        }
                        
                        insert invTrackList;
                        update equipments;

                        product.Status__c = 'Replaced';
                        update product;                                                
                        success = true;
                    }
                }else{
                    Apexpages.AddMessage(new Apexpages.message(APexpages.Severity.Error,'Please select the new product to replace exiting product.'));    
                }
            }else{
                Apexpages.AddMessage(new Apexpages.message(APexpages.Severity.Error,'Existing product dont have any inventory to replace.'));
            }
        }else{
            Apexpages.AddMessage(new Apexpages.message(APexpages.Severity.Error,'Product Catalogue not found.'));
        }
    }
}