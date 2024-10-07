[![badge_flutter]][link_flutter_release]
[![badge_linter]][dependency_flutter_lints]

# epack_connect_manager
**Goal**: A Flutter project to manage epack connect.

## Requirements
* Computer (Windows, Mac or Linux)
* Android Studio

## Setup the project in Android studio
1. Download the project code, preferably using `git clone git@github.com:YannMancel/epack_connect_manager.git`.
2. In Android Studio, select *File* | *Open...*
3. Select the project

## Change the minSdk/minSdkVersion for Android
The application is compatible only from version 21 of Android SDK so you should change this in `android/app/build.gradle`:
```xml
    Android {
        defaultConfig {
            minSdk = 21 # or minSdkVersion: 21
```

## Permissions
* Location
* Bluetooth

## Dependencies
* Flutter Version Management
    * [fvm][dependency_fvm]
* Linter
    * [flutter_lints][dependency_flutter_lints]
* Bluetooth Low Energy
    * [bluetooth_low_energy][dependency_bluetooth_low_energy]

## Troubleshooting

### No device available during the compilation and execution steps
* If none of device is present (*Available Virtual Devices* or *Connected Devices*),
    * Either select `Create a new virtual device`
    * or connect and select your phone or tablet

## Useful
* [Download Android Studio][useful_android_studio]
* [Create a new virtual device][useful_virtual_device]
* [Enable developer options and debugging][useful_developer_options]

[badge_flutter]: https://img.shields.io/badge/flutter-v3.24.1-blue?logo=flutter
[badge_linter]: https://img.shields.io/badge/style-flutter__lints-4BC0F5.svg
[link_flutter_release]: https://docs.flutter.dev/development/tools/sdk/releases
[dependency_fvm]: https://fvm.app/
[dependency_flutter_lints]: https://pub.dev/packages/flutter_lints
[dependency_bluetooth_low_energy]: https://pub.dev/packages/bluetooth_low_energy
[useful_android_studio]: https://developer.android.com/studio
[useful_virtual_device]: https://developer.android.com/studio/run/managing-avds.html
[useful_developer_options]: https://developer.android.com/studio/debug/dev-options.html#enable
