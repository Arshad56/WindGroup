public class NewLeasePOSRedirectController{
    public Lease_Unit__c leaseUnit{get;set;}
    public string stDate{get;set;}
    public string endDate{get;set;}
    public NewLeasePOSRedirectController(Apexpages.StandardCOntroller std){
        leaseUnit = new Lease_Unit__c();
        Lease_POS__c lp = (Lease_POS__c)std.getRecord();
        List<Lease_Unit__c> leaseUnits = [Select id,Lease_Start_Date__c,Lease_End_Date__c from Lease_Unit__c where id=:lp.Lease_Unit__c limit 1];
        if(leaseUnits.size()>0){
            leaseUnit = leaseUnits[0];
            stDate = leaseUnit.Lease_Start_Date__c.format();
            endDate = leaseUnit.Lease_end_Date__c.format(); 
        }
    }
}