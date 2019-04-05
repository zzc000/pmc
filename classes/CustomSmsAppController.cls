global with sharing class CustomSmsAppController extends MarketingCloudControllerBase {
  
    public override string getRedirectUri(){
        return MarketingCloudClientFactory.getAppRedirectUri();
    }
    
    @RemoteAction
    global static CustomSms[] listSms(string token) {
        
        string dataExtensionExternalKey = MarketingCloudClientFactory.getDataExtensionExternalKey();
        MarketingCloudClientV2 client = MarketingCloudClientFactory.createWebServerClient();
        
        string requestBodyString = 
            '<RetrieveRequest>' +
            '  <ObjectType>DataExtensionObject[' + dataExtensionExternalKey + ']</ObjectType>' +
            '  <Properties>sid</Properties>' +
            '  <Properties>template_name</Properties>' +
            '  <Properties>to</Properties>' +
            '  <Properties>body</Properties>' +
            '  <Properties>date_created</Properties>' +
            '  <Properties>status</Properties>' +
            '  <Properties>date_sent</Properties>' +
            '  <Properties>date_updated</Properties>' +
            '  <Properties>error_message</Properties>' +
            '</RetrieveRequest>';
        
        Dom.XmlNode RetrieveResponseMsgNode = client.SoapRetrieve(token, requestBodyString);
        CustomSms[] smsList = convert(RetrieveResponseMsgNode);
                
        return smsList;
    }
    
    @TestVisible
    private static CustomSms[] convert(Dom.XmlNode RetrieveResponseMsgNode){
        CustomSms[] smsList = new List<CustomSms>();
        for (Dom.XmlNode childElement : RetrieveResponseMsgNode.getChildElements()){
            if (childElement.getName().equalsIgnoreCase('Results')){
                CustomSms template = new CustomSms();
                for (Dom.XmlNode templateElement : childElement.getChildElement('Properties', MarketingCloudClientV2.serviceNS).getChildElements()){
                    if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('sid')){
                        template.sid = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('template_name')){
                        template.template_name = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('to')){
                        template.to = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('body')){
                        template.body = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('date_created')){
                        string date_created = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                        if (string.isNotBlank(date_created)){
                            template.date_created = MarketingCloudClientV2.parse(date_created).format('YYYY-MM-dd\'T\'HH:MM:SS\'Z\'');
                        }                        
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('status')){
                        template.status = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('date_sent')){
                        string date_sent = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                        if (string.isNotBlank(date_sent)){
                          template.date_sent = MarketingCloudClientV2.parse(date_sent).format('YYYY-MM-dd\'T\'HH:MM:SS\'Z\'');
                        }
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('date_updated')){
                        string date_updated = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                        if (string.isNotBlank(date_updated)){
                          template.date_updated = MarketingCloudClientV2.parse(date_updated).format('YYYY-MM-dd\'T\'HH:MM:SS\'Z\'');
                        }
                    }
                    else if (templateElement.getChildElement('Name', MarketingCloudClientV2.serviceNS).getText().equalsIgnoreCase('error_message')){
                        template.error_message = templateElement.getChildElement('Value', MarketingCloudClientV2.serviceNS).getText();
                    }
                }
                smsList.add(template);                
            }
        }
        return smsList;
    }
}
