[CCode (cprefix = "G", lower_case_cprefix = "g_", cheader_filename = "glib.h", gir_namespace = "GLib", gir_version = "2.0")]
namespace GLib {
	
	namespace Environment {
		[CCode (cname = "g_get_user_runtime_dir")]
		public static unowned string get_user_runtime_dir ();
		[CCode (cname = "tempnam")]
		public void tempnam (string dir, string prefix);
	}
}