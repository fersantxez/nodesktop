// Native arm64 compatibility profile. Official Tor Browser is used on amd64.
user_pref("browser.privatebrowsing.autostart", true);
user_pref("media.peerconnection.enabled", false);
user_pref("network.proxy.no_proxies_on", "");
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.proxy.socks_version", 5);
user_pref("network.proxy.type", 1);
user_pref("privacy.firstparty.isolate", true);
user_pref("privacy.resistFingerprinting", true);
user_pref("webgl.disabled", true);
