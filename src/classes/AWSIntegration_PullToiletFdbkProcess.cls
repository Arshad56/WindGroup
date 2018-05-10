/*
Description  : This class is created to prepare the Pull Toilet Feedback request by callout to AWS system and update the information based on Dates
Date created : 22nd Feb 2017 
Loon: Currently using it.
*/
public class AWSIntegration_PullToiletFdbkProcess implements Schedulable 
{
    public void execute(SchedulableContext SC) 
    {
        processPull(AWSIntegration_TestClass_New.isTestRunning);
    }
    @future(callout=true)
    public static void processPull(Boolean isTestRunning)
    {
        Utility.lastUpdatedFromAwsIntegration = 'iOPS';
        Integration_AWS_Log__c logRec= new Integration_AWS_Log__c();
        String responseString='';
        try{
            String AWSAccessToken = AWSIntegration_IntegrationHelper.getAccessToken(isTestRunning,'');
            Http h2 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setHeader('Authorization','Bearer '+AWSAccessToken);
            req1.setHeader('Content-Type','application/json');
            // req1.setBody(jsonstr);
            req1.setMethod('GET');
            req1.setTimeout(90000); // timeout in milliseconds - this is one minute
            String fromDate='',toDate='';
            String PullEndPoint='http://13.228.56.148/api/PullAWSChecklistStatus';
            for(AWS_Credentials__c awsRec : AWS_Credentials__c.getAll().Values())
            {
                if(awsRec.PULL_Toilet_Feedback_Start_Datetime__c!=null)
                {
                    String Month='',day='';
                    if(awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Month()>9)
                        Month=awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Month()+'';
                    else
                        Month='0'+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Month();
                    
                    if(awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Day()>9)
                        day=awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Day()+'';
                    else
                        day='0'+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Day();
                    fromDate=''+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Year()+'-'+Month+'-'+day+'%20'+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Hour()+':'+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.Minute()+':'+awsRec.PULL_Toilet_Feedback_Start_Datetime__c.second();  
                } 
                else
                {
                    String Month='',day='';
                    if(System.now().Month()>9)
                        Month=System.now().Month()+'';
                    else
                        Month='0'+System.now().Month();
                    
                    if(System.now().Day()>9)
                        day=System.now().Day()+'';
                    else
                        day='0'+System.now().Day();
                    fromDate=''+System.now().Year()+'-'+Month+'-'+day+'%20'+(system.now().addMinutes(-30)).Hour()+':'+(system.now().addMinutes(-30)).Minute()+':00';
                }  
                
                DateTime dt =System.now();
                if(awsRec.PULL_Toilet_Feedback_End_Datetime__c!=null)
                    dt=awsRec.PULL_Toilet_Feedback_End_Datetime__c;
                if(dt>System.now())
                    dt=System.now();
                if(dt!=null)
                {
                    String Month='',day='';
                    if(dt.Month()>9)
                        Month=dt.Month()+'';
                    else
                        Month='0'+dt.Month();
                    
                    if(dt.Day()>9)
                        day=dt.Day()+'';
                    else
                        day='0'+dt.Day();
                    toDate=''+dt.Year()+'-'+Month+'-'+day+'%20'+dt.Hour()+':'+dt.Minute()+':'+dt.second();  
                }
                
                if(awsRec.PULL_Toilet_Feedback_EndPoint__c!=null)
                    PullEndPoint=awsRec.PULL_Toilet_Feedback_EndPoint__c;
            }
            
            req1.setEndpoint(PullEndPoint+'/'+fromDate+'/'+toDate);
            req1.setTimeout(90000); // timeout in milliseconds - this is one minute
            
            HttpResponse res1 =null;
            if(isTestRunning==false)
                res1 = h2.send(req1);
            else
            {
                String fbId=[Select Id from Feedback__c LIMIT 1].Id;
                res1 = new HttpResponse();
                res1.setHeader('Content-Type', 'application/json');
                res1.setBody('{"feedback" :[{"aws_id" : "000001","resolved_datetime" : "2017-07-13 09:26:59"}, {"id" : "'+fbId+'"}]}');
                res1.setStatusCode(200);
            }
            
            logRec.Target_URL__c=PullEndPoint+'/'+fromDate+'/'+toDate;
            logRec.Integration_Call_Type__c='Pull Toilet Feedback';
            if(res1.getBody().length()>100000)
                logRec.Response_String__c=res1.getBody().subString(0,100000);
            else
                logRec.Response_String__c=res1.getBody();
            for(AWS_Credentials__c awsRec : [Select Id,PULL_Toilet_Feedback_Start_Datetime__c,PULL_Toilet_Feedback_End_Datetime__c,Push_EndPoint__c from AWS_Credentials__c where Name = 'AWS' LIMIT 1])
            {
                logRec.Last_Synch_Datetime_Criteria__c=awsRec.PULL_Toilet_Feedback_Start_Datetime__c;
                if(res1.getBody().contains('Exception'))
                    logRec.Status__c='Exception';
                else
                {
                    logRec.Status__c='Success';
                }    
            }
            responseString=res1.getBody();
            JSONParser jsonParser= JSON.createParser(res1.getBody());
            
            System.JSONToken token;
            string text;
            Map<String,String> objectNameMap = new Map<String,String>();
            Map<String,String> fieldNameMap = new Map<String,String>();
            for(PULL_Toilet_Feedback__c objMapRec : PULL_Toilet_Feedback__c.getAll().values())
            {
                if(objMapRec.AWS_Object_Label__c!=null)
                {
                    objectNameMap.put(objMapRec.AWS_Object_Label__c,objMapRec.Salesforce_Object_Name__c);
                    fieldNameMap.put(objMapRec.Salesforce_Object_Name__c+'-'+objMapRec.AWS_Field_Label__c,objMapRec.Salesforce_Field__c);
                }
            }
            List<Sobject> sobjectList = new List<Sobject>();
            List<Sobject> sobjectInsertList = new List<Sobject>();
            String fieldName='';
            String fieldAPIName='';
            TimeZone tz = UserInfo.getTimeZone();
            try{
                while((token = jsonParser.nextToken()) != null)
                {
                    if(jsonParser.getCurrentToken() == JSONToken.START_OBJECT)
                    {
                        system.debug('1 --> jsonParser.getCurrentToken():'+jsonParser.getCurrentToken());
                        system.debug('1 --> jsonParser.getText():'+jsonParser.getText());
                        
                        while(jsonParser.nextToken() != JSONToken.END_OBJECT)
                        {
                            if(jsonParser.getCurrentToken() == JSONToken.START_ARRAY )
                            {
                                system.debug('1 --> jsonParser.getCurrentName():'+jsonParser.getCurrentName());
                                String SobjApiName=jsonParser.getCurrentName();
                                if(SobjApiName!='' && SobjApiName!=null && objectNameMap.get(SobjApiName)!=null)
                                {
                                    SobjApiName=objectNameMap.get(SobjApiName);
                                    Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe(); 
                                    Schema.sObjectType sObjType = globalDescription.get(SobjApiName); 
                                    Schema.DescribeSObjectResult res = sObjType.getDescribe(); 
                                    Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap(); 
                                    
                                    while(jsonParser.nextToken() != JSONToken.END_ARRAY)
                                    {
                                        
                                        if(jsonParser.getCurrentToken() == JSONToken.START_OBJECT)
                                        {
                                            Sobject objRec = Schema.getGlobalDescribe().get(SobjApiName).newSObject();
                                            while(jsonParser.nextToken() != JSONToken.END_OBJECT)
                                            {
                                                if(jsonParser.getCurrentToken()==JSONToken.FIELD_NAME)
                                                {
                                                    
                                                    fieldName=SobjApiName+'-'+jsonParser.getText();
                                                    if(jsonParser.nextToken()==JSONToken.VALUE_STRING)
                                                    {
                                                        if(fieldNameMap.get(fieldName)!=null)
                                                        {
                                                            fieldAPIName=fieldNameMap.get(fieldName);
                                                            fieldAPIName=fieldAPIName.toLowerCase();
                                                            Schema.DisplayType fielddataType = mapFieldList.get(fieldAPIName).getDescribe().getType();
                                                            if(mapFieldList.get(fieldAPIName).getDescribe().isUpdateable() || fieldAPIName=='id' || (fielddataType == Schema.DisplayType.Reference && fieldAPIName=='checklist_item__c')) 
                                                            {
                                                                if(fieldAPIName!='id')
                                                                {
                                                                    system.debug('fielddataType:'+fielddataType);
                                                                    system.debug('jsonParser.getText():'+jsonParser.getText());
                                                                    if(fielddataType == Schema.DisplayType.DateTime)
                                                                    {
                                                                        String dt=jsonParser.getText();
                                                                        Datetime dtime =Datetime.newinstance(Integer.valueof(dt.substring(0,4)),Integer.valueof(dt.substring(5,7)),Integer.valueof(dt.substring(8,10)),Integer.valueof(dt.substring(11,13)),Integer.valueof(dt.substring(14,16)),Integer.valueof(dt.substring(17,19)));
                                                                        objRec.put(fieldAPIName,dtime);
                                                                    }
                                                                    else if(fielddataType == Schema.DisplayType.Double)
                                                                    {
                                                                        objRec.put(fieldAPIName, Double.Valueof(jsonParser.getText()));
                                                                    }
                                                                    else if(fielddataType == Schema.DisplayType.Date)
                                                                    {
                                                                        String dt=jsonParser.getText();
                                                                        Date dtVal =Date.newinstance(Integer.valueof(dt.substring(0,4)),Integer.valueof(dt.substring(5,7)),Integer.valueof(dt.substring(8,10)));
                                                                        objRec.put(fieldAPIName,dtVal);
                                                                    }
                                                                    else if(fielddataType != Schema.DisplayType.Boolean)
                                                                        objRec.put(fieldAPIName, jsonParser.getText());
                                                                    else
                                                                    {
                                                                        if(jsonParser.getText()=='false')
                                                                            objRec.put(fieldAPIName, false);
                                                                        else 
                                                                            objRec.put(fieldAPIName, true);
                                                                    }
                                                                } 
                                                                else
                                                                {
                                                                    objRec.put(fieldAPIName, jsonParser.getText());
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        system.debug('8 -->:'+fieldName);
                                                        system.debug('6 --> '+fieldName+' --'+fieldNameMap.get(fieldName));
                                                        
                                                        if(fieldNameMap.get(fieldName)!=null)
                                                        {
                                                            fieldAPIName=fieldNameMap.get(fieldName);
                                                            fieldAPIName=fieldAPIName.toLowerCase();
                                                            Schema.DisplayType fielddataType = mapFieldList.get(fieldAPIName).getDescribe().getType();
                                                            system.debug('5 --> '+fieldName);
                                                            
                                                            if(mapFieldList.get(fieldAPIName).getDescribe().isUpdateable() && fielddataType == Schema.DisplayType.String)
                                                            {
                                                                system.debug('9-->fieldAPIName'+fieldAPIName);
                                                                if(jsonParser.getText()!=null && jsonParser.getText()!='')
                                                                {
                                                                    objRec.put(fieldAPIName, jsonParser.getText());
                                                                    system.debug('10-->'+jsonParser.getText());
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            if(objRec!=null && objRec.Id!=null)
                                                sobjectList.add(objRec);
                                            else
                                                sobjectInsertList.add(objRec);
                                            
                                        }
                                    }  
                                } 
                            }
                        }
                    }             
                }   
                list<Database.SaveResult> results =null;
                String ErrorMessage='';
                if(sobjectList.size()>0)
                {
                    results = Database.update(sobjectList,false);
                    for ( Integer i = 0; i < results.size(); i++ ) 
                    {
                        if ( !results.get(i).isSuccess() ) 
                        {
                            for ( Database.Error theError : results.get(i).getErrors() )
                            {
                                if(!theError.getMessage().contains('This is record stopped to update to avoid overriding of Salesforce latest updates by iFB (Toilet)'))
                                    ErrorMessage=ErrorMessage+'-- Record Id:'+results[i].id+'==>'+theError.getMessage();
                                
                            }    
                        }
                    }     
                }
                
                
                list<Database.SaveResult> upsertresult =null;
                if(sobjectInsertList.size()>0)
                {
                    upsertresult = Database.insert(sobjectInsertList,false);
                    for ( Integer i = 0; i < upsertresult.size(); i++ ) 
                    {
                        if ( !upsertresult.get(i).isSuccess() ) 
                        {
                            for ( Database.Error theError : upsertresult.get(i).getErrors())
                                if(!theError.getMessage().contains('This is record stopped to update to avoid overriding of Salesforce latest updates by iFB (Toilet)'))
                                ErrorMessage=ErrorMessage+'-- Record Id:'+upsertresult[i].id+'==>'+theError.getMessage();
                        }
                    }     
                }
                
                if(ErrorMessage!='')
                {
                    logRec.Status__c='Salesforce Exception';
                    logRec.Response_String__c=logRec.Response_String__c+'--->Salesforce Exception:'+ErrorMessage;
                }
                else
                {
                    for(AWS_Credentials__c awsRec : [Select Id,PULL_Toilet_Feedback_Start_Datetime__c,PULL_Toilet_Feedback_End_Datetime__c,Push_EndPoint__c from AWS_Credentials__c where Name = 'AWS' LIMIT 1])
                    {
                        if(awsRec.PULL_Toilet_Feedback_End_Datetime__c==null)
                            awsRec.PULL_Toilet_Feedback_Start_Datetime__c=System.now();
                        else
                        {
                            awsRec.PULL_Toilet_Feedback_Start_Datetime__c=awsRec.PULL_Toilet_Feedback_End_Datetime__c;
                            awsRec.PULL_Toilet_Feedback_End_Datetime__c=awsRec.PULL_Toilet_Feedback_End_Datetime__c.AddMinutes(15);
                        }
                        update awsRec;
                    }
                }
            }catch(Exception e)
            {
                System.debug('Exception:'+e.getMessage());
                logRec.Status__c='Salesforce Exception';
                logRec.Response_String__c=logRec.Response_String__c+'--->Salesforce Exception'+e.getMessage()+'--'+e.getStackTraceString();
            }
            if(system.label.Create_Pull_Log=='TRUE')
                insert logRec;    
            //system.debug(res1.getBody());
        }catch(Exception e)
        {
            System.debug('Exception:'+e.getMessage());
            System.debug('Exception:'+e.getLinenumber());
        }
        if(logRec!=null && logRec.id!=null)
        {
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(responseString);
            attachment.Name = String.valueOf('Pull Jason String.txt');
            attachment.ParentId = logRec.id; 
            insert attachment;
        }
    }
}