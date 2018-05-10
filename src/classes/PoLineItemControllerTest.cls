/*
 *      Name            :       POLineItemPreventDeleteTest
 *      Author          :       Mohd Anas
 *      Date            :       10th July 2017
 *      Description     :       The unit test class for POLineItemPreventDelete trigger
*/
@isTest
public class PoLineItemControllerTest {

    @isTest
    public static void POLineItemPreventDeleteMethod(){
        
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;
        
        Purchase_Order__c purOrder = new Purchase_Order__c();
        purOrder.PO_Start_Date__c = System.today();
        purOrder.Po_End_Date__c = system.today()+20;
        purOrder.Status__c = 'Draft';
        purOrder.Company_Name__c = acc.Id;
        insert purOrder;
        
        Fiscal_year__c fYear = new Fiscal_Year__c();
        fYear.Start_Date__c = System.today().addMonths(-2);
        fYear.End_Date__c = system.today().addmonths(12);
        insert fYear;
        
        Operational_Budget__c op= new Operational_Budget__c();
        op.Budget_Type__c = 'Opex';
        op.Budget_Category__c = 'Projects';
        op.Budget_Line__c = 'Hardware Maintenance';
        op.Company_Name__c = acc.id;
        insert op;
        
        Coa_Fy_Balance__c coa = new COA_FY_Balance__c();
        coa.Budget_Amount__c = 10000;
        coa.PO_Pending__c = 200;
        coa.Fiscal_Year__c = fYear.id;
        coa.Operational_Budget__c = op.id;
        insert coa;
        
        PO_Payment_Arrangement__c poPa = new PO_Payment_Arrangement__c();
        poPa.Purchase_Order__c = purOrder.id;
        poPa.Payment_Due__c = '30 Days';
        insert poPa;
         
        Item_Catalogue__c product = new Item_Catalogue__c();
        product.Name = 'Prod1';
        product.Amount__c = 100;
        product.Department__c ='Operations';
        product.Expiry_Date__c = system.today().addYears(1);
        product.Product_Type__c = 'Consumable';
        product.Status__c = 'Active';
        insert product;
        
        PO_Line_Item__c poLineItem2 = new PO_Line_Item__c();
        poLineItem2.Budget_Line__c = 'Hardware Maintenance';
        poLineItem2.Amount__c = 2000;
        poLineItem2.COA_FY_Balance__c = coa.id;
        poLineItem2.Purchase_Order__c = purOrder.id;
        poLineItem2.Product_Type__c = 'Equipment';
        poLineItem2.Product_Catalogue__c = product.Id;
        insert poLineItem2;
     
        PO_Line_Item__c poLineItem1 = new PO_Line_Item__c();
        poLineItem1.Budget_Line__c = 'Hardware Maintenance';
        poLineItem1.Amount__c = 2000;
        poLineItem1.COA_FY_Balance__c = coa.id;
        poLineItem1.Purchase_Order__c = purOrder.id;
        poLineItem1.Product_Type__c = 'Equipment';
        poLineItem1.Item_Name__c = 'TestPrd';
        insert poLineItem1;
        
        update poLineItem1;
        
        purOrder.Status__c = 'Issued';
        update purOrder; 
        
        
        try {              
            delete poLineItem1;  
            System.Assert(false, 'PO status should be Draft or Rejected');  
        }catch(DMLException e){  
            System.assert(true, 'Deletion failed appropriately');
        }                
    }
}