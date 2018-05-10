@isTest
public class InvoiceReceiptControllerTest {
@isTest
    static void test1(){
        
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Draft';
        po.PO_End_Date__c=date.today()+30;
        
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        insert po;
                
        
        COA_FY_Balance__c cb=new COA_FY_Balance__c();
        cb.Budget_Amount__c=3000;
        insert cb;
        
        PO_Line_Item__c pol=new PO_Line_Item__c();
        pol.Amount__c=2000;
        pol.COA_FY_Balance__c=cb.Id;
        pol.Purchase_Order__c=po.Id;
        pol.Budget_Line__c='Hardware Maintenance';
        pol.Product_Type__c = 'Equipment';
        pol.Quantity__c=1;
        insert pol;
        
        po.PO_Line_Validation_Bypass__c = true;
        po.Status__c='Issued';
        update po;
        
        Goods_Receipt__c gr=new Goods_Receipt__c();
        gr.Purchase_Order__c=po.Id;
        insert gr;
        
        GR_Line_Item__c gri=new GR_Line_Item__c();
        gri.PO_Line_Item__c=pol.Id;
        gri.Goods_Receipt__c=gr.Id;
        insert gri;
        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Payment_Term__c=2;
        pa.Purchase_Order__c=po.Id;
        insert pa;
        
        Invoice_Receipt__c ir1=new Invoice_Receipt__c();
        ir1.Purchase_Order__c=po.id;
        ir1.Amount__c=10;
        ir1.PO_Payment_Arrangement__c=pa.id;
        insert ir1;
        
        Invoice_Receipt__c ir=new Invoice_Receipt__c();
        ir.Purchase_Order__c=po.id;
        ir.Amount__c=0;
        ir.Goods_Receipt__c = gr.Id;
        ir.PO_Payment_Arrangement__c=pa.id;
        insert ir;
        
        InvoiceReceiptController.updateRecord (ir.Id,'Paid',po.Id);
        
        List<Invoice_Receipt__c> irList = new List<Invoice_Receipt__c>();
        irList.add(ir);
        
        InvoiceReceiptController.InvoiceReceiptValidation(irList);
        
    }
}