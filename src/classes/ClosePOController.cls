public class ClosePOController{
    public string poId{get;set;}
    public ClosePOController(){
        poId = Apexpages.CurrentPage().getParameters().get('Id');
    }
    public void yes(){
        if(poId!=null && poId.trim().length()>0){
            Purchase_Order__c po = [Select id,PO_Amount__c,Total_Receipt_Amount__c from Purchase_Order__c where id=:poId limit 1];
            po.Status__c = 'Closed';
            update po;
            
            Decimal balanceAmount = po.PO_Amount__c - po.Total_Receipt_Amount__c;
            if(balanceAmount>0){
                List<PO_Line_Item__c> poLinItmList = [Select id,COA_FY_Balance__c,COA_FY_Balance__r.PO_Closed_Amount__c from PO_Line_Item__c where Purchase_Order__c=:po.Id and COA_FY_Balance__c!=null limit 1];
                if(poLinItmList.size()>0 && poLinItmList[0].COA_FY_Balance__c!=null){
                    COA_FY_Balance__c cfb = new COA_FY_Balance__c();
                    cfb.Id = poLinItmList[0].COA_FY_Balance__c;
                    cfb.PO_Closed_Amount__c = (poLinItmList[0].COA_FY_Balance__r.PO_Closed_Amount__c!=null?poLinItmList[0].COA_FY_Balance__r.PO_Closed_Amount__c:0)+balanceAmount;
                    update cfb;
                }
            }
        }
    }
}