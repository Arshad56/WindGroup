/*
* Name             :       GenerateGRControllerTest
* Author           :       Prabhakar Joshi
* Date             :       05 July 2017
* Description      :       Test class for GenerateGRController.
*/


@isTest
public class GenerateGRControllerTest {
@isTest
    static void test1(){
        
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
        po.Property__c = prop.Id;
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
        
        

        
        PO_Payment_Arrangement__c pa=new PO_Payment_Arrangement__c();
        pa.Purchase_Order__c=po.Id;
        insert pa;
          
              
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
        
        
       
        
        PageReference pageRef = Page.generateGR;
        pageRef.getParameters().put('poId',po.Id);
        Test.setCurrentPage(pageRef);
        GenerateGRController obj=new GenerateGRController();
        //obj.delRow();
        obj.index=5;
        obj.saveGRWithLineItems();
        obj.indexValRemove=0;
        obj.delRow();
        
        
        
    }
}