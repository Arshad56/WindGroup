@isTest
public class UpdateLeasePlanFromLOIChargesTest{
    static testMethod void Test(){
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
        
        Units__c un=new Units__c();
        un.Name='testUnit';
        un.Property__c=prop.Id;
        un.Level__c=lvl.Id;
        un.NLA_SQF__c=123;
        un.Charge_Method__c='Monthly Rate - CL';
        un.Start_Date__c=date.today();
        un.End_Date__c=date.today()+30;
        insert un;
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.name='testLOIUnit';
        lu.LOI_Agreement_No__c=l1.Id;
        lu.Unit__c = un.Id;
        lu.LOI_start_Date__c = un.start_Date__c;
        lu.LOI_End_Date__c = un.End_Date__c;
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
        
        Lease_Plan__c lp = new Lease_Plan__c();
        lp.Unit__c = un.Id;
        lp.Start_Date__c = un.Start_Date__c;
        lp.End_Date__c = Date.newInstance(un.Start_Date__c.year(),un.Start_Date__c.month(),Date.DaysInMonth(un.Start_Date__c.Year(),un.Start_Date__c.Month()));
        for(Date dts=un.Start_Date__c;dts<=lp.End_Date__c; dts = dts+1){
            lp.put('Daily_Rate_'+dts.Day()+'__c',dts.day());
            
            if(dts.Day() > 0 && dts.Day() < 7){
                lp.put('Status_'+dts.Day()+'__c','Committed');
            }else if(dts.Day() > 7 && dts.Day() < 15){
                lp.put('Status_'+dts.Day()+'__c','Vacant');
            }else if(dts.Day() > 17 && dts.Day() < 25){
                lp.put('Status_'+dts.Day()+'__c','LOI');
            }
        }
        insert lp;
        
        LOI_Charges__c lc = new LOI_Charges__c();
        lc.Active__c = true;
        lc.LOI_Unit__c = lu.Id;
        lc.Start_Date__c = lu.LOI_start_Date__c;
        lc.End_Date__c = lu.LOI_End_Date__c;
        lc.Charge__c = apc.Id;
        lc.Charge_Rate__c = 5;
        lc.Currency_Code__c = label.Default_Currency;
        lc.Type__c = 'Fixed';
        lc.Lease_Plan__c = lp.Id;
        insert lc;
}
}