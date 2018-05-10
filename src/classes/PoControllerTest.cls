/*
* Name             :       poTriggerHelperTest
* Author           :       Prabhakar Joshi
* Date             :       05 July 2017
* Description      :       Test class for PoTriggerHelper class.
*/

@isTest
public class PoControllerTest {
    @isTest
    static void test1(){
        Account ac1=new Account();
        ac1.Name='testAc1';
        insert ac1;
        
        Account ac2=new Account();
        ac2.Name='testAc1';
        insert ac2;
        
        Property__c prop = new Property__c();
        prop.Name = 'TestProp';
        insert prop;
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Draft';
        po.PO_End_Date__c=date.today()+30;
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        po.Generate_PO_PDF__c=false;
        po.Vendor_Name__c=ac1.id;
        po.Property__c = prop.Id;
        insert po;
        po.Generate_PO_PDF__c=true;
        po.Vendor_Name__c=ac2.id;
        
        update po;
        
        COA_FY_Balance__c cb=new COA_FY_Balance__c();
        cb.Budget_Amount__c=3000;
        insert cb;
        
        PO_Line_Item__c pol=new PO_Line_Item__c();
        pol.Amount__c=2000;
        pol.COA_FY_Balance__c=cb.Id;
        pol.Purchase_Order__c=po.Id;
        pol.Budget_Line__c='Hardware Maintenance';
        pol.Quantity__c=1;
        pol.Product_Type__c = 'Service';
        pol.Item_Name__c = 'TestPr';
        insert pol;
        
        
        
        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Purchase_Order__c=po.Id;
        insert pa;
        
        po.PO_Line_Validation_Bypass__c = true;
        po.Status__c='In-Approval';
        update po;
        
        po.PO_Line_Validation_Bypass__c = true;
        po.Status__c='Issued';
        update po;
        
        
        
        Goods_Receipt__c gr=new Goods_Receipt__c();
        gr.Purchase_Order__c=po.Id;
        //gr.Vendor_Name__c=ac.Id;
        insert gr;
        
        
        
        GR_Line_Item__c gri=new GR_Line_Item__c();
        gri.PO_Line_Item__c=pol.Id;
        gri.Goods_Receipt__c=gr.Id;
        insert gri;
        
        
        PoController obj=new PoController();
        
    }
}