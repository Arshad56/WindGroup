/*
*    Name          :        LoiCloningControllerTest
*    Author        :       	Prabhakar Joshi   
*    Date          :        12th May 2017
*    Description   :        Unit test class for LoiCloningController
*/
@isTest 
public class LoiCloningControllerTest {
    @isTest 
    static void CloningController1(){
        
        
        Property__c prop=new Property__c();
        prop.Name='testprop';
        prop.Short_Code__c='acb';
        insert prop;
        
        LOI__c loi=new LOI__c();
        loi.Name='testLoi';
        insert loi;
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.Name='testLoiUnit';
        lu.LOI_Agreement_No__c=loi.Id;
        
        insert lu;
        
        LOI_Charges__c lc=new LOI_Charges__c();
        lc.Name='testLoiCharge';
        lc.LOI_Unit__c=lu.Id;
        lc.Type__c='Fixed';
        insert lc;
        
        Deposit__c dp=new Deposit__c();
        dp.Name='testDeposit';
        dp.LOI__c = loi.id;
        insert dp;
        
        
        Checklist_Master__c mas =new Checklist_Master__c();
        mas.Type__c='Takeover';
        insert mas;
        Checklist__c chck = new Checklist__c();
        chck.LOI_Unit__c=lu.id;
        chck.Checklist_Master__c=mas.id;
        insert chck;
        
        
        Checklist_Item__c clist = new Checklist_Item__c();
        clist.Checklist__c=chck.id;
        
        insert clist;
        
        
        ApexPages.currentPage().getParameters().put('loiId', loi.id);
        LoiCloningController obj=new LoiCloningController();
        obj.wrapUnit[0].isSelected=True;
        obj.originalLoi=loi;
        obj.originalLoi.property__c=prop.id;
        obj.newLoi=loi;
        obj.cloneLoi();
        
    }
}