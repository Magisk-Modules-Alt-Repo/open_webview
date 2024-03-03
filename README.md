# Open WebView - [XDA Thread](https://xdaforums.com/t/magisk-module-webview-open-webview-2-3-0.4496119/)

![Open WebView](https://raw.githubusercontent.com/Magisk-Modules-Alt-Repo/open_webview/master/img/logo.png)

This module helps you to replace your system webview though Magisk.

>~~**ATTENTION!** There is a bug that still needs to be fixed where sometimes you may find that the installed webview doesn't work. To fix this bug you need to manually install the webview, to do this just:~~
> - ~~download from sources the latest version of the webview you have choosen during module installation~~
> - ~~install it~~

## DISCLAIMER

Before flash module, please read below:
>I AM NOT RESPONSIBLE IF YOUR DEVICE DOES NOT WORK PROPERLY. BEFORE FLASHING THE MODULE, PLEASE READ THE CODE. YOU WHO DECIDE TO INSTALL THIS MODULE ASSUME ALL RESPONSIBILITY FOR ANY PROBLEMS.

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

- Works on any device running Android 8.0+ and Magisk 20.4+
- Replace the webview with one of:
    1. ~~[Bromite WebView](https://github.com/bromite/bromite)~~ [Deprecated]
    2. [Mulch](https://gitlab.com/divested-mobile/mulch)
    3. [Vanadium](https://gitlab.com/grapheneos/platform_external_vanadium)
    4. [Thorium](https://github.com/Alex313031/Thorium-Android)

## Compile

- Clone the repository
- Run the script: `./create-module.sh`

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

# v2.3.1

- KernelSU compatibility (Shell must have SuperUser enabled). Thanks to [@amteza](https://github.com/amteza)
- Bug fix

# v2.3.0

- Remove Bromite webview
- Re-add overlay inside module
- Add Android 14 support for Vanadium

# v2.2.0

- Add Vanadium webview
- Add SHA256 integrity check for Mulch
- Get always last release of bromite
- Bug fix

# v2.1.0

- Add Mulch webview
- Add status in the module description
- Update bromite to v108.0.5359.156
- Bug fix

# v2.0.0

- Reworked the installation logic
- Add cleaning logic for dalvik cache
- Update bromite to v106.0.5249.163
- Bug fix

# v1.1.0

- Add curl binary
- Bug fix

# v1.0.1

- Bug fix

# v1.0.0

- Initial release
