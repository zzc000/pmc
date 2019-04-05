global class CustomSmsActivityController extends MarketingCloudControllerBase {
  
    public override string getRedirectUri(){
        return MarketingCloudClientFactory.getActivityRedirectUri();
    }
    
    @RemoteAction
    global static CustomSms.Template[] getContentBuilderSmsTemplates(string token) {
        
        string filter = 'assetType.name eq \'jsonmessage\'';
        string fields = 'id,name,description,views';
        string query = string.format('$filter={0}&$fields={1}', new string[] { EncodingUtil.urlEncode(filter, 'UTF-8'), EncodingUtil.urlEncode(fields, 'UTF-8') });
        MarketingCloudClientV2 client = MarketingCloudClientFactory.createWebServerClient();
        
        string queryResponseJson = client.assetSimpleQuery(token, query);
        system.debug(queryResponseJson);
        Map<string, object> queryResponseMap = (Map<string, object>)JSON.deserializeUntyped(queryResponseJson);
        List<object> smsTemplateList = (List<object>)queryResponseMap.get('items');
        
        CustomSms.Template[] smsTemplates = new List<CustomSms.Template>();
        
        for(object smsTemplateObject : smsTemplateList){
            
            CustomSms.Template template = new CustomSms.Template();
            
            Map<string, object> smsTemp = (Map<string, object>)smsTemplateObject;
            
            template.Id = string.valueOf(smsTemp.get('id'));
            template.Name = string.valueOf(smsTemp.get('name'));
            Map<string, object> viewsMap = (Map<string, object>)smsTemp.get('views');
            Map<string, object> smsMap = (Map<string, object>)viewsMap.get('sMS');
            Map<string, object> metaMap = (Map<string, object>)smsMap.get('meta');
            Map<string, object> optionsMap = (Map<string, object>)metaMap.get('options');
            Map<string, object> customBlockDataMap = (Map<string, object>)optionsMap.get('customBlockData');
            template.Content = string.valueOf(customBlockDataMap.get('display:message'));
            
            smsTemplates.add(template);
        }
                
        return smsTemplates;
    }
}
