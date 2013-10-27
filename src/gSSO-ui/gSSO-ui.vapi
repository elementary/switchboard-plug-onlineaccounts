
[CCode (cprefix = "GSSOUI", lower_case_cprefix = "gsso_ui_")]
namespace gSSOui {
    [CCode (cheader_filename = "gsso-ui-server.h", type_id = "gsso_ui_server_get_type ()")]
    public class Server : GLib.Object {
        [CCode (has_construct_function = false)]
        public Server (uint32 timeout);
        bool start ();
        void stop ();
        void push_dialog (gSSOui.DialogService serive, GLib.DBusMethodInvocation invocation, GLib.HashTable<string, GLib.Variant> params);
        bool refresh_dialog (gSSOui.DialogService service, GLib.HashTable<string, GLib.Variant> params);
        bool cancel_dialog (gSSOui.DialogService service, string id);
    }
    
    [CCode (cheader_filename = "gsso-ui-dialog-service.h", type_id = "gsso_ui_dialog_service_get_type ()")]
    public class DialogService : GLib.Object {
        [CCode (has_construct_function = false)]
        public DialogService ();
        void notify_reply (GLib.DBusMethodInvocation invocation, GLib.HashTable<string, GLib.Variant> reply);
        void emit_refresh (string request_id);
    }
}
