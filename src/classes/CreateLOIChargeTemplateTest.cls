@isTest public class CreateLOIChargeTemplateTest {
    @isTest static void myTest(){
        Account ac=new Account();
        ac.name='TestAc';
        insert ac;
        
        Property__c prop=new Property__c();
        prop.name='TestProp';
        prop.Short_Code__c='abc';
        insert prop;
        
        Level__c lvl=new Level__c();
        lvl.name='1';
        lvl.Property__c=prop.Id;
        insert lvl;
        
        LOI__c l1=new LOI__c();
        l1.name='TestLOI';
        insert l1;
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.name='testLOIUnit';
        lu.LOI_Agreement_No__c=l1.Id;
        insert lu;
        
       Applicable_Charges__c apc=new Applicable_Charges__c();
        apc.name='Test12';
        apc.Frequency__c='Monthly';
        apc.Billing_Frequency__c='Monthly';
        apc.Billing_Days__c='31';
        apc.Property__c=prop.id;
        apc.Charge_Type__c='Local';
        apc.Currency_Code__c=label.Base_Foreign_Currency;
        apc.Charge_Method__c='Monthly Rate - L';
        apc.Billing_Terms__c='Prorate';
        apc.Type__c='Fixed';
        insert apc; 
        
        Units__c un=new Units__c();
        un.Name='testUnit';
        un.Property__c=prop.Id;
        un.Level__c=lvl.Id;
        un.NLA_SQF__c=123;
        un.Charge_Method__c='Monthly Rate - L';
        un.Start_Date__c=date.today();
        un.End_Date__c=date.today()+30;
        insert un;
        
        LOI_Unit_Template__c lt=new LOI_Unit_Template__c();
        lt.Property_Lookup__c=prop.id;
        lt.Start_Date__c=date.today();
        lt.End_Date__c=date.today()+30;
        lt.Charge_Method__c = 'Monthly Rate - L';
        insert lt;
    }
    
    @isTest static void myTest2(){
        Account ac=new Account();
        ac.name='TestAc';
        insert ac;
        
        Property__c prop=new Property__c();
        prop.name='TestProp';
        prop.Short_Code__c='abc';
        insert prop;
        
        Level__c lvl=new Level__c();
        lvl.name='1';
        lvl.Property__c=prop.Id;
        insert lvl;
        
        LOI__c l1=new LOI__c();
        l1.name='TestLOI';
        insert l1;
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.name='testLOIUnit';
        lu.LOI_Agreement_No__c=l1.Id;
        insert lu;
        
       Applicable_Charges__c apc=new Applicable_Charges__c();
        apc.name='Test12';
        apc.Frequency__c='Monthly';
        apc.Billing_Frequency__c='Monthly';
        apc.Billing_Days__c='31';
        apc.Property__c=prop.id;
        apc.Charge_Type__c='Local';
        apc.Currency_Code__c=label.Base_Foreign_Currency;
        apc.Charge_Method__c='Monthly Rate - CL';
        apc.Billing_Terms__c='Prorate';
        apc.Type__c='Fixed';
        insert apc; 
        
        Units__c un=new Units__c();
        un.Name='testUnit';
        un.Property__c=prop.Id;
        un.Level__c=lvl.Id;
        un.NLA_SQF__c=123;
        un.Charge_Method__c='Monthly Rate - CL';
        un.Start_Date__c=date.today();
        un.End_Date__c=date.today()+30;
        insert un;
        
        LOI_Unit_Template__c lt=new LOI_Unit_Template__c();
        lt.Property_Lookup__c=prop.id;
        lt.Charge_Method__c = 'Monthly Rate - CL';
        insert lt;
    }
    
}