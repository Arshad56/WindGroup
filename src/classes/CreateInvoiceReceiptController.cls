public class CreateInvoiceReceiptController{
    public Purchase_Order__c purOrder{get;set;}
    public List<GoodReceiptWrapper> goodReceiptList{get;set;}
    public CreateInvoiceReceiptController(){
        goodReceiptList = new List<GoodReceiptWrapper>();
        String poId = Apexpages.CurrentPage().getParameters().get('Id');
        purOrder = New Purchase_Order__c();
        for(Purchase_Order__c po:[Select id,Vendor_Name__c,Property__c,property__r.Invoice_Receipt_Index__c,Property__r.Short_Code__c,(Select id,Name,GR_Quantity__c,Currency_Code__c,GR_Amount__c,GR_Date__c,Tax_Amount__c,Invoice_Created__c from Goods_Receipts__r where Void__c=false and Invoice_Created__c=false) from Purchase_Order__c where id=:poId limit 1]){
            purOrder = po;
            for(Goods_Receipt__c gr:po.Goods_Receipts__r){
                GoodReceiptWrapper grWrap = new GoodReceiptWrapper();
                grWrap.goodReceipt = gr;
                goodReceiptList.add(grWrap);
            }
        }
    }
    
    public pageReference CreateInvoiceReceipt(){
        if(goodReceiptList.size()>0){
            Boolean recordSelected = false;
            for(GoodReceiptWrapper grWrap:GoodReceiptList){
                if(grWrap.isSelected){
                    recordSelected = true;
                    break;
                }                
            }
            if(recordSelected){
                List<Invoice_Receipt__c> invReceipts = new List<Invoice_Receipt__c>();
                Property__c prop = new Property__c();
                prop.Id = purOrder.Property__c;
                prop.Invoice_Receipt_Index__c = purOrder.Property__r.Invoice_Receipt_Index__c;
                prop.Short_Code__c = purOrder.Property__r.Short_Code__c;
                Integer IntIndex = 1;
                if(prop.Invoice_Receipt_Index__c!=null && prop.Invoice_Receipt_Index__c>0){
                    intIndex = Integer.valueOf(prop.Invoice_Receipt_Index__c);
                }
                List<Goods_Receipt__c> goodReceipts = new List<Goods_Receipt__c>();
                for(GoodReceiptWrapper grWrap:GoodReceiptList){
                    if(grWrap.isSelected){
                        Invoice_Receipt__c ir = new Invoice_Receipt__c();
                        ir.Purchase_Order__c = purOrder.Id;
                        ir.Goods_Receipt__c = grWrap.goodReceipt.Id;
                        ir.Amount__c = grWrap.goodReceipt.GR_Amount__c;
                        ir.Currency_Code__c = grWrap.goodReceipt.Currency_Code__c;
                        ir.Description__c = grWrap.remarks;
                        ir.Invoice_Date__c = system.today();
                        ir.Invoice_Due_Date__c = system.today();
                        ir.Tax__c = grWrap.goodReceipt.Tax_Amount__c;
                        ir.Vendor_Name__c = purOrder.Vendor_Name__c;
                        
                        Integer indexSize = string.valueOf(intIndex).length();
                        string index = '';
                        for(integer i =1;i<=6-indexSize;i++){
                            index += '0';
                        }
                        index += string.valueOf(intIndex);
                        ir.Invoice_Number__c = prop.Short_Code__c+'-IR-'+system.today().Year()+(system.today().Month()<10?'0'+system.today().Month():''+system.today().Month())+'-'+index;
                        invReceipts.add(ir);
                        intIndex++;
                        grWrap.goodReceipt.Invoice_Created__c = true;
                        
                        goodReceipts.add(grWrap.goodReceipt);
                    }
                    
                    prop.Invoice_Receipt_Index__c = intIndex;
                    update prop;
                    
                    if(invReceipts.size()>0){
                        insert invReceipts;
                    }
                    
                    if(goodReceipts.size()>0){
                        update goodReceipts;
                    }
                    
                    return new pageReference('/'+purOrder.Id);
                }
            }else{
                Apexpages.AddMessage(new Apexpages.Message(Apexpages.Severity.Error,'Please select atleast 1 record.'));
            }
        }else{
            Apexpages.AddMessage(new Apexpages.Message(Apexpages.Severity.Error,'No goods receipts found under this Purchase Order.'));
        }
        return null;
    }
    
    public class GoodReceiptWrapper{
        public Goods_Receipt__c goodReceipt{get;set;}
        public Boolean isSelected{get;set;}
        public string remarks{get;set;}
        public GoodReceiptWrapper(){
            isSelected = false;
            goodReceipt = new Goods_Receipt__c();
        }
    }
}