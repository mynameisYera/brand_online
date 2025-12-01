'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "e3f8a49404646afdcef8ec98b95a9bdc",
"version.json": "e8214a9737ab72aae2176a2b9266829b",
"index.html": "be8a0c32fd10f90138af5753e633cf77",
"/": "be8a0c32fd10f90138af5753e633cf77",
"main.dart.js": "905671ed217035d13f898b9b628f83cb",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-192.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-maskable-192.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-maskable-512.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-512.png": "d41d8cd98f00b204e9800998ecf8427e",
"manifest.json": "d8436903ad2c0b358999482aa7948e0c",
"assets/AssetManifest.json": "a7594609c260086993e5eeca71d65397",
"assets/NOTICES": "9638195ccce195acd500005afe2af1d6",
"assets/FontManifest.json": "b726e165c9eb156988b5264e1729355f",
"assets/AssetManifest.bin.json": "3172e2fbf43d234804a55e7221076b94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "a2eb084b706ab40c90610942d98886ec",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/youtube_player_flutter/assets/speedometer.webp": "50448630e948b5b3998ae5a5d112622b",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "c8c5e8bfa2f84c3faaa6dbcb56bd6608",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/images/news.png": "7af1f58888483d3f972c2b4349ddbcb5",
"assets/assets/images/III.png": "948b738e134bd242a2f5ef4cff839b23",
"assets/assets/images/logoTitle2.png": "9383e1adae44a9fea679be1e9bf14a04",
"assets/assets/images/I.png": "49d53185e46a6ef80a8c9c3282ec94f5",
"assets/assets/images/book.png": "1371638184cfc2467300882c49b76643",
"assets/assets/images/subscribe.png": "902bcb66497256b9d17c132bc2357887",
"assets/assets/images/fire1.png": "9bc434501bd8835e0c3fc0682977efed",
"assets/assets/images/maths.png": "b1e52a91323892ea4c76bb4b23e2e63f",
"assets/assets/images/fire.png": "e59ecaeeea98a4497a43902061cf2ecb",
"assets/assets/images/barys.png": "b8c6b3c7d7cf3d84d7428055ea49aae4",
"assets/assets/images/brs4.png": "391c5fe8c040dfadf8b3b2b73769f4b4",
"assets/assets/images/brs5.png": "fd721ce80788f3d925b1527dcd4db935",
"assets/assets/images/clouds.png": "38e0f7b8aab3bd5d97f63996ce64f1af",
"assets/assets/images/barys2.png": "3b1d184c5973e1b540c834304b71ecb8",
"assets/assets/images/baryss.png": "3445f0305f0dcb373a57718c3024766f",
"assets/assets/images/formula.png": "a148e031f9e25287eabbe18ef27d1115",
"assets/assets/images/function.png": "3e97c0e2bc93e5b3403c0244800d8bff",
"assets/assets/images/home.png": "b81631f8b34674e5d1df884d2589a2dd",
"assets/assets/images/brs2.png": "6aac609c31136b9f87dac4ca596ac4d7",
"assets/assets/images/brs3.png": "c7dabcdde6741fc9433a511f8194eff7",
"assets/assets/images/trophy1.png": "ea43f92e19dd19a7228cde78cbf4a07b",
"assets/assets/images/II.png": "ce89eccfe992920ed73165ef0b4050fb",
"assets/assets/images/repeat.png": "fbf82562aeb8038f15160a1b2f6f67ad",
"assets/assets/images/brs1.png": "e7387a6e596f84185c88c4d4ff0b6870",
"assets/assets/images/splash_text.png": "1bda696fc69619c1b465abdd514b67cd",
"assets/assets/images/play_icon.png": "12946e08bee3e76d3a4dd97ba5e7fc23",
"assets/assets/images/users.png": "2408291fce37cf8e98515e1866ca167e",
"assets/assets/images/clouds2.png": "c049d271069479fe08e83b9804700ba3",
"assets/assets/images/logo.png": "6ab378d64b5698d5512b59d32cd56b41",
"assets/assets/images/logo2.png": "0df9fbfa2437d877ae033c51687abe56",
"assets/assets/images/restartLogo.png": "589c03777f0df1424bcbbcaef23de8be",
"assets/assets/images/math_icon.png": "b84fb61b26f624bdf104d68b44de3b58",
"assets/assets/images/robot.png": "09209065b00cd669c51ff11f1f9d4e2f",
"assets/assets/images/play_btn.png": "12946e08bee3e76d3a4dd97ba5e7fc23",
"assets/assets/images/profile.png": "d7c4fbc755cf437ebad04223e632e580",
"assets/assets/images/robot_image.png": "cee12b047e29cf0f8f30ac737b97a645",
"assets/assets/images/mainLogo.png": "8a6e40c346f79d64bad6340c94f89fb3",
"assets/assets/images/star.png": "afafe86bff8954122fc990a0d9d04ce4",
"assets/assets/images/star-sparkle.png": "5cff6ea830e7620745a26c904767989d",
"assets/assets/images/application_logo.png": "3bbbc59eabeb8821e3a34b53c274a346",
"assets/assets/images/play-button.png": "993930c270e22af66c4db1d6fda5e2df",
"assets/assets/images/crown.png": "dd589e8a7f87eebce8a6d6ab3f2a84e4",
"assets/assets/images/splash_logo.PNG": "9280176132dbed7a0096b5ad406af0c4",
"assets/assets/images/logoTitle.png": "5e3ccbb056d4fdb7c6b68273973c4e8d",
"assets/assets/sounds/error.mp3": "427d21471782870d0e74c77c6ac20406",
"assets/assets/sounds/success.mp3": "da3a8badf306bff6d9ed6a3f81ad38f7",
"assets/assets/sounds/wrong-answer2.mp4": "3166892b12cc40929a057e31d7e113ac",
"assets/assets/sounds/wrong-answer.mp3": "6f8ca29ea6af04b8447f2e32574f5a3a",
"assets/assets/sounds/success1.mp3": "101cb57731ef1b12acb04d324c426585",
"assets/assets/fonts/Roboto-Regular.ttf": "303c6d9e16168364d3bc5b7f766cfff4",
"assets/assets/fonts/Roboto-Bold.ttf": "8c9110ec6a1737b15a5611dc810b0f92",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
