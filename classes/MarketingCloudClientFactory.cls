public class MarketingCloudClientFactory {

    private static final string server2ServerClientId,server2ServerClientSecret,webServerClientId,webServerClientSecret,authBaseUri,restBaseUri,soapBaseUri,jwtSigningSecret,dataExtensionExternalKey,activityRedirectUri,appRedirectUri;    
    @TestVisible
    private static MarketingCloudClientV2 server2ServerClient,webServerClient;
    
    static {
        for(Marketing_Cloud_Package_Setting__mdt setting : [SELECT DeveloperName, Value__c FROM Marketing_Cloud_Package_Setting__mdt]){
            if (setting.DeveloperName.equalsIgnoreCase('server2ServerClientId')){
                server2ServerClientId = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('server2ServerClientSecret')){
                server2ServerClientSecret = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('WebServerClientId')){
                webServerClientId = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('WebServerClientSecret')){
                webServerClientSecret = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('authBaseUriTenant')){
                authBaseUri = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('restBaseUriTenant')){
                restBaseUri = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('soapBaseUriTenant')){
                soapBaseUri = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('jwtSigningSecret')){
                jwtSigningSecret = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('appRedirectUri')){
                appRedirectUri = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('activityRedirectUri')){
                activityRedirectUri = setting.Value__c;
            }
            else if (setting.DeveloperName.equalsIgnoreCase('dataExtensionExternalKey')){
                dataExtensionExternalKey = setting.Value__c;
            }
        }
    }
    
    public static string getWebServerClientId(){
        return webServerClientId;
    }
    
    public static string getAuthBaseUri(){
        return authBaseUri;
    }
    
    public static string getJwtSigningSecret(){
        return jwtSigningSecret;
    }
    
    public static string getActivityRedirectUri(){
        return activityRedirectUri;
    }
    
    public static string getAppRedirectUri(){
        return appRedirectUri;
    }
    
    public static string getDataExtensionExternalKey(){
        return dataExtensionExternalKey;
    }
    
    public static MarketingCloudClientV2 createServer2ServerClient(){
        if (server2ServerClient == null){
            
          server2ServerClient = new MarketingCloudClientV2(server2ServerClientId, server2ServerClientSecret, authBaseUri, restBaseUri,soapBaseUri);
        }
        return server2ServerClient;
    }
    
    public static MarketingCloudClientV2 createWebServerClient(){
        if (webServerClient == null){
            
          webServerClient = new MarketingCloudClientV2(webServerClientId, webServerClientSecret, authBaseUri, restBaseUri,soapBaseUri);
        }
        return webServerClient;
    }
}
