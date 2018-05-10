/*
*    Name           :    invoiceReceiptTrigger
*    Author         :    Mohd Anas
*    Date           :    29th June 2017
*    Description    :    This trigger checks the following scenario
*                        1. Invoice ammount doesnt exceeds the good receipt
*                        2. Invoice ammount doesnt voilates the payment arrangement
*                        3. Update the checkbox ("Invoice Created") in Po Payment arrangement
*                        4. Invoice must be generated in sequence of payment arrangement (EDITTED ON : 14th July 2014)  
*                        5. Added Button Paid and Void for Invoice Receipt
*/

trigger InvoiceReceiptTrigger on Invoice_Receipt__c (before insert){
    InvoiceReceiptController.InvoiceReceiptValidation(Trigger.New);
}