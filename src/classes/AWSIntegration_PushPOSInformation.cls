public class AWSIntegration_PushPOSInformation 
{
   public class wrapperClass
   {
       public String SalesforceObjectName{get;set;}
       public String AwsObjectLabel{get;set;}
       public Map<String,String> fieldMap=new Map<String,String>();
   }
 
   @future(callout=true)
   public static void processPush(Boolean isTestRunning, Id posId)
   {
        Integration_AWS_Log__c logRec= new Integration_AWS_Log__c();
        String jsonstr='';
        String Push_EndPoint='http://13.228.56.148/jc/api/pushleaseposdata';
        List<AWS_Credentials__c> awsRecList = [Select Id,PUSH_POSInfo_StartDateTime__c, PUSH_POSInfo_Endpoint__c, PUSH_POSInfo_EndDateTime__c from AWS_Credentials__c where Name ='AWS'];
        AWS_Credentials__c awsRec = new AWS_Credentials__c();
        if(!awsRecList.isEmpty())
            awsRec = awsRecList.get(0);
       try
       {
        
        String AWSAccessToken = AWSIntegration_IntegrationHelper.getAccessToken(isTestRunning,'POS');
        jsonstr=AWSIntegration_PushPOSInformation.prepareJsonString(posId);
        if(jsonstr.length()>30000)
        {
        logRec.Json_String1__c=jsonstr.subString(0,30000);
        if(jsonstr.length()<60000)
        logRec.Json_String2__c=jsonstr.subString(30000,jsonstr.length());
        else
        logRec.Json_String2__c=jsonstr.subString(30000,60000);
        }
        else
        {
            logRec.Json_String1__c=jsonstr;
        }
        logRec.Integration_Call_Type__c='Push POS Information';
        system.debug('jsonstr:'+jsonstr);
        
        //Check whether the Request and Task End Point is it store inside SF Database 
        if(awsRec.PUSH_POSInfo_Endpoint__c !=null)
           Push_EndPoint= awsRec.PUSH_POSInfo_Endpoint__c;
        
        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer '+AWSAccessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setBody(jsonstr);
        req1.setMethod('POST');
        req1.setEndpoint(Push_EndPoint);
        req1.setTimeout(90000); // timeout in milliseconds - this is one minute
        
        HttpResponse res1 = null;
        
         if(isTestRunning==false)
          res1 = h2.send(req1);
          else
          {
            res1 = new HttpResponse();
            res1.setHeader('Content-Type', 'application/json');
            res1.setBody('{"request"[{"id":"src=ABCDefgh,style=1234,src=ABCD,style=></img>","name":"src=ABCDefgh,style=1234,src=ABCD,style=></img>"}]}');
            res1.setStatusCode(200);
          }
      
        logRec.Response_String__c=res1.getBody();
           
        logRec.Last_Synch_Datetime_Criteria__c=awsRec.PUSH_POSInfo_StartDateTime__c;
        if(res1.getBody().contains('Exception') || res1.getBody().contains('error') || res1.getBody().contains('failed'))
            logRec.Status__c='Exception';
        else
        {
            logRec.Status__c='Success';
            
            if(awsRec.PUSH_POSInfo_EndDateTime__c==null)
                awsRec.PUSH_POSInfo_StartDateTime__c=System.now();
            else
                awsRec.PUSH_POSInfo_StartDateTime__c=awsRec.PUSH_POSInfo_EndDateTime__c;
            update awsRec;
               
         }    
        
        logRec.Target_URL__c=Push_EndPoint;
        if(system.label.Create_Push_Log=='TRUE')
        insert logRec;
        system.debug(res1.getBody());
        if(AWSIntegration_TestClass_New.isTestRunning==true)
        insert logRec;
       }catch(Exception e)
       {
        String errorMessage=''+e.getMessage()+' at line number:'+e.getLineNumber();
        System.debug('Exception:'+errorMessage);
        logRec.Response_String__c=errorMessage;
        logRec.Target_URL__c=Push_EndPoint;
        logRec.Last_Synch_Datetime_Criteria__c=awsRec.PUSH_POSInfo_StartDateTime__c;
        logRec.Status__c='Exception';                
        
        if(system.label.Create_Push_Log=='TRUE')
        if(AWSIntegration_TestClass_New.isTestRunning==false)
        insert logRec;
       }
       if(logRec!=null && logRec.id!=null)
       {
          Attachment attachment = new Attachment();
          attachment.Body = Blob.valueOf(jsonstr);
          attachment.Name = String.valueOf('Push Jason String.txt');
          attachment.ParentId = logRec.id; 
          insert attachment;
       }
   }
    
   public static String prepareJsonString(Id posId)
   {
        List<wrapperClass> objectList = new List<wrapperClass>();
        Map<String,wrapperClass> objectMap = new Map<String,wrapperClass>();
        Map<String,String> ObjectSortFieldMap = new Map<String,String>();
        AWS_Credentials__c awsCreRec = [Select Id,PUSH_POSInfo_StartDateTime__c, PUSH_POSInfo_Endpoint__c, PUSH_POSInfo_EndDateTime__c from AWS_Credentials__c where Name ='AWS' Limit 1];
        String jsonstr='{';
        String objectName='';
        String PreviousObject='';
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        TimeZone tz = UserInfo.getTimeZone();
        for(AWS_PUSH_POSInfo_Mapping__c awsRec : [Select AWS_Object_Label__c,Object_Sort_Required__c,Salesforce_Sort_Field_API_Name__c,AWS_Field_Label__c,Salesforce_Field__c,Salesforce_Object_Name__c from AWS_PUSH_POSInfo_Mapping__c Order by AWS_Object_Label__c])
        {
            wrapperClass wrapRec = new wrapperClass(); 
            if(objectMap.get(awsRec.AWS_Object_Label__c)!=null)
                wrapRec = objectMap.get(awsRec.AWS_Object_Label__c);
         
            if(awsRec.Object_Sort_Required__c!=null && awsRec.Object_Sort_Required__c==True)
                ObjectSortFieldMap.put(awsRec.Salesforce_Object_Name__c,awsRec.Salesforce_Sort_Field_API_Name__c);
            wrapRec.SalesforceObjectName=awsRec.Salesforce_Object_Name__c ;
            wrapRec.AwsObjectLabel=awsRec.AWS_Object_Label__c;
            wrapRec.fieldMap.put(awsRec.AWS_Field_Label__c,awsRec.Salesforce_Field__c);
            objectMap.put(awsRec.AWS_Object_Label__c,wrapRec);
        }
        Integer counter=0;
        if(objectMap.size()>0)
        {
     
        for(wrapperClass objRec : objectMap.Values())
        {
            if(objRec.fieldMap!=null && objRec.fieldMap.keyset().size()>0)
            {
                jsonstr=jsonstr+'\"'+objRec.AwsObjectLabel+'\" :[';
                String query = 'Select ';
                for(Integer i=0;i<objRec.fieldMap.Values().size();i++)
                {
                    if(i!=(objRec.fieldMap.Values().size()-1))
                        query =query+objRec.fieldMap.Values()[i]+',';
                    else
                        query =query+objRec.fieldMap.Values()[i]+'';
                }
                
                query =query+' from '+objRec.SalesforceObjectName+' ' + 'where Id=:posId';
                
                if(ObjectSortFieldMap.get(objRec.SalesforceObjectName)!=null)
                query =query+' Order by '+ObjectSortFieldMap.get(objRec.SalesforceObjectName)+' ASC';
                system.debug('query:'+query);
                Integer j=0;
                Integer querySize =Database.query(query).size();
                
                Schema.sObjectType sObjType = globalDescription.get(objRec.SalesforceObjectName); 
                Schema.DescribeSObjectResult objRes = sObjType.getDescribe(); 
                Map<String , Schema.SObjectField> mapFieldList = objRes.fields.getMap();
                           
                for(Sobject sobjRec : Database.query(query))
                {
                    jsonstr=jsonstr+'{';
                    Integer i=0;
                    for(String awsField : objRec.fieldMap.keyset())
                    {
                        try{
                        String fieldValue =String.valueof(sobjRec.get(objRec.fieldMap.get(awsField)));
                        
                        if(fieldValue!=null)
                        {
                            if(fieldValue.contains('base64,') && fieldValue.contains('></im'))
                                fieldValue=fieldValue.substring(fieldValue.indexof('base64,')+7,fieldValue.indexof('></im')-1);
                            else if(fieldValue.equals('Active'))
                                fieldValue = 'A';
                            else if(fieldValue.equals('Inactive')) 
                                fieldValue = 'I';
                           /* else if(fieldValue.contains('src=') && fieldValue.contains('=='))
                            {
                                try{
                                fieldValue=fieldValue.substring(fieldValue.indexof('src=')+5,fieldValue.indexof('==')+2);
                                if(fieldValue.contains('base64,'))
                                    fieldValue=fieldValue.substring(fieldValue.indexof('base64,')+7,fieldValue.length());                                
                                }catch(Exception e){}
                            }
                            else if(fieldValue.contains('src=') && fieldValue.contains('style='))
                            {
                                try{
                                fieldValue=fieldValue.substring(fieldValue.indexof('src=')+5,fieldValue.indexof('style=')-2);
                                if(fieldValue.contains('&amp;'))
                                fieldValue=fieldValue.replaceall('&amp;','&');
                                HttpRequest req = new HttpRequest();
                                req.setEndpoint(fieldValue);
                                req.setMethod('GET');
                                req.setTimeout(90000); // timeout in milliseconds - this is one minute
                                Http binding = new Http();
                                HttpResponse res = binding.send(req);
                                Blob image = res.getBodyAsBlob();
                                fieldValue=EncodingUtil.base64Encode(image);
                                }catch(Exception e){}
                            }
                            if(fieldValue.contains('src=') && fieldValue.contains('></img>'))
                            {
                                try{
                                fieldValue=fieldValue.substring(fieldValue.indexof('src=')+5,fieldValue.indexof('></img>')-1);
                                 if(fieldValue.contains('&amp;'))
                                fieldValue=fieldValue.replaceall('&amp;','&');
                                HttpRequest req = new HttpRequest();
                                req.setEndpoint(fieldValue);
                                req.setMethod('GET');
                                req.setTimeout(90000); // timeout in milliseconds - this is one minute
                                Http binding = new Http();
                                HttpResponse res = binding.send(req);
                                Blob image = res.getBodyAsBlob();
                                fieldValue=EncodingUtil.base64Encode(image);
                                }catch(Exception e){}
                            }*/
                            //replacing all HTML tags
                            fieldValue = fieldValue.replaceAll('\\<.*?\\>', '');
                        }
                            
                        if(fieldValue!=null && (fieldValue.contains('\n') ||fieldValue.contains('\r') || fieldValue.contains('"')))
                            fieldValue = fieldValue.escapeJava(); 
                        else if(fieldValue!=null && fieldValue.contains('\\'))
                            fieldValue=fieldValue.replaceall('\\','\\'+'\\');
                            
                        if(fieldValue==null || fieldValue=='null')
                        {
                            
                            if(i<(objRec.fieldMap.keyset().size()-1))
                            jsonstr=jsonstr+'\"'+awsField+'\" : '+fieldValue+',';
                            else
                            jsonstr=jsonstr+'\"'+awsField+'\" : '+fieldValue+'';
                        }
                        else
                        {
                            if(fieldValue!=null)
                            {
                            fieldValue=String.Valueof(fieldValue);
                            }
                            // check if field Type is Data type
                            Schema.DisplayType fielddataType = mapFieldList.get(objRec.fieldMap.get(awsField)).getDescribe().getType();
                             system.debug(awsField+'<--3-->'+fielddataType);
                             if(fielddataType == Schema.DisplayType.DateTime)
                             {
                                 system.debug('1-->'+fieldValue);
                                 if(fieldValue!=null)
                                 {
                                   String dt=fieldValue;
                                   Datetime dtime =Datetime.newinstance(Integer.valueof(dt.substring(0,4)),Integer.valueof(dt.substring(5,7)),Integer.valueof(dt.substring(8,10)),Integer.valueof(dt.substring(11,13)),Integer.valueof(dt.substring(14,16)),Integer.valueof(dt.substring(17,19)));
                                   dtime=dtime.AddSeconds(tz.getOffset(dtime)/1000);
                                   dtime=dtime.AddSeconds(tz.getOffset(dtime)/1000);
                                   fieldValue=''+dtime;
                                 }
                                 system.debug('2-->'+fieldValue);    
                             }
                            if(i<(objRec.fieldMap.keyset().size()-1))
                            {
                                jsonstr=jsonstr+'\"'+awsField+'\" : \"'+fieldValue+'\",';
                            }    
                            else
                            {
                                jsonstr=jsonstr+'\"'+awsField+'\" : \"'+fieldValue+'\"';
                            }
                        }
                        i++;
                        }catch(Exception e){
                        i++;
                        system.debug('Exception :'+e);
                        System.debug('Exception e:'+e.getLineNumber());
                        }
                    }
                  if(j!=(querySize-1)) 
                    jsonstr=jsonstr+'},';
                  else
                   jsonstr=jsonstr+'}';  
                  j++;  
                }
                 if(counter!=(ObjectMap.size()-1))
                 jsonstr=jsonstr+'],';
                 else
                 jsonstr=jsonstr+']';
                 counter++;
            }
          }  
           
        }
            
        jsonstr=jsonstr+'}';
        
        return jsonstr;
   }
}