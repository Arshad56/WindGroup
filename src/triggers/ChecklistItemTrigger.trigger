trigger ChecklistItemTrigger on Checklist_Item__c(before insert,before update,before delete,after insert,after update,after delete)
{
     if(Trigger.isInsert)
    {
        if(Trigger.isBefore)
        {
            try
            {
                ActionTypeAndDateTimeAssignmentHelper.ProcessActionTypeDateTime(Trigger.new);
            }
            catch(Exception e)
            {
                system.debug(e);
            }    
        }
        else if(Trigger.isAfter)
        {
        
        }
    }
    else if(Trigger.isUpdate)
    {
        if(Trigger.isBefore)
        {
            try
            {
                ActionTypeAndDateTimeAssignmentHelper.ProcessActionTypeDateTime(Trigger.new);
            }
            catch(Exception e)
            {
                system.debug(e);
            }
        }
        else if(Trigger.isAfter)
        {
        
        }
    }
    else if(Trigger.isDelete)
    {
        if(Trigger.isBefore)
        {
            
        }
        else if(Trigger.isAfter)
        {
                
        }
    }
}