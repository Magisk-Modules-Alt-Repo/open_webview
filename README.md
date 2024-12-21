# Open WebView - [XDA Thread](https://xdaforums.com/t/magisk-module-webview-open-webview.4496119/)

![Open WebView](https://raw.githubusercontent.com/Magisk-Modules-Alt-Repo/open_webview/master/img/logo.png)

This module helps you to replace your system webview though Magisk.

## NOTICE
> This for me is just a hobby that I do when I have some free time (very little). If you appreciate my work please let me know, thank you!

>~~**ATTENTION!** There is a bug that still needs to be fixed where sometimes you may find that the installed webview doesn't work. To fix this bug you need to manually install the webview, to do this just:~~
> - ~~download from sources the latest version of the webview you have choosen during module installation~~
> - ~~install it~~

## DISCLAIMER

>I AM NOT RESPONSIBLE IF YOUR DEVICE DOES NOT WORK PROPERLY OR FOR ANY DAMAGE THAT MAY OCCUR TO YOUR DEVICE. BEFORE USING THIS MODULE, PLEASE READ THE CODE. YOU WHO DECIDE TO INSTALL THIS MODULE ASSUMES ALL RESPONSIBILITY FOR ANY PROBLEMS.

## Compatibility

- S.O.
    - minimum: Android 8+
    - suggested: Android 13+
- Magisk 20.4+
- KernelSU 0.6+

## Tested Device ROM

- [LOS 19, LOS 20, LOS 21](https://lineageos.org/)
- [crDroid 10.x](https://crdroid.net/)
- And more...

## Support

If you find this project useful, please consider [supporting](https://www.paypal.me/f3ff0) the developer's mental health :)
Alternatively, you can contribute directly to the project. All support is appreciated!

## Features

**ATTENTION!** This module cannot automatically update the webview, so if you want to update a webview installed through this module you must manually reinstall the module.

- Works on any device running Android 8.0+ and Magisk 20.4+
- Replace the webview with one of:
    1. ~~[Bromite](https://github.com/bromite/bromite)~~ (Deprecated)
    2. [Mulch](https://gitlab.com/divested-mobile/mulch)
    3. [Vanadium](https://gitlab.com/grapheneos/platform_external_vanadium)
    4. ~~[Thorium](https://github.com/Alex313031/Thorium-Android)~~ (Deprecated)
    5. [Cromite](https://github.com/uazo/cromite)

### Why did I deprecate webview?

In general because I no longer consider it adequate to my standard:
- security reason
- no more update for too long
- no longer supported

In my opinion a webview is a very important part of the system and I don't want to make the system vulnerable with an outdate webview

- **Bromite** -> last update in 12/2022 (**Bromite**'s successor is **Cromite**)
- **Thorium** -> I don't like the update policy, too long between two update

## Create module

1. Clone the repository
2. Run the script according to the OS:
   - Unix/Linux: `./create-module.sh`
   - Windows: `./create-module.ps1`

## Credits

- [Magisk by topjohnwu](https://github.com/topjohnwu/Magisk)
- [MMT-Extended by Zackptg5](https://github.com/Zackptg5/MMT-Extended)
- [Bromite](https://github.com/bromite/bromite)
- [Vanadium by GrapheneOS](https://gitlab.com/grapheneos/platform_external_vanadium)
- [Mulch by DivestOS](https://gitlab.com/divested-mobile/mulch)
- [Thorium by Alex313031](https://github.com/Alex313031/thorium)
- [cUrl](https://github.com/curl/curl)
- [cUrl binary](https://github.com/F3FFO/compile_zlib_openssl_curl_android)
- [Zipsigner by osm0sis](https://github.com/Magisk-Modules-Repo/zipsigner)
- [Cromite by uazo](https://github.com/uazo/cromite)
- [AAPT2 binaries](https://github.com/skittles9823/QuickSwitch)
- [WebViewChanger](https://github.com/Lordify95/WebViewChanger)

## License

Copyright 2024 F3FFO

The source code is available under [GPL-3.0](https://github.com/Magisk-Modules-Alt-Repo/open_fonts/blob/master/LICENSE)

## Change logs

# v2.5.2 (see 2.5.0 changelog for more)

- Prevent post-fs logic if Cromite is choosen as webview

See older release notes: [CHANGELOG.md](CHANGELOG.md)
