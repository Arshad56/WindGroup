/*
* Name             :       ThreeDimensionalCheckInvoiceReceiptTest
* Author           :       Prabhakar Joshi
* Date             :       05 July 2017
* Description      :       Test class for ThreeDimensionalCheckForInvoiceReceipt.
*/


@isTest
public class ThreeDimensionalCheckInvoiceReceiptTest {
@isTest
    static void test1(){
        Account ac1=new Account();
        ac1.Name='testAc1';
        insert ac1;
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Issued';
        po.PO_End_Date__c=date.today()+30;
        
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        insert po;
        
        Purchase_Order__c po2=new Purchase_Order__c();
        po2.PO_Start_Date__c=date.today();
        po2.Status__c='Issued';
        po2.PO_End_Date__c=date.today()+30;
        po2.Currency_Code__c=label.Default_Currency;
        po2.X3_Quotes__c = true;
        po2.PO_Line_Validation_Bypass__c = false;
        insert po2;
        
        COA_FY_Balance__c cb=new COA_FY_Balance__c();
        cb.Budget_Amount__c=3000;
        insert cb;
        
        PO_Line_Item__c pol=new PO_Line_Item__c();
        pol.Amount__c=2000;
        pol.COA_FY_Balance__c=cb.Id;
        pol.Purchase_Order__c=po.Id;
        pol.Budget_Line__c='Lift';
        pol.Quantity__c=1;
        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Payment_Term__c=2;
        pa.Purchase_Order__c=po.Id;
        insert pa;
        
        Invoice_Receipt__c ir=new Invoice_Receipt__c();
        ir.Purchase_Order__c=po.id;
        ir.Amount__c=0;
       
        ir.PO_Payment_Arrangement__c=pa.id;
        insert ir;
        
        Invoice_Receipt__c ir2=new Invoice_Receipt__c();
        ir2.Purchase_Order__c=po.id;
        ir2.PO_Payment_Arrangement__c=pa.id;
        insert ir2;
        
    }
}