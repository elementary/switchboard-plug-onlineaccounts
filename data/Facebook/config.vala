
namespace OnlineAccounts.Plugins.Facebook.Config {
    
    const string[] schemes = {
        "https"
    };
    
    const string[] scopes = {
        "publish_stream",
        "read_stream",
        "status_update",
        "user_photos",
        "friends_photos",
        "xmpp_login"
    };
    
    const string response_type = "code";
    const string auth_host = "www.facebook.com";
    const string auth_path = "/dialog/oauth";
    const string token_path = "/dialog/oauth";
    const string redirect_uri = "https://www.facebook.com/connect/login_success.html";
    const string client_id = "217719465038528";
    const string client_secret = "";
}
