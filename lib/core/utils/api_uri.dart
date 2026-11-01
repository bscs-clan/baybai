Uri apiUri(String configuredHost, String path) {
  configuredHost = configuredHost.trim();
  final host = RegExp(r"^[a-zA-Z][a-zA-Z0-9+.-]*://").hasMatch(configuredHost)
      ? configuredHost
      : "http://$configuredHost";
  return Uri.parse(host).resolve(path);
}
