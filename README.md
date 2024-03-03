# Open WebView - [XDA Thread](https://xdaforums.com/t/magisk-module-webview-open-webview.4496119/)

![Open WebView](https://raw.githubusercontent.com/Magisk-Modules-Alt-Repo/open_webview/master/img/logo.png)

This module helps you to replace your system webview though Magisk.

## NOTICE
> I don't have so much time to devote to this hobby, this is not my main job. If you appreciate my work please let me know with a star on github, or a feedback, or a PR to improve the code or a donation, thank you!

>~~**ATTENTION!** There is a bug that still needs to be fixed where sometimes you may find that the installed webview doesn't work. To fix this bug you need to manually install the webview, to do this just:~~
> - ~~download from sources the latest version of the webview you have choosen during module installation~~
> - ~~install it~~

## DISCLAIMER

>I AM NOT RESPONSIBLE IF YOUR DEVICE DOES NOT WORK PROPERLY OR FOR ANY DAMAGE THAT MAY OCCUR TO YOUR DEVICE. BEFORE USING THIS MODULE, PLEASE READ THE CODE. YOU WHO DECIDE TO INSTALL THIS MODULE ASSUMES ALL RESPONSIBILITY FOR ANY PROBLEMS.

## Compatibility

- Android 8+
- Magisk 20.4+
- KernelSU 0.6+

## Tested Device

- [LOS 19](https://lineageos.org/)
- [LOS 20](https://lineageos.org/)
- [crDroid 10.x](https://crdroid.net/)
- And more...

## Support

If you found this helpful, please consider supporting development with a [coffe](https://www.paypal.me/f3ff0). Alternatively, you can contribute to the project by reporting bugs and doing PR. All support is appreciated!

## Features

**ATTENTION!** This module cannot automatically update the webview, so if you want to update a webview installed through this module you must manually reinstall the module.

- Works on any device running Android 8.0+ and Magisk 20.4+
- Replace the webview with one of:
    1. ~~[Bromite WebView](https://github.com/bromite/bromite)~~ [Deprecated]
    2. [Mulch](https://gitlab.com/divested-mobile/mulch)
    3. [Vanadium](https://gitlab.com/grapheneos/platform_external_vanadium)
    4. [Thorium](https://github.com/Alex313031/Thorium-Android)

## Create module

1. Clone the repository
2. Run the script according to the OS:
   - Unix/Linux: `./create-module.sh`
   - Windows: `./create-module.ps1`

## Credits

- [MMT-Extended](https://github.com/Zackptg5/MMT-Extended) by [Zackptg5](https://github.com/Zackptg5)
- ~~[Bromite](https://github.com/bromite/bromite)~~
- [GrapheneOS](https://grapheneos.org/)
- [DivestOS](https://gitlab.com/divested-mobile)
- [Thorium by Alex313031](https://github.com/Alex313031/thorium)
- [cUrl](https://github.com/curl/curl)
- [cUrl binary](https://github.com/F3FFO/compile_zlib_openssl_curl_android)
- [Zipsigner](https://github.com/Magisk-Modules-Repo/zipsigner) by [osm0sis](https://github.com/osm0sis)

## License

Copyright 2024 F3FFO

The source code is available under [GPL-3.0](https://github.com/Magisk-Modules-Alt-Repo/open_fonts/blob/master/LICENSE)

## Change logs

# v2.4.0

- Welcome to Thorium webview
- Mark as **experimental** Vanadium and Thorium
- Add manual installation of Mulch webview
- No need anymore to download thrichrome lib
- Prevent to perform user installation of webview
- Bug fix

See older release notes: [CHANGELOG.md](CHANGELOG.md)
