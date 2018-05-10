/*
*    Name           :    Generate LOI Controller Test 
*    Author         :    Mohd Anas
*    Date           :    6 April 2017
*    Description    :    Unit Test Class for Generate LOI Controller.
*    Updated        :    21 April 2017
*/
@isTest
public class GenerateLOIControllerTest {
    @isTest
    static void methodGenerateLOIController1(){
        //-------------------------Data Insert Section----------------------------------------
      
        Account tenant=new Account();
        tenant.name='test';
        tenant.Trade_Category__c='Electricals / Electronics';
        tenant.sub_Trade_Category__c='Electricals / Electronics';
        //tenant.Trade_Category__c='Beauty, Wellness & Personal Care';
        //tenant.sub_Trade_Category__c='Beauty Salon & Spa';
        tenant.WItholding_Eligible__c = true;
        insert tenant;
        
        
        contact con=new contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
        con.Region__c='Asia';
        con.Country__c='China';
        con.lastName='testCont';
        insert con;
        
        property__c pr=new property__c();
        pr.name='test Property';
        pr.LOI_Unit_Index__c=2;
        pr.LOI_Index__c=2;
        pr.Deposit_Index__c=2;
        pr.short_code__c='ABC';
        pr.Witholding_Tax__c = 3;
        pr.Witholding_Tax_Limit__c = 10;
        insert pr;
        
        
        LOI__c loi=new LOI__c();
        loi.name='Test loi';
        loi.Tenant_Type__c='tenant';
        loi.LOI_Start_Date__c=Date.today();
        loi.Tenant__c=tenant.id;
        loi.Contact__c=con.Id;
        loi.Property__c=pr.Id;
        loi.LOI_Tenure_Days__c='2';
        loi.LOI_Tenure_Mths__c=24;
        loi.LOI_Validity_Week__c='One Week';
        insert loi;
        
        System.debug('LOI End Date'+loi.LOI_end_Date__c);
        
        LOI_Unit__c lu=new LOI_Unit__c();
        lu.LOI_Agreement_No__c=loi.Id;
        
        
        CheckList_Master__c chkMast= new CheckList_Master__c();
        chkMast.Property__c=pr.id;
        chkMast.Description__c='test Description';
        insert chkMast;
        
        CheckList_Master_Item__c chkMastItem = new CheckList_Master_Item__C();
        chkMastItem.Checklist_Master__c=chkMast.id;
        chkMastItem.Description__c='';
        chkMastItem.condition__c='';
        chkMastItem.SN__c='';
        chkMastItem.Number__c='1213';
        chkMastItem.Issue_Types__c='Leakage;Cracking';
        chkMastItem.Item_Type__c='Floor';
        insert chkMastItem;
        
        
        Checklist__c chkList=new Checklist__c();
        chkList.Checklist_Master__c=chkMast.Id;
        insert chkList;
        
        
        
        
        Level__c le=new Level__c();
        le.name='test level';
        le.Property__c=pr.id;
        insert le;
        
        Units__c unt=new Units__c();
        unt.name='Test Unit';
        unt.Space_Type__c='Shop'; 
        unt.Property__c=pr.id;
        unt.Level__c=le.id;
        unt.NLA_SQF__c=234.32;
        unt.rent_hurdle__c = 100;
        unt.Rent_Hurdle_Lower_Limit__c = 10;
        unt.Rent_Hurdle_Upper_Limit__c = 20;
        unt.Charge_Method__c='Monthly Rate - CL';
        unt.NLA_SQF__c=25.5;
        insert unt;
        
        Units__c unt2=new Units__c();
        unt2.name='Test Unit';
        unt2.Property__c=pr.id;
        unt2.Level__c=le.id;
        insert unt2;
        
        
         
        Conditions__c cd=new Conditions__c();
        cd.Condition__c='testConditin';
        cd.Description__c='testCondition Description';       
        cd.Unit__c=unt.Id;
        insert cd;
        
        Checklist_Item__c chkitem=new Checklist_Item__c();
        chkitem.CheckList_Master_Item__c= chkMastItem.id;
        chkitem.Condition__c = cd.id;
        chkitem.Handover_Condition__c =cd.Id;
        chkitem.Checklist__c=chkList.Id;
        insert chkitem;
        
        Checklist_Item__c chkitem1=new Checklist_Item__c();
        chkitem1.CheckList_Master_Item__c= chkMastItem.id;
        chkitem1.Condition__c = cd.id;
        chkitem1.Checklist__c=chkList.Id;
        insert chkitem1;
       
         
        List<Lease_Plan__c> LPList=new List<Lease_Plan__c>();
        Lease_Plan__c lp=new Lease_Plan__c();
        lp.start_date__c=system.today();
        lp.end_date__c=system.today().addDays(10);
        lp.Unit__c=unt.Id;
        lp.Monthly_Budget__c = 1000;
        LPList.add(lp) ;
        
        Lease_Plan__c lp2=new Lease_Plan__c();
        lp2.start_date__c=system.today();
        lp2.end_date__c=system.today().addDays(10);
        lp2.Unit__c=unt.Id;
        lp2.Monthly_Budget__c = 1000;
        LPList.add(lp2) ;
        insert LPList;
        
       
        
        Applicable_Charges__c ac=new Applicable_Charges__c();
        ac.Name='testCharge';
        ac.Property__c=pr.Id;
        ac.Charge_Type__c='Local';
        ac.Charge_Rate__c=213;
        ac.Currency_Code__c=label.Base_Foreign_Currency;
        ac.Charge_Method__c='Monthly Rate - CL';
        ac.Billing_Terms__c='Prorate';
        ac.Type__c='Fixed';
        ac.Billing_Frequency__c ='Monthly';
        ac.Billing_Days__c ='1';
        ac.Billing_Terms__c = 'Prorate';
        ac.Charge_Start_Day__c = '1';
        insert ac;
        
        Applicable_Charges__c acDisc=new Applicable_Charges__c();
        acDisc.Name='testCharge';
        acDisc.Property__c=pr.Id;
        acDisc.Charge_Type__c='Invoice Discount';
        acDisc.Charge_Rate__c=213;
        acDisc.Currency_Code__c=label.Base_Foreign_Currency;
        acDisc.Charge_Method__c='Monthly Rate - CL';
        acDisc.Billing_Terms__c='Prorate';
        acDisc.Type__c='Fixed';
        acDisc.Billing_Frequency__c ='Monthly';
        acDisc.Billing_Days__c ='1';
        acDisc.Billing_Terms__c = 'Prorate';
        acDisc.Charge_Start_Day__c = '1';
        insert acDisc;
        
        LOI_Unit_Template__c lut=new LOI_Unit_Template__c();
        lut.Charge_Method__c = 'Monthly Rate - CL';
        lut.Unit__c=unt.id;
        lut.Start_Date__c = loi.LOI_Start_Date__c;
        lut.End_Date__c = loi.LOI_Start_Date__c;
        lut.Space_Type__c='Shop';
        lut.active__c = TRUE;
        lut.Trade_Category__c=tenant.Trade_Category__c;
        lut.sub_Trade_Category__c=tenant.sub_Trade_Category__c; 
        insert lut;
        
        LOI_Unit_Template__c lut2=new LOI_Unit_Template__c();
        //lut2.Unit__c=unt2.id;
        lut2.Space_Type__c = 'Shop';
        lut2.Active__c = true;
        lut2.Start_Date__c = loi.LOI_Start_Date__c;
        lut2.End_Date__c = loi.LOI_Start_Date__c;
    lut2.Property_Lookup__c=loi.property__c;
        lut2.Trade_Category__c=tenant.Trade_Category__c;
        //lut2.sub_Trade_Category__c='Books & Stationery'; 
        insert lut2;
        
        List<LOI_Charge_Template__c> listLCT=new List<LOI_Charge_Template__c>();
        LOI_Charge_Template__c lct= new LOI_Charge_Template__c();
        lct.name='test charge template';
        lct.Charge_Type__c='Rent';
        lct.Charge_Rate__c=123;
        lct.Type__c='By Area';
        lct.Charge__c=ac.id;
        lct.Billing_Terms__c = 'Prorate';
        lct.LOI_Unit_Template__c=lut.id;
        lct.RecordTypeId=schema.SObjectType.LOI_Charge_Template__c.getRecordTypeInfosByName().get('Rent').getrecordTypeId();
        
        LOI_Charge_Template__c lct2= new LOI_Charge_Template__c();
        lct2.name='test charge template';
        lct2.Charge_Type__c='Rent';
        lct2.Charge_Rate__c=123;
        lct2.Type__c='By Area';
        lct2.LOI_Unit_Template__c=lut.id;
        lct2.Billing_Terms__c = 'Prorate';
        lct2.RecordTypeId=schema.SObjectType.LOI_Charge_Template__c.getRecordTypeInfosByName().get('Monthly').getrecordTypeId();
        listLCT.add(lct2);
        listLCT.add(lct);
        insert listLCT;
        
        Pricing_Factor__c pf = new Pricing_Factor__c();
        pf.Property_Name__c = pr.id; 
        pf.Start_Date__c = loi.LOI_Start_Date__c-10;
        pf.End_Date__c = loi.LOI_Start_Date__c+10;
        pf.Tenant_Type__c=loi.Tenant_Type__c;
        pf.Charge_Method__c='Monthly Rate - CL;Daily Rate';
        pf.Factor__c = .8;
        insert pf;
        
        /*LOI_Unit_Template__c loiunit=new LOI_Unit_Template__c();
        loiunit.Unit__c=unt.Id;
        insert loiunit;*/
        
        /*LOI_Charge_Template__c lctMon= new LOI_Charge_Template__c();
        lctMon.name='test charge template';
        lctMon.Charge_Type__c='Rent';
        lctMon.Charge_Rate__c=2839.89;
        lctMon.Type__c='By Area';
        
        lctMon.LOI_Unit_Template__c=loiunit.id;
        lctMon.RecordTypeId=schema.SObjectType.LOI_Charge_Template__c.getRecordTypeInfosByName().get('Monthly').getrecordTypeId();
        insert lctMon;*/
        
        /*List<LOI_Charge_Template__c> lctList=new List<LOI_Charge_Template__c>();
        lctList.add(lct);
        lctList.add(lctMon);
        insert lctList;*/
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accId',tenant.Id);
        ApexPages.currentPage().getParameters().put('conId',con.Id);
        ApexPages.currentPage().getParameters().put('propId',pr.Id);
        ApexPages.currentPage().getParameters().put('unitId',unt.Id);
        ApexPages.CurrentPage().getParameters().put('sDate',system.today().year()+'-'+system.today().Month()+'-'+system.today().Day());
        ApexPages.CurrentPage().getParameters().put('eDate',system.today().addDays(7).year()+'-'+system.today().addDays(7).Month()+'-'+system.today().addDays(7).Day());
        GenerateLOIController glc1=new GenerateLOIController();
        ApexPages.CurrentPage().getParameters().put('sDate',null);
        ApexPages.CurrentPage().getParameters().put('eDate',null);
        
       ApexPages.currentPage().getParameters().put('action', 'New');
        //
        //-------------------------------object of controller------------------------
        GenerateLOIController cntr1=new GenerateLOIController();
        cntr1.endDate=date.newInstance(2017, 12, 23);
        //cntr1.applyWitholding = true;
        //cntr1.priceFactor = .8;
        //cntr1.selectionError();
       // cntr1.getActionSelectList();
        cntr1.checkMandateFields();
        cntr1.loi=loi;
        cntr1.endDateSetup();
        cntr1.loiUnitTemp.Unit__c=unt2.Id;
        cntr1.unitDetailSetup();
        cntr1.calcPriceFactor();
        cntr1.showTenantType = true;
        cntr1.loi.LOI_Validity_Week__c = 'One Week';
        cntr1.next();
        
        cntr1.loiUnitTemp.Unit__c=unt.Id;
        cntr1.unitDetailSetup();
        cntr1.calcPriceFactor();
        cntr1.next();
        
        cntr1.indexVal = 0;
        cntr1.listType='Deposit';
        cntr1.addRow();
        
        cntr1.delRow();
        cntr1.listType='Rent';
        cntr1.addRow();
        cntr1.delRow();
        cntr1.populateLOIvalidity();
        
        
        /*
        for(LOI_Charge_Template__c loc:cntr1.rentUnitChrgTemp){
            loc.Charge_Rate__c = 10;
        }*/
        //cntr1.generateCharge();
       
        cntr1.generateLOIPage3();
        for(GenerateLOIController.DepositUnitWrap wrap: cntr1.depositUnitChrgTemp){
            wrap.dep.Deposit_Type__c='Security';
            wrap.dep.Deposit_Formula_Type__c='By Base Rent';
            wrap.dep.Currency_Code__c='USD';
        }
        cntr1.generateLOIPage3();
        
        cntr1.SaveLOI();
        
        ac.Charge_Method__c ='Daily Rate' ;
        update ac;
        unt.Charge_Method__c='Daily Rate';
        update unt;
        cntr1.loiUnitTemp.Unit__c=unt.Id;
        cntr1.unitDetailSetup();
        for(LOI_Charge_Template__c loc:cntr1.rentUnitChrgTemp){
            loc.Charge_Rate__c = 10;
        }
        cntr1.generateCharge(); 
        cntr1.Calculation(); 
        
        String testStr = cntr1.addZeroIndex(5);
        
        cntr1.next();
        
        
        unt.Charge_Method__c='Monthly Rate - L';
        update unt;
        cntr1.loiUnitTemp.Unit__c=unt.Id;
        cntr1.unitDetailSetup();
        
        
        for(LOI_Charge_Template__c loc:cntr1.rentUnitChrgTemp){
            loc.Charge_Rate__c = 10;
        }
        cntr1.generateCharge();
        cntr1.next();
        
        
        //cntr1.indexVal=1;
        
        
        ApexPages.currentPage().getParameters().put('action', 'Add LOI Unit ');
        ApexPages.currentPage().getParameters().put('loiId', loi.id);
        ApexPages.CurrentPage().getParameters().put('accId',tenant.Id);
        ApexPages.CurrentPage().getParameters().put('conId',con.Id);
        ApexPages.CurrentPage().getParameters().put('propId',pr.Id);
        ApexPages.currentPage().getParameters().put('unitId',unt.Id);
        GenerateLOIController cntr2=new GenerateLOIController();
        
       Test.stopTest();
    }
   
}