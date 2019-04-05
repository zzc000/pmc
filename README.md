<a href="https://www.amazon.com/dp/B07QHF4117"><h1>Programming Salesforce Marketing Cloud</h1></a>
<p align="center">
  <a href="https://www.amazon.com/dp/B07QHF4117"><img src="images/ProgrammingMarketingCloud.jpg" width="200"  /></a>
</p>

## Install salesforce unmanaged package

The full working sample code discussed in the book <a href="https://www.amazon.com/dp/B07QHF4117">"Programming Salesforce Marketing Cloud"</a> can be installed as unmanaged package from the URL or short URL:

- **Production / Developer Org**:
    - https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0o000002pZhS
    - https://sforce.co/2FRI0Ee
- **Sandbox**:
    - https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0o000002pZhS
    - https://sforce.co/2I8yZZ4

Below table lists major components of this unmanaged package.

| Component Type | Component Name | Description |
|--|--|--|
| Apex Class | CustomSms | Class contains our domain data model |
| Apex Class | MarketingCloudControllerBase | Base class for CustomSmsAppController and CustomSmsActivityController, including logic to perform authorization code oAuth 2.0 flow  |
| Apex Class | CustomSmsAppController | Controller for CustomSmsApp Visualforce Page |
| Apex Class | CustomSmsActivityController | Controller for CustomSmsActivity Visualforce Page |
| Apex Class | CustomSmsActivityService | REST service for CustomSmsActivity |
| Apex Class | MarketingCloudClientV2 | Class contains methods to invoke marketing cloud REST and SOAP API  |
| Apex Class | MarketingCloudClientFactory | Class to read marketing cloud settings (client id, client secret, URLs) from custom metadata and initiate MarketingCloudClientV2 instances |
| Apex Class | TwilioService | Use Twilio to send out SMS |
|   |   |   |
| Unit Test | CustomSmsActivityControllerTest |  Test class for CustomSmsActivityController |
| Unit Test | CustomSmsAppControllerTest | Test class for CustomSmsAppController and MarketingCloudControllerBase |
| Unit Test | MarketingCloudClientFactoryTest | Test class for MarketingCloudClientFactory |
| Unit Test | CustomSmsActivityServiceTest | Test class for CustomSmsActivityService |
| Unit Test | MarketingCloudClientV2Test | Test class for MarketingCloudClientV2 |
| Unit Test | TwilioServiceTest | Test class for TwilioService |
|   |   |   |
| Visualforce Page | CustomSmsActivity | User interface for custom activity |
| Visualforce Page | CustomSmsApp | User interface for custom app |
|   |   |   |
| Static Resource | postmonger | JavaScript framework to communicate between custom activity and journey builder |
| Static Resource | MarketingCloudActivityConfig | JSON file contains configuration for custom activity |
| Static Resource | MarketingCloudApp | Contains data table style sheet and JavaScript used in custom app user interface |
| Static Resource | Marketing_Cloud_SQL_Query | SQl for marketing cloud SQL Query activity |
| Static Resource | Marketing_Cloud_Script_Activity | Server Side JavaScript for marketing cloud Script Activity |
| Static Resource | Server_Side_JavaScript_Landing_Page | HTML for marketing cloud landing page to test server side JavaScript |
|   |   |   |
| Remote Site | Marketing_Cloud_Auth_Tenant | Marketing cloud authentication base URL for your instance |
| Remote Site | Marketing_Cloud_REST_Tenant | Marketing cloud REST API endpoint URL for your instance |
| Remote Site | Marketing_Cloud_SOAP_Tenant | Marketing cloud SOAP API endpoint URL for your instance |
| Remote Site | Twilio_API | Twilio API endpoint URL to send out SMS  |
|   |   |   |
| Custom Metadata Type | Marketing Cloud Package Setting | Custom Metadata to save marketing cloud settings (client id, client secret, URLs) |

There are eleven marketing cloud settings saved in custom metadata

- **WebServerClientId**: client id for web server API integration component
- **WebServerClientSecret**: client secret for web server API integration component
- **activityRedirectUri**: URL for custom activity in salesforce site, added to the web server API integration component redirect Uri
- **appRedirectUri**: URL for custom app in salesforce site, added to the web server API integration component redirect Uri
- **authBaseUriTenant**: marketing cloud authentication base uri
- **dataExtensionExternalKey**: external key for marketing cloud data extension saving Twilio SMS
- **jwtSigningSecret**: jwt signing secret for the marketing cloud package contain custom activity
- **restBaseUriTenant**: Marketing cloud REST API endpoint URL for your instance
- **server2ServerClientId**: client id for server to server API integration component
- **server2ServerClientSecret**: client secret for server to server API integration component
- **soapBaseUriTenant**: Marketing cloud SOAP API endpoint URL for your instance

## create salesforce site

After install the unmanaged package, let's create a site within salesforce.

1. create site and write down **site URL**
1. set the value for "**Clickjack Protection Level**" to "**Allow framing of site or community pages on external domains (Good protection)**"
1. add the following two domian to site "**whitelisted domains for inline frames**", remember change it to your marketing cloud instance url, mine is on s10 instance, yours could be different.
    - https://mc.s10.exacttarget.com 
    - https://jbinteractions.s10.marketingcloudapps.com 
1. add visualforce page "**CustomSmsApp**" and "**CustomSmsActivity**" to "**site visualforce pages**"
1. add apex class "**CustomSmsActivityService**" to site "**public access settings**"

## update custom activity configuration file in static resource

Find static resource named "**MarketingCloudActivityConfig**" and update the json configuration file. Update URL in line
- **arguments.execute.url** (line 33): https://YOUR-SALESFORCE-SITE-URL/services/apexrest/activity/sms/execute
- **configurationArguments.publish.url** (line 38): https://YOUR-SALESFORCE-SITE-URL/services/apexrest/activity/sms/publish
- **configurationArguments.validate.url** (ine 43): https://YOUR-SALESFORCE-SITE-URL/services/apexrest/activity/sms/validate
- **userInterfaces.configModal.url** (line 50): https://YOUR-SALESFORCE-SITE-URL/CustomSmsActivity?ui=configModal
- **userInterfaces.runningModal.url** (line 55): https://YOUR-SALESFORCE-SITE-URL/CustomSmsActivity?ui=runningModal
- **userInterfaces.runningHover.url** (line 58): https://YOUR-SALESFORCE-SITE-URL/CustomSmsActivity?ui=runningHover

## Apply for Twilio trial number

1. Register Twilio account
1. apply for trial number
1. write down **account sid**, **auth token** and **trial number** from Twilio dashboard
1. open apex class **TwilioService**, and change the following 3 property value to your Twilio account information
    - accountSid
    - authToken
    - fromNumber 

```java
public class TwilioService {
    
    private static final string accountSid = 'AC76667a24********4ba0426aaa7f3';
    private static final string authToken = '26af21290d5********36043b8686748';
    private static final string fromNumber = '+12016465074';
}
```

## create marketing cloud packages and components

1. create one marekting cloud package "**Custom SMS App & Activity**" and add the following components to it.
1. add **web server API integration** to the package and add the following two url to the redirect uri
    - https://YOUR-SALESFORCE-SITE-URL/CustomSmsApp
    - https://YOUR-SALESFORCE-SITE-URL/CustomSmsActivity
1. add **marketing cloud app** to the package and set the below login and logout url
    - Login Endpoint: https://YOUR-SALESFORCE-SITE-URL/CustomSmsApp
    - Logout Endpoint: https://YOUR-SALESFORCE-SITE-URL/CustomSmsApp?logout=1
1. add **journey builder activity** to the package and set the below url for Endpoint URL
    - Endpoint URL: https://YOUR-SALESFORCE-SITE-URL/services/apexrest/activity/sms
1. create another marketing cloud package "**Custom SMS Service**" and add **server to server API integration** component to it.
1. create data extension named "Twilio_SMS" to save Twilio SMS
1. (Optional) create data extension named "**Last Twilio SMS Sent Time**" to save last sent time of Twilio SMS
1. (Optional) create SQL Query activity and Script activity using the content of salesforce static resource to update Twilio SMS delivery status
    - Static Resource Name for **SQL Query activity**: Marketing_Cloud_SQL_Query
    - Static Resource Name for **Script activity**: Marketing_Cloud_Script_Activity
    - Static Resource Name for **Landing Page**: Server_Side_JavaScript_Landing_Page
1. (Optional) create one automation and add above SQL Query activity as step 1 and Script activity as step 2, schedule this automation to run every hour.

## update settings in salesforce saved in custom metadata "Marketing Cloud Package Setting"

1. update the following marketing cloud settings in salesforce custom metadata "**Marketing Cloud Package Setting**"

   - **WebServerClientId**: client id for web server API integration component within package "Custom SMS App & Activity" 
   - **WebServerClientSecret**: client secret for web server API integration component within package "Custom SMS App & Activity" 
   - **activityRedirectUri**: https://YOUR-SALESFORCE-SITE-URL/CustomSmsActivity
   - **appRedirectUri**: https://YOUR-SALESFORCE-SITE-URL/CustomSmsApp
   - **authBaseUriTenant**: marketing cloud authentication base uri (https://YOUR_SUBDOMAIN.auth.marketingcloudapis.com)
   - **dataExtensionExternalKey**: external key for marketing cloud data extension "Twilio_SMS"
   - **jwtSigningSecret**: jwt signing secret for the marketing cloud package contain custom activity (Custom SMS App & Activity) 
   - **restBaseUriTenant**: Marketing cloud REST API endpoint URL for your instance (https://YOUR_SUBDOMAIN.rest.marketingcloudapis.com)
   - **server2ServerClientId**: client id for server to server API integration component within package "Custom SMS Service"
   - **server2ServerClientSecret**: client secret for server to server API integration component within package "Custom SMS Service"
   - **soapBaseUriTenant**: Marketing cloud SOAP API endpoint URL for your instance (https://YOUR_SUBDOMAIN.soap.marketingcloudapis.com/)

1. add the following URL to remote site

   - **Marketing_Cloud_Auth_Tenant**: https://YOUR_SUBDOMAIN.auth.marketingcloudapis.com
   - **Marketing_Cloud_REST_Tenant**: https://YOUR_SUBDOMAIN.rest.marketingcloudapis.com
   - **Marketing_Cloud_SOAP_Tenant**: https://YOUR_SUBDOMAIN.soap.marketingcloudapis.com

## Use custom Journey Builder activity and custom app

Now we can use custom activity within Journey Builder and access custom app under AppExchange menu.
