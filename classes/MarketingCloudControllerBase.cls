global abstract class MarketingCloudControllerBase {

    @TestVisible
    protected final string clientId,authBaseUri,redirectUri;
    @TestVisible
    protected MarketingCloudClientV2 client;
    
    public string token { get; set; } 
    
    public MarketingCloudControllerBase(){
        clientId = MarketingCloudClientFactory.getWebServerClientId();
        authBaseUri = MarketingCloudClientFactory.getAuthBaseUri();
        redirectUri = getRedirectUri();
        client = MarketingCloudClientFactory.createWebServerClient();
    }
    
    global abstract string getRedirectUri();
        
    public PageReference authenticate(){        
        
        Map<String, Cookie> cookiesMap = ApexPages.currentPage().getCookies();
        if (cookiesMap.containsKey('token')){
            Cookie tokenCookie = cookiesMap.get('token');
            this.token = tokenCookie.getValue();
            if (string.isNotBlank(this.token)){
                return null;
            }
        }
        
        string code = ApexPages.currentPage().getParameters().get('code');
        if (string.isNotBlank(code)){            
            MarketingCloudClientV2.MarketingCloudToken oauthToken = client.requestToken(code, redirectUri);
            this.token = oauthToken.access_token;
            if (string.isNotBlank(this.token)){
                //Cookie[] cookies = cookiesMap.values();
                //Cookie tokenCookie = new Cookie('token', this.token, null, oauthToken.expires_in, true);
                //cookies.add(tokenCookie);
                //ApexPages.currentPage().setCookies(cookies);
                ApexPages.currentPage().setCookies(new Cookie[]{ new Cookie('token', this.token, null, oauthToken.expires_in, true) });
                PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl().substringBefore('?'));
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        
        PageReference pageRef = new PageReference(authBaseUri + 'v2/authorize?response_type=code&client_id=' + clientId + '&redirect_uri=' + redirectUri);
        return pageRef;
    }
}
