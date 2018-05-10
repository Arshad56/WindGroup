public Class PicklistValue
{
    public set<String> getPickValues(Sobject objName, String fieldName, String firstVal) 
    {
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      Set<String> setPicklistValue = new Set<String>();
      
      if (firstVal != null) { //if there is a first value being provided
         options.add(new selectOption(firstVal, firstVal)); //add the first option
      }
      
      Schema.sObjectType sobject_type = objName.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      
      List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                  
            //options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            setPicklistValue.add(a.getValue());
      }
      
      return setPicklistValue; //return the List
    }
}