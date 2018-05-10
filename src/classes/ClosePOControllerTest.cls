@isTest
public class ClosePOControllerTest {
    @isTest
    static void test1(){
        Account ac1=new Account();
        ac1.Name='testAc1';
        insert ac1;
        
        Account ac2=new Account();
        ac2.Name='testAc1';
        insert ac2;
        
        Purchase_Order__c po=new Purchase_Order__c();
        po.PO_Start_Date__c=date.today();
        po.Status__c='Draft';
        po.PO_End_Date__c=date.today()+30;
        po.Currency_Code__c=label.Default_Currency;
        po.X3_Quotes__c = true;
        po.PO_Line_Validation_Bypass__c = false;
        po.Generate_PO_PDF__c=false;
        po.Vendor_Name__c=ac1.id;
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
        insert pol;
        
        Apexpages.CurrentPage().getParameters().put('Id',po.Id);
        ClosePOController cp = new ClosePOController();
        cp.yes();
        
    }
}