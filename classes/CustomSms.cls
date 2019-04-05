global class CustomSms {

    public String sid;
    public String date_created;
    public String date_updated;
    public String date_sent;
    public String account_sid;
    public String to;
    public String fromNumber;
    public String messaging_service_sid;
    public String body;
    public String status;
    public String num_segments;
    public String num_media;
    public String direction;
    public String api_version;
    public String price;
    public String price_unit;
    public String error_code;
    public String error_message;
    public String uri;
    public string subresource_uris_media;
    public String template_id;
    public string template_name;
    
    public class Dto {
        public Keys keys;
      public CustomSms values;
    }
    
    public class Keys {
        public String sid;
    }
    
    global class Template{
        public string Id;
        public string Name;
        public string Content;
    }
}
