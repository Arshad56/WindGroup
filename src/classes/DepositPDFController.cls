public class DepositPDFController{
    public Deposit__c deposit{get;set;}
    public String units{get;set;}
    public string concatIncAddFields{get;set;}
    public List<Deposit__c> deposits{get;set;}
    public Date generatedDate{get;set;}
    public Decimal grandTotal{get;set;}
    public String defaultCurrency{get;set;} 
    public List<Bank_Information__c> bankInfoList{get;set;}
    map<String,Bank_Information__c> bankInfoMap{get;set;}
    public String billingCity{get;set;}
    public String billingState{get;set;}
    public String billingCountry{get;set;}
    public String billingStreet{get;set;} 
    public DepositPDFController(){
        defaultCurrency = label.Default_Currency;
        grandTotal = 0;
        generatedDate = system.today();
        deposit = new Deposit__c();
        units = '';
        concatIncAddFields = '';
        string depositId = Apexpages.currentPage().getParameters().get('depositId');
        
        List<Bank_Information__c> tempBankInfoList = [select Id, Account_No__c,Bank_Address__c,Bank_Name__c,Beneficiary_Name__c,Branch_Name__c,Currency_Code__c,Property__c,Swift_Code__c from Bank_Information__c];
        bankInfoMap = new  map<String,Bank_Information__c> ();
        bankInfoList = new List<Bank_Information__c>();
        for(Bank_Information__c bi:tempBankInfoList){
          bankInfoMap.put(bi.Currency_Code__c+bi.Property__c,bi);
        }
            
         //System.debug('deppIds-->'+deppIds);
        if(depositId != null){
            deposits = [Select Exchange_Rate__c, Currency_Code__c, Number_of_Months__c, Deposit_Rate__c, id, Tenant__c, Name, 
            Deposit_Amount__c, Deposit_Date__c, Deposit_Formula_Type__c, Deposit_Type__c, Payment_Due_Date__c, Description__c, 
            Lease__r.Tenant__r.Customer_Code__c, Lease__r.Property__r.Beneficiary_Name__c, Lease__r.Property__r.Branch_Code__c, 
            Lease__r.Property__r.Bank_Account_Number__c, Lease__r.Property__r.Branch_Name__c, Lease__r.Property__r.Bank_Name__c, 
            Lease__r.Property__r.Bank_Address__c , Lease__r.Property__r.Remarks_Other_Invoices__c, Lease_Charge__r.Charge_Type__c, 
            Lease_Unit__r.Unit__r.Name, Lease_Unit__r.Area_Sq_Ft__c, Lease__c, Lease_Charge__c, Lease_Unit__c, Lease__r.Name, 
            Lease__r.Tenant__r.Phone, Lease__r.Tenant__r.BillingStreet, Lease__r.Tenant__r.BillingCity, 
            Lease__r.Tenant__r.BillingCountry, Lease__r.Tenant__r.BillingState, Lease__r.Tenant__r.BillingPostalCode, 
            Lease__r.Property__c, Lease__r.Property__r.Name, Lease__r.Property__r.Logo__c, Lease__r.Property__r.Address__c, 
            Lease__r.Property__r.Account_No_Local__c, Lease__r.Property__r.Bank_Address_Local__c, 
            Lease__r.Property__r.Bank_Name_Local__c, Lease__r.Property__r.Beneficiary_Name_Local__c,Lease__r.Tenant__r.Name, 
            Lease__r.Property__r.Swift_Code_Local__c, Lease__r.LOI_Signed_off_Date__c, Lease__r.Property__r.Branch_Name_Local__c, 
             
            LOI__r.Tenant__r.Customer_Code__c, LOI__r.Property__r.Beneficiary_Name__c, LOI__r.Property__r.Branch_Code__c, 
            LOI__r.Property__r.Bank_Account_Number__c, LOI__r.Property__r.Branch_Name__c, LOI__r.Property__r.Bank_Name__c, 
            LOI__r.Property__r.Bank_Address__c , LOI__r.Property__r.Remarks_Other_Invoices__c, LOI__r.Tenant__r.Name, 
            LOI_Unit__r.Unit__r.Name, LOI_Unit__r.Area_Sq_Ft__c, LOI__c, LOI_Unit__c, LOI__r.Name, LOI__r.Tenant__r.Phone, 
            LOI__r.Tenant__r.BillingStreet, LOI__r.Tenant__r.BillingCity, LOI__r.Tenant__r.BillingCountry, 
            LOI__r.Tenant__r.BillingState, LOI__r.Tenant__r.BillingPostalCode, LOI__r.Property__c, 
            LOI__r.Property__r.Name, LOI__r.Property__r.Logo__c, LOI__r.Property__r.Address__c,
            LOI__r.Property__r.Account_No_Local__c, LOI__r.Property__r.Bank_Address_Local__c, LOI__r.Property__r.Bank_Name_Local__c, 
            LOI__r.Property__r.Beneficiary_Name_Local__c, LOI__r.Property__r.Swift_Code_Local__c, LOI__r.LOI_Signed_off_Date__c, 
            LOI__r.Property__r.Branch_Name_Local__c
            
            from Deposit__c where id=:depositId];
        }
        for(Deposit__c dp:deposits){
            if(dp.Deposit_Amount__c == null){
                dp.Deposit_Amount__c = 0;
            }
            grandTotal += dp.Deposit_Amount__c;
        }
        
        if(deposits.size()>0){
        	String property;
            System.debug('deposits[0]-->'+deposits[0]);
            deposit = deposits[0];
            if(deposit.Currency_Code__c == null || deposit.Currency_Code__c == ''){
            	deposit.Currency_Code__c = label.Default_Currency;
            }
            
            property = (deposit.Lease__c != null)?deposit.Lease__r.Property__c:deposit.LOI__r.Property__c;
            
            if(deposit.Currency_Code__c != label.Default_Currency){
                if(bankInfoMap.containsKey(deposit.Currency_Code__c+property)){
                    bankInfoList.add(bankInfoMap.get(deposit.Currency_Code__c+property));
                }
            }
            if(bankInfoMap.containsKey(label.Default_Currency+property)){
                bankInfoList.add(bankInfoMap.get(label.Default_Currency+property));
            }
            
             billingCity = (deposit.Lease__r.Tenant__r.BillingCity!=null)?deposit.Lease__r.Tenant__r.BillingCity+',':((deposit.LOI__r.Tenant__r.BillingCity!=null)?deposit.LOI__r.Tenant__r.BillingCity+',':'');
             billingState = (deposit.Lease__r.Tenant__r.BillingState!=null)?deposit.Lease__r.Tenant__r.BillingState+',':((deposit.LOI__r.Tenant__r.BillingState!=null)?deposit.LOI__r.Tenant__r.BillingState+',':'');
             billingCountry = (deposit.Lease__r.Tenant__r.BillingCountry!=null)?deposit.Lease__r.Tenant__r.BillingCountry+',':((deposit.LOI__r.Tenant__r.BillingCountry!=null)?deposit.LOI__r.Tenant__r.BillingCountry+',':'');
            billingStreet = (deposit.Lease__r.Tenant__r.BillingStreet!=null)?deposit.Lease__r.Tenant__r.BillingStreet+',':((deposit.LOI__r.Tenant__r.BillingStreet!=null)?deposit.LOI__r.Tenant__r.BillingStreet+',':'');
            concatIncAddFields = billingCity + billingState + billingCountry;
            if(concatIncAddFields!=null && concatIncAddFields.endsWith(',')){
                concatIncAddFields = concatIncAddFields.subString(0,concatIncAddFields.length()-1);
            }
            
            if(deposit.Lease_Unit__c != null){
            	units = deposit.Lease_Unit__r.Unit__r.Name;
            }else if(deposit.LOI_Unit__c != null){
            	units = deposit.LOI_Unit__r.Unit__r.Name;
            }
           /* List<Lease_Unit__c> leaseUnitList = [Select id,Unit__r.Name from Lease_Unit__c where Id=:deposit.Lease_Unit__c];
            if(leaseUnitList.size()>0){
                for(Lease_Unit__c lu:leaseUnitList){ 
                    units += lu.Unit__r.Name ;
                }
                if(units!=null && units.endsWith(', ')){
                    units = units.substring(0,units.Length()-2);
                }
            }*/
            
            /*List<Lease_Unit__c> leaseUnitList = [Select id,Unit__r.Name from Lease_Unit__c where Id=:deposit.Lease_Unit__c];
            if(leaseUnitList.size()>0){
                for(Lease_Unit__c lu:leaseUnitList){ 
                    units += lu.Unit__r.Name ;
                }
                if(units!=null && units.endsWith(', ')){
                    units = units.substring(0,units.Length()-2);
                }
            }*/
        }
    }
}