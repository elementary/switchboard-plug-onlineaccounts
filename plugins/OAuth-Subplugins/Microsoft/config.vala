
namespace OnlineAccounts.Plugins.Microsoft.Config {
    
    const string[] schemes = {
        "https"
    };
    
    const string[] scopes = {
        "wl.basic",
        "wl.birthday",
        "wl.emails",
        "wl.offline_access",
        "wl.postal_addresses",
        "wl.phone_numbers",
        "wl.calendars_update",
        "wl.events_create",
        "wl.contacts_photos",
        "wl.contacts_create",
        "wl.contacts_skydrive",
        "wl.skydrive_update"
    };
    
    const string response_type = "code";
    const string auth_host = "login.live.com";
    const string auth_path = "/oauth20_authorize.srf";
    const string auth_query = "&access_type=offline&approval_prompt=force";
    const string token_path = "/oauth20_token.srf";
    const string redirect_uri = "http://elementaryos.org";
    const string client_id = "00000000400ECC75";
    const string client_secret = "SFHsDQX7IuyykXpSfGKJxh7xcRCKX1Gd";
}
