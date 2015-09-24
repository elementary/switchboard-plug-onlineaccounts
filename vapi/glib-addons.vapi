[CCode (cprefix = "G", lower_case_cprefix = "g_", cheader_filename = "glib.h", gir_namespace = "GLib", gir_version = "2.0")]
namespace GLib {
	namespace Environment {
#if !VALA_0_30
		[CCode (cname = "g_get_user_runtime_dir")]
		public static unowned string get_user_runtime_dir ();
#endif
	}
}
