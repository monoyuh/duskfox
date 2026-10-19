// ============================================================================
//  Duskfox default preferences
//  Appended to browser/app/profile/firefox.js, so these are the last defaults
//  set and therefore always win.
//  Philosophy: MAX SPEED, low RAM, zero bloat, no adblocking, security expendable.
// ============================================================================

// ============================================================================
//  SPEED :: rendering / paint / layout
// ============================================================================
pref("nglayout.initialpaint.delay", 0);
pref("nglayout.initialpaint.delay_in_oopif", 0);
pref("content.notify.interval", 100000);
pref("content.notify.ontimer", true);
pref("content.notify.backoffcount", 5);
pref("content.max.tokenizing.time", 2250000);
pref("layout.frame_rate", 0);
pref("gfx.frame_rate", 0);

// ============================================================================
//  SPEED :: process model  (4 cores -> cap processes, low RAM, no lost perf)
// ============================================================================
pref("dom.ipc.processCount", 4);
pref("dom.ipc.processCount.file", 1);
pref("dom.ipc.processCount.extension", 1);
pref("dom.ipc.processCount.webIsolated", 4);
pref("browser.tabs.remote.warmup.enabled", false);

// ============================================================================
//  SPEED :: JavaScript engine
// ============================================================================
pref("javascript.options.baselinejit.threshold", 50);
pref("javascript.options.wasm_optimizingjit", true);
pref("javascript.options.wasm_simd", true);
pref("javascript.options.wasm_relaxed_simd", true);

// ============================================================================
//  SPEED :: caches
// ============================================================================
pref("browser.cache.disk.enable", true);
pref("browser.cache.disk.smart_size.enabled", false);
pref("browser.cache.disk.capacity", 1048576);
pref("browser.cache.memory.enable", true);
pref("browser.cache.memory.capacity", 131072);
pref("browser.sessionstore.interval", 60000);

// ============================================================================
//  SPEED :: network
// ============================================================================
pref("network.http.max-connections", 900);
pref("network.http.max-persistent-connections-per-server", 10);
pref("network.http.max-persistent-connections-per-proxy", 32);
pref("network.http.max-urgent-start-excessive-connections-per-host", 10);
pref("network.http.http3.enable", true);
pref("network.http.speculative-parallel-limit", 10);
pref("network.dns.disablePrefetch", false);
pref("network.prefetch-next", true);
pref("network.predictor.enabled", true);
pref("network.predictor.enable-prefetch", true);
pref("network.buffer.cache.size", 262144);
pref("network.buffer.cache.count", 48);
pref("network.websocket.max-connections", 400);
pref("browser.urlbar.speculativeConnect.enabled", true);
pref("browser.places.speculativeConnect.enabled", true);

// ============================================================================
//  SPEED :: GPU / media hardware decode
// ============================================================================
pref("gfx.webrender.all", true);
pref("gfx.canvas.accelerated", true);
pref("layers.acceleration.force-enabled", true);
pref("gfx.webrender.software", false);
pref("media.ffmpeg.vaapi.enabled", true);
pref("media.hardware-video-decoding.force-enabled", true);
pref("widget.dmabuf.force-enabled", true);
pref("image.mem.max_decoded_image_kb", 131072);
pref("media.memory_cache_max_size", 65536);

// ---------------------------------------------------------------------------
//  VIDEO :: force H.264 so the GPU hardware-decodes YouTube 1080p60
//  The RX 480 (Polaris) has no VP9/AV1 decode block, so hiding those formats
//  makes YouTube serve avc1 (itag 299), which VAAPI decodes for ~free.
//  Tradeoff: VP9/WebM <video> on other sites will not play.
//  Flip back at runtime in about:config if you want them.
// ---------------------------------------------------------------------------
pref("media.webm.enabled", false);
pref("media.av1.enabled", false);

// ============================================================================
//  SPEED :: UI snappiness (kill animations)
// ============================================================================
pref("browser.tabs.animate", false);
pref("browser.fullscreen.animate", false);
pref("toolkit.cosmeticAnimations.enabled", false);
pref("ui.prefersReducedMotion", 1);
pref("browser.download.animateNotifications", false);

// ============================================================================
//  SPEED > SECURITY :: no safe browsing, no OCSP, no tracker blocking,
//  no fingerprint resistance, no cookie partitioning, no DoH overhead
// ============================================================================
pref("browser.safebrowsing.malware.enabled", false);
pref("browser.safebrowsing.phishing.enabled", false);
pref("browser.safebrowsing.downloads.enabled", false);
pref("browser.safebrowsing.downloads.remote.enabled", false);
pref("browser.safebrowsing.blockedURIs.enabled", false);
pref("browser.safebrowsing.provider.google.updateURL", "");
pref("browser.safebrowsing.provider.google.gethashURL", "");
pref("browser.safebrowsing.provider.google4.updateURL", "");
pref("browser.safebrowsing.provider.google4.gethashURL", "");
pref("security.OCSP.enabled", 0);
pref("security.OCSP.require", false);
pref("security.cert_pinning.enforcement_level", 0);
pref("security.pki.crlite_mode", 0);
pref("security.remote_settings.crlite_filters.enabled", false);
pref("security.remote_settings.intermediates.enabled", false);
pref("network.stricttransportsecurity.preloadlist", false);
pref("privacy.trackingprotection.enabled", false);
pref("privacy.trackingprotection.pbmode.enabled", false);
pref("privacy.trackingprotection.emailtracking.enabled", false);
pref("privacy.trackingprotection.socialtracking.enabled", false);
pref("privacy.trackingprotection.cryptomining.enabled", false);
pref("privacy.trackingprotection.fingerprinting.enabled", false);
pref("browser.contentblocking.category", "standard");
pref("network.cookie.cookieBehavior", 0);
pref("privacy.partition.network_state", false);
pref("privacy.resistFingerprinting", false);
pref("privacy.globalprivacycontrol.enabled", false);
pref("dom.security.https_only_mode", false);
pref("dom.security.https_only_mode_pbm", false);
pref("dom.security.https_only_mode.upgrade_local", false);
pref("network.trr.mode", 5);
pref("security.tls.enable_0rtt_data", true);
pref("browser.xul.error_pages.expert_bad_cert", true);

// ============================================================================
//  RAM :: keep it lean
// ============================================================================
pref("browser.tabs.unloadOnLowMemory", true);
pref("browser.sessionstore.max_tabs_undo", 10);
pref("browser.sessionstore.max_windows_undo", 2);

// ============================================================================
//  BLOAT :: telemetry / reporting / studies  (all off)
// ============================================================================
pref("toolkit.telemetry.unified", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.server", "data:,");
pref("toolkit.telemetry.archive.enabled", false);
pref("toolkit.telemetry.newProfilePing.enabled", false);
pref("toolkit.telemetry.updatePing.enabled", false);
pref("toolkit.telemetry.firstShutdownPing.enabled", false);
pref("toolkit.telemetry.shutdownPingSender.enabled", false);
pref("toolkit.telemetry.bhrPing.enabled", false);
pref("toolkit.telemetry.cachedClientID", "");
pref("toolkit.telemetry.previousBuildID", "");
pref("toolkit.telemetry.dap_enabled", false);
pref("toolkit.coverage.opt-out", true);
pref("toolkit.coverage.enabled", false);
pref("toolkit.coverage.endpoint.base", "");
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
pref("browser.ping-centre.telemetry", false);
pref("app.normandy.enabled", false);
pref("app.normandy.api_url", "");
pref("app.shield.optoutstudies.enabled", false);
pref("browser.discovery.enabled", false);
pref("security.protectionspopup.recordEventTelemetry", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
pref("browser.newtabpage.activity-stream.telemetry", false);
pref("browser.pagethumbnails.capturing_disabled", true);

// ============================================================================
//  BLOAT :: Pocket / sponsored content / Firefox Suggest / AI / Shopping
// ============================================================================
pref("extensions.pocket.enabled", false);
pref("extensions.pocket.site", "");
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
pref("browser.newtabpage.activity-stream.feeds.system.showSponsored", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("browser.newtabpage.activity-stream.feeds.system.topstories", false);
pref("browser.newtabpage.activity-stream.feeds.snippets", false);
pref("browser.newtabpage.activity-stream.feeds.recommendationprovider", false);
pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false);
pref("browser.newtabpage.activity-stream.discoverystream.enabled", false);
pref("browser.newtabpage.activity-stream.feeds.topsites", false);
pref("browser.newtabpage.activity-stream.default.sites", "");
pref("browser.newtabpage.activity-stream.showWeather", false);
pref("browser.topsites.contile.enabled", false);
pref("browser.urlbar.quicksuggest.enabled", false);
pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
pref("browser.urlbar.suggest.trending", false);
pref("browser.urlbar.suggest.weather", false);
pref("browser.urlbar.suggest.recentsearches", false);
pref("browser.shopping.experience2023.enabled", false);
pref("browser.shopping.experience2023.optedIn", 2);
pref("browser.ml.enable", false);
pref("browser.ml.chat.enabled", false);
pref("browser.ml.chat.menu", false);
pref("browser.ml.chat.page", false);
pref("browser.ml.linkPreview.enabled", false);
pref("browser.tabs.groups.smart.enabled", false);
pref("browser.preferences.moreFromMozilla", false);
pref("browser.messaging-system.whatsNewPanel.enabled", false);

// ============================================================================
//  BLOAT :: first-run / welcome / default browser / region / connectivity
// ============================================================================
pref("browser.startup.homepage_override.mstone", "ignore");
pref("browser.aboutwelcome.enabled", false);
pref("browser.startup.homepage_welcome_url", "");
pref("browser.startup.homepage_welcome_url.additional", "");
pref("startup.homepage_override_url", "");
pref("browser.shell.checkDefaultBrowser", false);
pref("browser.region.network.url", "");
pref("browser.region.update.enabled", false);
pref("browser.search.update", false);
pref("network.captive-portal-service.enabled", false);
pref("network.connectivity-service.enabled", false);
pref("geo.enabled", false);
pref("beacon.enabled", false);
pref("browser.aboutConfig.showWarning", false);

// ============================================================================
//  UI :: NATIVE VERTICAL TABS  (no extension)
// ============================================================================
pref("sidebar.revamp", true);
pref("sidebar.verticalTabs", true);

// ============================================================================
//  STARTUP :: blank + instant
// ============================================================================
pref("browser.startup.page", 1);
pref("browser.startup.homepage", "about:blank");
pref("browser.newtabpage.enabled", true);
pref("browser.newtab.preload", false);
pref("browser.startup.preXulSkeletonUI", false);

// ============================================================================
//  UPDATER :: none exists in this build anyway
// ============================================================================
pref("app.update.enabled", false);
pref("app.update.auto", false);
pref("app.update.background.scheduling.enabled", false);
