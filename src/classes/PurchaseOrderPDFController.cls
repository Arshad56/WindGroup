/*
*    Name             :     PurchaseOrderPDFController
*    Author           :     Mohd Anas
*    Date             :     16th June 2017
*    Description      :     Controller to generate Purchase Order PDF 
*/
public class PurchaseOrderPDFController{
    public List<Purchase_Order__c> po{get;set;}
    public Double subTotal{get;set;}
    public List<Organization> org{get;set;}
    
    public PurchaseOrderPDFController(){
        subTotal=0;
        po=new List<Purchase_Order__c>();
        id poId=ApexPages.currentPage().getParameters().get('id');
        po=[select id,Vendor_Contact__r.name,Attention_To__c,Vendor_Contact__r.mailingCountry,Vendor_Contact__r.mailingStreet,Name,PO_Start_Date__c,PO_End_Date__c,
                Company_Name__r.Field1__c,Company_Name__r.name,Company_Name__c,Company_Name__r.billingStreet,Company_Name__r.billingCity,Company_Name__r.billingState,Company_Name__r.billingCountry,
                Vendor_Name__c,Vendor_Name__r.name,Vendor_Name__r.BillingStreet,Vendor_Name__r.BillingCity,Vendor_Name__r.BillingState,Vendor_Name__r.BillingCountry,
                Vendor_Contact__r.mailingCity,Vendor_Contact__r.mailingState,Vendor_Contact__r.phone,Delivery_Street__c,Delivery_City__c,
               Delivery_Country__c,Delivery_Phone__c,Delivery_Zip_Postal_Code__c,Total_PO_Amount__c,Currency_Code__c,Tax_Amount__c,
               (select Item_Name__c,description__c,quantity__c,amount__c,Total_Amount__c 
                from PO_Line_Items__r) 
            from Purchase_Order__c 
            where id=:poid];
            
        if(po.size()>0){
            for(PO_Line_Item__c st:po[0].PO_Line_Items__r){
                subTotal=subTotal+st.Total_Amount__c ;
            }
        }
        org=[select name from organization];
        }
    }