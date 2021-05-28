namespace E {
	[CCode (cheader_filename = "libedataserver/libedataserver.h", cname = "e_webdav_discover_free_discovered_sources")]
	[Version (since = "3.18")]
	public static void webdav_discover_do_free_discovered_sources (owned GLib.SList<E.WebDAVDiscoveredSource?> discovered_sources);
		[CCode (cname = "e_webdav_discover_sources")]
		[Version (since = "3.18")]
		public async bool webdav_discover_sources (E.Source source, string? url_use_path, uint32 only_supports, E.NamedParameters? credentials, GLib.Cancellable? cancellable, out string out_certificate_pem, out GLib.TlsCertificateFlags out_certificate_errors, out GLib.SList<E.WebDAVDiscoveredSource> out_discovered_sources, out GLib.SList<string> out_calendar_user_addresses) throws GLib.Error;
    [CCode (cname = "e_webdav_discover_sources_finish")]
    bool webdav_discover_sources_finish (E.Source source, GLib.AsyncResult result, out string out_certificate_pem, out GLib.TlsCertificateFlags out_certificate_errors, out GLib.SList<E.WebDAVDiscoveredSource?> out_discovered_sources, out GLib.SList<string> out_calendar_user_addresses) throws GLib.Error;
}
