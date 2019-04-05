public class MarketingCloudClientV2 {
    
    @TestVisible
    private string clientId, clientSecret, authBaseUri, restBaseUri,soapBaseUri;
    public static final string serviceNS = 'http://exacttarget.com/wsdl/partnerAPI';
    
    public class MarketingCloudToken{
        public String access_token;
        public String refresh_token;
        public Integer expires_in;
        public String token_type;
        public String rest_instance_url;
        public String soap_instance_url;
        public String scope;
    }
    
    public MarketingCloudClientV2(string clientId, string clientSecret, string authBaseUri, string restBaseUri, string soapBaseUri){
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.authBaseUri = authBaseUri;
        this.restBaseUri = restBaseUri;
        this.soapBaseUri = soapBaseUri;
    }
    
    public string getClientId(){
        return clientId;
    }
    
    @TestVisible
    private string getClientSecret(){
        return clientSecret;
    }
    
    public string getAuthBaseUri(){
        return authBaseUri;
    }
    
    public string getRestBaseUri(){
        return restBaseUri;
    }
    
    public string getSoapBaseUri(){
        return soapBaseUri;
    }
    
    public MarketingCloudToken requestToken(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authBaseUri + 'v2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"grant_type": "client_credentials",'+
                    '  "client_id": "' + clientId + '",'+
                    '  "client_secret": "' + clientSecret + '"}');
                    
        HttpResponse res = new Http().send(req);
        return (MarketingCloudToken) System.JSON.deserialize(res.getBody(), MarketingCloudToken.class);
    }
    
    public MarketingCloudToken requestToken(string authorizationCode, string redirectUri){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authBaseUri + 'v2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"grant_type": "authorization_code",'+
                    '  "code": "' + authorizationCode + '",'+
                    '  "client_id": "' + clientId + '",'+
                    '  "client_secret": "' + clientSecret + '",'+
                    '  "redirect_uri": "' + redirectUri + '"}');

        HttpResponse res = new Http().send(req);
        return (MarketingCloudToken) System.JSON.deserialize(res.getBody(), MarketingCloudToken.class);
    }
    
    public static DateTime parse(string dateString){
        if (string.isBlank(dateString)){
            return null;
        }
        Integer month = Integer.valueOf(dateString.substring(0, dateString.indexof('/')));
        Integer day = Integer.valueOf(dateString.substring(dateString.indexof('/') + 1, dateString.lastindexof('/')));
        Integer year = Integer.valueOf(dateString.substring(dateString.lastindexof('/') + 1, dateString.indexof(' ')));
        Integer hour = Integer.valueOf(dateString.substring(dateString.indexof(' ') + 1, dateString.indexof(':')));
        Integer minute = Integer.valueOf(dateString.substring(dateString.indexof(':') + 1, dateString.lastindexof(':')));
        Integer second = Integer.valueOf(dateString.substring(dateString.lastindexof(':') + 1, dateString.lastindexof(' ')));
        string apm = dateString.substring(dateString.lastindexof(' ') + 1);
        if (apm.equalsIgnoreCase('PM')){
            hour = hour + 12;
        }
        return datetime.newInstanceGmt(year, month, day, hour, minute, second);
    }
    
    public string upsertDataExtensionRows(string token, string dataExtensionExternalKey, string jsonData){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restBaseUri + 'hub/v1/dataevents/key:' + dataExtensionExternalKey + '/rowset');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setBody(jsonData);
        HttpResponse res = new Http().send(req);
        return res.getBody();
    }
    
    public Dom.XmlNode SoapDelete(string token, string deleteRequestXML){
        string soapXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
            '  xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
            '  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '  <soapenv:Header>' +
            '    <fueloauth>' + token + '</fueloauth>' +
            '  </soapenv:Header>' +
            '  <soapenv:Body>' +
            deleteRequestXML +
            '  </soapenv:Body>' +
            '</soapenv:Envelope>';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(soapBaseUri + 'Service.asmx');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setHeader('SOAPAction', 'Delete');
        req.setBody(soapXML);
        
        HttpResponse res = new Http().send(req);
        Dom.Document responseDoc = res.getBodyDocument();
        Dom.XmlNode rootNode = responseDoc.getRootElement();
        Dom.XmlNode bodyNode = rootNode.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode DeleteResponseNode = bodyNode.getChildElement('DeleteResponse', serviceNS);
        return DeleteResponseNode;
    }
    
    public Dom.XmlNode SoapRetrieve(string token, string retrieveRequestXML){
        string soapXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
            '  xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
            '  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '  <soapenv:Header>' +
            '    <fueloauth>' + token + '</fueloauth>' +
            '  </soapenv:Header>' +
            '  <soapenv:Body>' +
            '    <RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' + 
            retrieveRequestXML +
            '    </RetrieveRequestMsg>' +
            '  </soapenv:Body>' +
            '</soapenv:Envelope>';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(soapBaseUri + 'Service.asmx');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setHeader('SOAPAction', 'Retrieve');
        req.setBody(soapXML);
        
        HttpResponse res = new Http().send(req);
        Dom.Document responseDoc = res.getBodyDocument();
        Dom.XmlNode rootNode = responseDoc.getRootElement();
        Dom.XmlNode bodyNode = rootNode.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode RetrieveResponseMsgNode = bodyNode.getChildElement('RetrieveResponseMsg', serviceNS);
        return RetrieveResponseMsgNode;
    }
    
    public string assetSimpleQuery(string token, string query){
        HttpRequest req = new HttpRequest();
        //req.setEndpoint(restBaseUri + 'asset/v1/content/assets?' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setEndpoint(restBaseUri + 'asset/v1/content/assets?' + query);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse res = new Http().send(req);
        return res.getBody();
    }
    
    public string getAsset(string token, integer assetId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restBaseUri + 'asset/v1/content/assets/' + assetId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse res = new Http().send(req);
        return res.getBody();
    }
    
    public Map<String, Object> getContactAttributes(string token, string contactKey, string[] attributes){
        
        string requestJson = '{' +
        '    "request": {' +
        '        "attributes": [';
        
        for(string attributeName : attributes){
            attributeName = attributeName.remove('"');
            requestJson += '{ "key": "' + attributeName + '"},';
        }
        
        requestJson = requestJson.removeEnd(',');
        
        requestJson += ']' +
        '    },' +
        '    "conditionSet": {' +
        '        "operator": "And",' +
        '        "conditionSets": [],' +
        '        "conditions": [' +
        '            {' +
        '                "attribute": {' +
        '                    "key": "Contact.Contact Key"' +
        '                },' +
        '                "operator": "Equals",' +
        '                "value": {' +
        '                    "items": [' +
        '                        "customer1"' +
        '                    ]' +
        '                }' +
        '            }' +
        '        ]' +
        '    }' +
        '}';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restBaseUri + 'contacts/v1/attributes/search');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setBody(requestJson);
        HttpResponse res = new Http().send(req);
        
        system.debug(requestJson);
        system.debug(res.getBody());
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        List<Object> itemsList = (List<Object>)responseMap.get('items');
        
        Map<String, Object> contactAttributes = new Map<String, Object>();
        
        for(object item : itemsList){
            Map<String, Object> itemMap = (Map<String, Object>)item;
            List<Object> valuesList = (List<Object>)itemMap.get('values');
            for(object value : valuesList){
                Map<String, Object> attributeMap = (Map<String, Object>)value;
                if (attributeMap.containsKey('value')){
                    string name = string.valueOf(attributeMap.get('key'));
                    contactAttributes.put(name, attributeMap.get('value'));
                }
            }
        }
        
        return contactAttributes;
    }
    
    public static string decodeJwt(string privateKey, String base64url){
        
        if (string.isNotBlank(base64url)){
            string[] jwtParts = base64url.split('\\.');
            Blob privateKeyBlob = Blob.valueOf(privateKey);
            Blob data  = Crypto.generateMac('HmacSHA256', Blob.valueOf(jwtParts[0] + '.' + jwtParts[1]), privateKeyBlob);
            string sign = EncodingUtil.base64Encode(data).removeEnd('=').replace('+', '-').replace('/', '_');
            if (jwtParts[2].equals(sign)){
                //Convert base 64 url to base 64
                String base64 = jwtParts[1].replace('-', '+').replace('_', '/');
                //decodes a base-64 encoded string
                String utf8 = EncodingUtil.base64Decode(base64).toString();
                return utf8;
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }
}
