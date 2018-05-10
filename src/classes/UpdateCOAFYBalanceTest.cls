/*
 * Name             :       UpdateCOAFYBalanceTest
 * Author           :       Mohd Anas
 * modified by              Akhtar Husain
 * Date             :       08 June 2017
 * Description      :       Unit test Class For UpdateCOAFYBalance Trigger
*/
@isTest
public class UpdateCOAFYBalanceTest{

    @isTest
    public static void UpdateCOAFYBalanceTestMethod(){
        Account acc = new Account();
        acc.name = 'TestAccount';
        insert acc;
        
        List<Purchase_Order__c> purOrderList = new List<Purchase_Order__c>();
        Purchase_Order__c purOrder = new Purchase_Order__c();
        purOrder.Company_Name__c = acc.id;
        purOrder.PO_Start_Date__c = System.today();
        purOrder.Po_End_Date__c = purOrder.PO_Start_Date__c.addMonths(1);
        purOrderList.add(purOrder);
        
        Purchase_Order__c purOrder2 = new Purchase_Order__c();
        purOrder2.Company_Name__c = acc.id;
        purOrder2.PO_Start_Date__c = System.today();
        purOrder2.Po_End_Date__c = purOrder.PO_Start_Date__c.addMonths(1);
        purOrderList.add(purOrder2);
        insert purOrderList;
        
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
        coa.Fiscal_Year__c = fYear.id;
        coa.Operational_Budget__c = op.id;
        insert coa;
        
        List<PO_Line_Item__c> poList = new List<PO_Line_Item__c>();
        PO_Line_Item__c poLineItem = new PO_Line_Item__c();
        poLineItem.Budget_Line__c = 'Hardware Maintenance';
        poLineItem.Amount__c = 100;
        poLineItem.Purchase_Order__c = purOrder.id;
        poLineItem.product_Type__c = 'Equipment';
        poList.add(poLineItem);
        
        PO_Line_Item__c poLineItem2 = new PO_Line_Item__c();
        poLineItem2.Budget_Line__c = 'Hardware Maintenance';
        poLineItem2.Amount__c = 2000;
        poLineItem2.Purchase_Order__c = purOrder2.id;
        poLineItem2.product_Type__c = 'Equipment';
        poList.add(poLineItem2);
        insert poList;
    }

}