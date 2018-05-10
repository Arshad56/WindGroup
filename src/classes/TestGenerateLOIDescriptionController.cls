/*
*    Name           :    TestGenerateLOIDescriptionController
*    Author         :    Prabhakar Joshi
*    Date           :    12/5/2017
*    Description    :    Unit test class for GenerateLOIDescriptionController
*/
@isTest
public class TestGenerateLOIDescriptionController {
    @isTest 
    static void myTest(){
        
        Account tenant=new Account();
        tenant.name='test';
        insert tenant;
        
        
        
        
        Property__c prop=new Property__c();
        prop.Name='testprop';
        prop.Short_Code__c='abc';
        insert prop;
        
        Level__c le=new Level__c();
        le.name='test level';
        le.Property__c=prop.id;
        insert le;
        
       Units__c unt=new Units__c();
        unt.name='Test Unit';
        unt.Space_Type__c='Shop'; 
        unt.Property__c=prop.id;
        unt.Level__c=le.id;
        unt.NLA_SQF__c=234.32;
        unt.rent_hurdle__c = 100;
        unt.Rent_Hurdle_Lower_Limit__c = 10;
        unt.Rent_Hurdle_Upper_Limit__c = 20;
        unt.Charge_Method__c='Monthly Rate - CL';
        insert unt;
        
        list<loi__c> loiList = new List<Loi__c>();
        LOI__c loi=new LOI__c();
        loi.Name='testloi';
        loi.Property__c=prop.Id;
        loi.LOI_Status__c='Draft';
        loiList.add(loi);
        insert loiList;
        
        date sdate=system.today();
        
        ApexPages.currentPage().getParameters().put('propid',prop.id);
        ApexPages.currentPage().getParameters().put('tenantId',tenant.id);
        ApexPages.currentPage().getParameters().put('unitId',unt.id);
        ApexPages.currentPage().getParameters().put('loiId', loi.id);
        ApexPages.currentPage().getParameters().put('sDate', '21-6-2017');
        GenerateLOIDescriptionController obj=new GenerateLOIDescriptionController();
        
      
        obj.loi.LOI_Status__c='new';
        obj.selectedLeasePlan='Add LOI Unit';
        obj.listType='abc';
        obj.loi.LOI_Start_Date__c=date.today();
        obj.loi.Original_End_Date__c=date.today()+365;
        obj.indexVal=2;
        obj.searchlist=null;
        obj.selectedloi=loiList;
       
        obj.doSearch();
        obj.reload();
        obj.ContinueGenerateLOI();
        
        ApexPages.currentPage().getParameters().put('opr','New');
        GenerateLOIDescriptionController obj2=new GenerateLOIDescriptionController();
        
        obj2.selectedLeasePlan = 'New';
        obj2.ContinueGenerateLOI();
        //obj.getSetting();
        //obj.getActionSelectList();
        
    }
    
    @isTest
    static void myTest2(){
        LOI__c loi=new LOI__c();
        loi.Name='testloi';
        insert loi;
        
        ApexPages.currentPage().getParameters().put('loiId', loi.id);
        GenerateLOIDescriptionController obj2=new GenerateLOIDescriptionController();
        
        obj2.selectedLeasePlan='new';
        obj2.loi.Property__c=NULL;
        obj2.loi.LOI_Status__c='Draft';
        obj2.dataRow = '30';
        
        obj2.sortByLOI();
        obj2.sortByTenant();
        obj2.sortByProperties();
        obj2.sortByloiStartDate();
        obj2.sortByOgEndDate();
        obj2.getDataRowList();
        
        obj2.doPrevious();
        obj2.doNext();
        obj2.moveFirst();
        obj2.moveLast();
        
        
        obj2.reload();
        obj2.ContinueGenerateLOI();
        //obj2.getSetting();
        //obj2.getActionSelectList();
        }
}