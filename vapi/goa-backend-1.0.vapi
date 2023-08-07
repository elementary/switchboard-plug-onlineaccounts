// goa-backend doesn't provide vapi file
// so this thing is handmade from .h files :)

[CCode (cprefix = "Goa", gir_namespace = "Goa", gir_version = "1.0", lower_case_cprefix = "goa_")]
namespace Goa {
    [CCode (cheader_filename = "goabackend/goabackend.h", type_id = "goa_provider_get_type ()")]
	public class Provider : GLib.Object {
        public static async bool get_all ([CCode (pos = 0)] out GLib.List<Goa.Provider> providers) throws GLib.Error;
        public static Goa.Provider? get_for_provider_type (string provider_type);
        public unowned string get_provider_type ();
        public string get_provider_name (Goa.Object? object);
        public GLib.Icon get_provider_icon (Goa.Object? object);
        public Goa.ProviderFeatures get_provider_features ();
        public Goa.Object add_account (Goa.Client client, Gtk.Dialog dialog, Gtk.Box vbox) throws GLib.Error;
        public bool refresh_account (Goa.Client client, Goa.Object object, Gtk.Window parent) throws GLib.Error;
        public void show_account (Goa.Client client, Goa.Object object, Gtk.Box vbox, Gtk.Grid dummy1, Gtk.Grid dummy2);
        public uint get_credentials_generation ();
	}

	[CCode (cprefix = "GOA_PROVIDER_FEATURE_")]
	[Flags]
	public enum ProviderFeatures {
        BRANDED,
        MAIL,
        CALENDAR,
        CONTACTS,
        CHAT,
        DOCUMENTS,
        PHOTOS,
        FILES,
        TICKETING,
        READ_LATER,
        PRINTERS,
        MAPS,
        MUSIC,
  }
}