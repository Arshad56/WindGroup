/*
*    Name             :     GenerateGRController
*    Author           :     Prabhakar
*    Date             :     29th June 2017 
*    Editted by       :     Mohd Anas
*    Description      :     Controller to generate Goods Receipt
*/

public class GenerateGRController{

    public Goods_Receipt__c GR{ get; set;}
    public List<GR_Line_Item__c> GRlineItem{ get; set;}
    public integer index{get; set;}
    public Purchase_order__c purOrder;
    public Boolean validationSuccess;
    public integer indexValRemove { get; set; }
    public Map<Id,Decimal> grLineItemToBalance{get;set;}
    public Boolean itemError { get; set; }
    
    public GenerateGRController(){
        validationSuccess = true;
        itemError = false;
        id poId = ApexPages.CurrentPage().getParameters().get('poId');
        GR =new Goods_Receipt__c();
        if(poId != NULL){
            purOrder = [SELECT name,vendor_name__c,Vendor_Contact__c,Currency_Code__c,Property__c,Property__r.Good_Receipt_Index__c,Property__r.Short_Code__c ,(select Currency_Code__c, Item_Name__c,Product_Catalogue__c,Amount__c,Balance_Quantity__c,Total_Amount__c,Description__c from PO_Line_Items__r) 
                        FROM Purchase_order__c 
                        WHERE id = :poId];
            GR.Purchase_Order__c = purOrder.id;
            GR.Currency_Code__c = purOrder.Currency_Code__c;
            GR.Contact_Name__c = purOrder.Vendor_Contact__c;
            GR.Vendor_Name__c = purOrder.vendor_name__c;
            GR.GR_Date__c = System.today();
            
            GRlineItem = new List<GR_Line_Item__c>();
            grLineItemToBalance = new Map<Id,Decimal>(); 
            integer count=0;
            system.debug(purOrder.PO_Line_Items__r);
            
            system.debug(purOrder.PO_Line_Items__r);
            
            Set<Id> prodCatIds = new Set<Id>();
                for(PO_Line_Item__c pli: purOrder.PO_Line_Items__r){
                    if(pli.Balance_Quantity__c > 0){
                        GR_Line_Item__c gl = new GR_Line_Item__c();
                        gl.Item_Name__c=pli.Item_Name__c;
                        gl.Currency_Code__c=pli.Currency_Code__c;
                        gl.Amount__c=pli.Amount__c;
                        gl.Quantity__c=pli.Balance_Quantity__c;
                        gl.Description__c =pli.Description__c;
                        gl.PO_Line_Item__c=pli.id;
                        gl.recalculateFormulas();
                        GRlineItem.add(gl);
                        grLineItemToBalance.put(pli.id,pli.Balance_Quantity__c);
                        
                        if(pli.Product_Catalogue__c!=null){
                            prodCatIds.add(pli.Product_Catalogue__c);
                        }
                    }
                                 
                }
            System.debug('grLineItemToBalance.size()---@@'+grLineItemToBalance.size());
            if(grLineItemToBalance.size()<=0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,' No Item Found'));
                itemError=true;
            }
            
            if(prodCatIds.size()>0){
                List<Item_Catalogue__c> itemCatList = [Select id,Name,Amount__c,Department__c,Description__c, Product_Type__c,(Select id,Stock_Warehouse__c,Stock_Warehouse__r.Stock_Freeze__c from Inventory__r where Default__c=true) from Item_Catalogue__c where id in:prodCatIds];
                for(Item_Catalogue__c ic:itemCatList){
                    for(Inventory__c inv:ic.Inventory__r){
                        if(inv.Stock_Warehouse__r.Stock_Freeze__c){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,'Warehouse is freezed for stock take.'));
                            itemError=true;
                            break;
                        }
                    }
                }
            }
            
            system.debug(grLineItemToBalance);            
         }
     }
        
        
        public void validate(){
            if(index != NULL){
                integer count=0;
                for(integer i=0;i<GRlineItem.size();i++){
                    GRlineItem[i].recalculateFormulas();
                    if(grLineItemToBalance.containsKey(GRlineItem[i].PO_Line_Item__c)){
                        if(GRlineItem[i].Quantity__c > grLineItemToBalance.get(GRlineItem[i].PO_Line_Item__c)){
                            GRlineItem[i].Quantity__c.addError('Value Exceeds');
                            count++;
                        }else if(GRlineItem[i].Quantity__c == 0){
                            GRlineItem[i].Quantity__c.addError('cannot be 0');
                            count++;
                        }
                    }
                }
                validationSuccess = count>0||itemError?false:true;            
            }
            
        }
        
      
        public pageReference saveGRWithLineItems(){
            validate();
            if(validationSuccess){
                SavePoint sp = database.setSavePoint();
                try{
                    
                    Purchase_Order__c ValidatePO = [SELECT PO_Line_Validation_Bypass__c 
                                                    FROM Purchase_Order__c 
                                                    WHERE id = :GR.Purchase_Order__c];
                    boolean changedToValidate = false;
                    if(!validatePO.PO_Line_Validation_Bypass__c){
                        changedToValidate = true;
                        validatePO.PO_Line_Validation_Bypass__c = True;
                        update validatePO;
                    }
                    
                    
                    if(GRlineItem.size()>0){                    
                        if(purOrder!=null && purOrder.Property__c!=null){
                            Integer IntIndex = 1;
                            if(purOrder.Property__r.Good_Receipt_Index__c!=null && purOrder.Property__r.Good_Receipt_Index__c>0){
                                intIndex = Integer.valueOf(purOrder.Property__r.Good_Receipt_Index__c);
                            }
                            
                            Integer indexSize = string.valueOf(intIndex).length();
                            
                            string index = '';
                            for(integer i =1;i<=6-indexSize;i++){
                                index += '0';
                            }
                            index += string.valueOf(intIndex);
                            
                            gr.Name = purOrder.Property__r.Short_Code__c +'-GR-'+system.today().Year()+(system.today().Month()<10?'0'+system.today().Month():''+system.today().Month())+(system.today().Day()<10?'0'+system.today().Day():''+system.today().Day())+'-'+index;
                            
                            Property__c prop = new Property__c();
                            prop.Id = purOrder.Property__c;
                            prop.Good_Receipt_Index__c = intIndex + 1;
                            update prop;
                        }
                        insert GR;
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,' At least one line item is required'));
                        return NULL;
                    }
                    
                        
                    
                    List<GR_Line_Item__c> grInsertList = new List<GR_Line_Item__c>();
                    for(GR_Line_Item__c grLine : GRlineItem){
                        if(grLine.quantity__c != 0){
                            grLine.Goods_Receipt__c = GR.id;
                            grInsertList.add(grLine);
                        }
                    }
                    insert grInsertList;
                    if(changedToValidate){
                        validatePO.PO_Line_Validation_Bypass__c = false;
                        update validatePO;
                    }
                }
                catch(Exception e){
                    database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Insert Failed'));
                    return null;
                }
                return(new pageReference('/'+GR.id));
            }
            else{
                return null;
            }
        }
        
        
        public void delRow(){
        
            system.debug(indexValRemove);
            GRlineItem.remove(indexValRemove);
            system.debug(GRlineItem);
        }
        
    }