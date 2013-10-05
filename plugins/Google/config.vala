
namespace OnlineAccounts.GooglePlugin.Config {
    
    const string[] schemes = {
        "https",
        "http"
    };
    
    const string[] scopes = {
        "https://docs.google.com/feeds/",
        "https://www.googleapis.com/auth/googletalk",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://picasaweb.google.com/data/",
        "https://www.google.com/m8/feeds/" + "&access_type=offline&approval_prompt=force"
    };
    
    const string response_type = "code";
    const string auth_host = "accounts.google.com";
    const string auth_path = "/o/oauth2/auth";
    const string token_path = "/o/oauth2/token";
    const string redirect_uri = "http://elementaryos.org";
    const string client_id = "14954701535-q8brnt0l1o1sknuftm7tt3iqlaa1c95f.apps.googleusercontent.com";
    const string client_secret = "9sUlZ0q5-xBgAf5Rw7ZtuSjC";
}
