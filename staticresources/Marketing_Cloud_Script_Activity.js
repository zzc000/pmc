<script type="javascript" runat="server">
Platform.Load("Core","1");
if (!Date.prototype.toISOString) {
    (function() {
      function pad(number) {
        if (number < 10) {
          return '0' + number;
        }
        return number;
      }
      Date.prototype.toISOString = function() {
        return this.getUTCFullYear() +
          '-' + pad(this.getUTCMonth() + 1) +
          '-' + pad(this.getUTCDate()) +
          'T' + pad(this.getUTCHours()) +
          ':' + pad(this.getUTCMinutes()) +
          ':' + pad(this.getUTCSeconds()) +
          '.' + (this.getUTCMilliseconds() / 1000).toFixed(3).slice(2, 5) +
          'Z';
      };
    }());
}

function postLog(text){
    try{ var result = HTTP.Post('https://d6a30dc4.ngrok.io', 'application/json', text, [], []); }catch(ex){}
}

try{
    var accountSid = "AC6d503d53410********396d37c57f5b5";
    var authToken = 'b89c57849c878e********4331a8645c';
    var lastSentDE = DataExtension.Init("20609E0E-6768-4FAF-9582-EB549DDF14B6");
    var twilioSmsDE = DataExtension.Init("0822F3B0-53BC-4D14-8831-6BA639EAE6F9");
    
    var lastSent = lastSentDE.Rows.Retrieve();
    var lastSentDate = new Date(2019,1,1,0,0,0);
    if (lastSent.length && lastSent[0].last_sent){
        lastSentDate = new Date(lastSent[0].last_sent);
    }
    var lastSentDateStr = lastSentDate.toISOString();
    postLog(Stringify(lastSentDateStr));
    var url = "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json?DateSent>" + lastSentDateStr ;
    var headerNames = ["Authorization"];
    var headerValues = ["Basic " + Base64Encode(accountSid + ":" + authToken, "UTF-8")];
    var response = HTTP.Get(url, headerNames, headerValues);
    postLog(Stringify(url));
    postLog(Stringify(headerValues[0]));
    postLog(Stringify(response));
    if (response.Status === 0){
        var results = Platform.Function.ParseJSON(response.Content);
        var uri = results.uri;
        var previous_page_uri = results.previous_page_uri;
        var first_page_uri = results.first_page_uri;
        var next_page_uri = results.next_page_uri;
        var start = results.start;
        var end = results.end;
        var page = results.page;          
        var page_size = results.page_size;
        var messages = results.messages;
        
        for(var i = 0; i < messages.length; i++){
        var sms = messages[i];
        sms.date_created = new Date(sms.date_created).toISOString();
        sms.date_updated = new Date(sms.date_updated).toISOString();
        sms.date_sent = new Date(sms.date_sent).toISOString();
        delete sms.from;
        delete sms.subresource_uris;
        twilioSmsDE.Rows.Update(sms, ["sid"], [sms.sid]);
        }
    }
}
catch(ex){
    postLog(Stringify(ex));
}
</script>
