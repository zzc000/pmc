@RestResource(urlMapping='/activity/sms/*')
global with sharing class CustomSmsActivityService {

    @TestVisible
    private static final string webServicePath = '/activity/sms/';
    @TestVisible
    private static final string customActivityConfigResourceName = 'MarketingCloudActivityConfig';
    
    @TestVisible
    private static final string jwtSigningSecret,dataExtensionExternalKey;
    @TestVisible
    private static MarketingCloudClientV2 client;
    
    public string token { get; set; }
    
    static {
        jwtSigningSecret = MarketingCloudClientFactory.getJwtSigningSecret();
        dataExtensionExternalKey = MarketingCloudClientFactory.getDataExtensionExternalKey();
        client = MarketingCloudClientFactory.createServer2ServerClient();
    }
    
    @HttpGet
    global static void getConfig() {
        
        String name = Restcontext.request.requestURI.substring(Restcontext.request.requestURI.lastIndexOf('/') + 1);
        
        if (name.equalsIgnoreCase('config.json')) {
            
            StaticResource[] staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = :customActivityConfigResourceName LIMIT 1];
            if (staticResources.size() == 1){                
                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = staticResources[0].Body;
            }
            else {
                RestContext.response.statusCode = 404;
            }
        }
        else {
            RestContext.response.statusCode = 404;
        }
    }
    
    @HttpPost
    global static void doPost(){
        
        string requestUri = RestContext.request.requestURI;
        String name = requestUri.substring(requestUri.lastIndexOf('/') + 1).toLowerCase();
        integer queryIndex = name.indexOf('?');
        if (queryIndex > 0){
            name = name.substring(0, queryIndex);
        }
        
        String jsonResult;
        switch on name {
            when 'execute', 'publish', 'validate' {
                String requestBody = RestContext.request.requestBody.toString();
                if (name.equalsIgnoreCase('execute')){
                    jsonResult = execute(requestBody);
                }
                else if (name.equalsIgnoreCase('publish')){
                    jsonResult = publish(requestBody);
                }
                else if (name.equalsIgnoreCase('validate')){
                }
            }
            when 'save', 'unpublish', 'stop', 'TestSave' {
                RestContext.response.statusCode = 501;
            }
            when else {
                RestContext.response.statusCode = 404;
            }
        }
        
        if (string.isNotBlank(jsonResult)){
            RestContext.response.responseBody = Blob.valueOf(jsonResult);
        }
    }    

    @TestVisible
    private static string execute(string requestBody){
        
        system.debug(requestBody);
        if (string.isBlank(requestBody)){
            return null;
        }
        requestBody = MarketingCloudClientV2.decodeJwt(jwtSigningSecret, requestBody);
        system.debug(requestBody);
        
        Map<String,Object> mktParams = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        List<Object> inArguments = (List<Object>)mktParams.get('inArguments');
        Map<String,Object> inArguments1 = (Map<String,Object>)inArguments.get(0);
        string contactKey = string.valueOf(inArguments1.get('contactKey'));
        string mobile = string.valueOf(inArguments1.get('mobile'));
        if (!mobile.startsWithIgnoreCase('+')){
            mobile = '+' + mobile;
        }
        string email = string.valueOf(inArguments1.get('email'));
        Map<String,Object> smsTemplate = (Map<String,Object>)inArguments1.get('smsTemplate');
        string smsTemplateId = string.valueOf(smsTemplate.get('Id'));
        string smsTemplateName = string.valueOf(smsTemplate.get('Name'));
        string smsTemplateContent = string.valueOf(smsTemplate.get('Content'));
        string smsTemplateComplied = string.valueOf(smsTemplate.get('Complied'));
        List<Object> smsTemplateVariables = (List<Object>)smsTemplate.get('Variables');
        for(Object smsTemplateVariable : smsTemplateVariables){
            Map<string, object> templateVariable = (Map<string, object>)smsTemplateVariable;
            string variableName = string.valueOf(templateVariable.get('name'));
            string variableValue = string.valueOf(templateVariable.get('value'));
            // smsTemplateContent = smsTemplateContent.replace('%%' + variableName + '%%', variableValue);
        }
        
        // get access token from marketing cloud
        MarketingCloudClientV2.MarketingCloudToken token = client.requestToken();
        
        // get SMS template from marketing cloud
        CustomSms.Template serverTemplate = getSmsTemplate(token.access_token, smsTemplateId);
        
        if (serverTemplate != null){
            // find template placeholders
            Set<string> templateVariables = new Set<string>();
            Matcher m = Pattern.compile('%%(.*?)%%').matcher(serverTemplate.Content);
            while(m.find()) {
                string templateVariableName = m.group().replace('%%', '');
                templateVariables.add(templateVariableName);
            }
            
            // get contact attributes from marketing cloud
            Map<String, Object> contactAttributes = client.getContactAttributes(token.access_token, contactKey, new List<string>(templateVariables));
            
            // compile SMS template with contact attribute value
            string compliedTemplate = serverTemplate.Content;
            for(string templateVariable : templateVariables){
                compliedTemplate = compliedTemplate.replace('%%' + templateVariable + '%%', string.valueOf(contactAttributes.get(templateVariable.remove('"'))));
            }
            
            // send SMS through Twilio
            string twilioResponseJson = TwilioService.sendSms(mobile, compliedTemplate);
            system.debug(twilioResponseJson);
            
            // upsert Twilio SMS response into Marketing Cloud data extension
            CustomSms.Dto twilioWrapper = convert(twilioResponseJson);
            twilioWrapper.values.template_id = smsTemplateId;
            twilioWrapper.values.template_name = smsTemplateName;            
            
            string response = client.upsertDataExtensionRows(token.access_token, dataExtensionExternalKey, JSON.serialize(new CustomSms.Dto[] { twilioWrapper }));
            system.debug(response);
        }        
        
        return null;
    }
    
    @TestVisible
    private static CustomSms.Template getSmsTemplate(string token, string smsTemplateId){
        
        if (string.isBlank(token) || string.isBlank(smsTemplateId)){
            return null;
        }
        
        string response = client.getAsset(token, integer.valueOf(smsTemplateId));
        Map<String, Object> smsTemp = (Map<String, Object>)JSON.deserializeUntyped(response);        
        
        CustomSms.Template template = new CustomSms.Template();
        
        template.Id = string.valueOf(smsTemp.get('id'));
        template.Name = string.valueOf(smsTemp.get('name'));
        Map<string, object> viewsMap = (Map<string, object>)smsTemp.get('views');
        Map<string, object> smsMap = (Map<string, object>)viewsMap.get('sMS');
        Map<string, object> metaMap = (Map<string, object>)smsMap.get('meta');
        Map<string, object> optionsMap = (Map<string, object>)metaMap.get('options');
        Map<string, object> customBlockDataMap = (Map<string, object>)optionsMap.get('customBlockData');
        template.Content = string.valueOf(customBlockDataMap.get('display:message'));
        
        return template;
    }
    
    @TestVisible
    private static CustomSms.Dto convert(string twilioResponseJson){
        Map<string, object> twilioResponseMap = (Map<string, object>)JSON.deserializeUntyped(twilioResponseJson);
        CustomSms.Dto dto = new CustomSms.Dto();
        dto.keys = new CustomSms.Keys();
        dto.keys.sid = string.valueOf(twilioResponseMap.get('sid'));
        dto.values = new CustomSms();
        dto.values.date_created = TwilioService.formatGmt(string.valueOf(twilioResponseMap.get('date_created')));
        dto.values.date_updated = TwilioService.formatGmt(string.valueOf(twilioResponseMap.get('date_updated')));
        dto.values.date_sent = TwilioService.formatGmt(string.valueOf(twilioResponseMap.get('date_sent')));
        dto.values.account_sid = string.valueOf(twilioResponseMap.get('account_sid'));
        dto.values.to = string.valueOf(twilioResponseMap.get('to'));
        dto.values.fromNumber = string.valueOf(twilioResponseMap.get('from'));
        dto.values.messaging_service_sid = string.valueOf(twilioResponseMap.get('messaging_service_sid'));
        dto.values.body = string.valueOf(twilioResponseMap.get('body'));
        dto.values.status = string.valueOf(twilioResponseMap.get('status'));
        dto.values.num_segments = string.valueOf(twilioResponseMap.get('num_segments'));
        dto.values.num_media = string.valueOf(twilioResponseMap.get('num_media'));
        dto.values.direction = string.valueOf(twilioResponseMap.get('direction'));
        dto.values.api_version = string.valueOf(twilioResponseMap.get('api_version'));
        dto.values.price = string.valueOf(twilioResponseMap.get('price'));
        dto.values.price_unit = string.valueOf(twilioResponseMap.get('price_unit'));
        dto.values.error_code = string.valueOf(twilioResponseMap.get('error_code'));
        dto.values.error_message = string.valueOf(twilioResponseMap.get('error_message'));
        dto.values.uri = string.valueOf(twilioResponseMap.get('uri'));
        Map<string, object> subresource_uris_obj = (Map<string, object>)twilioResponseMap.get('subresource_uris');
        if (subresource_uris_obj != null){
            dto.values.subresource_uris_media = string.valueOf(subresource_uris_obj.get('media'));
        }        
        return dto;
    }
    
    @TestVisible
    private static string publish(string requestBody){
        return null;
    }
}
