public class TwilioService {
    
    @TestVisible
    private static final string accountSid = 'AC76667a249************a0426aaa7f3';
    @TestVisible
    private static final string authToken = '26af21290d57************b8686748';
    @TestVisible
    private static final string fromNumber = '+12016465074';
    
    public static string sendSms(string toNumber, string text){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/Messages.json');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountSid + ':' + authToken)));
        req.setBody(string.format('From={0}&To={1}&Body={2}', new string[]{ EncodingUtil.urlEncode(fromNumber, 'UTF-8'), EncodingUtil.urlEncode(toNumber, 'UTF-8'), EncodingUtil.urlEncode(text, 'UTF-8') }));
        HttpResponse res = new Http().send(req);
        return res.getBody();
    }
    
    public static string formatGmt(string datetimeStr){
        if (datetimeStr == null || datetimeStr.equalsIgnoreCase('null') || string.isBlank(datetimeStr)){
            return null;
        }
        string[] datetimeParts = datetimeStr.split(' ');
        integer day = integer.valueOf(datetimeParts[1].trim());
        integer month = 0;
        switch on (datetimeParts[2].tolowercase()){
            when 'jan' {
                month = 1;
            }
            when 'feb' {
                month = 2;
            }
            when 'mar' {
                month = 3;
            }
            when 'apr' {
                month = 4;
            }
            when 'may' {
                month = 5;
            }
            when 'jun' {
                month = 6;
            }
            when 'jul' {
                month = 7;
            }
            when 'aug' {
                month = 8;
            }
            when 'sep' {
                month = 9;
            }
            when 'oct' {
                month = 10;
            }
            when 'nov' {
                month = 11;
            }
            when 'dec' {
                month = 12;
            }
        }
        integer year = integer.valueOf(datetimeParts[3].trim());
        string timeStr = datetimeParts[4];
        string[] timeParts = timeStr.split(':');
        integer hour = integer.valueOf(timeParts[0].trim());
        integer minute = integer.valueOf(timeParts[1].trim());
        integer second = integer.valueOf(timeParts[2].trim());
        datetime datetimeGmt = datetime.newInstanceGmt(year, month, day, hour, minute, second);
        return datetimeGmt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
}
