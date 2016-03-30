# titanium
Titanium modules for iOS and Android

# Building
#### Android
The Android module builds with `ant`. To build:
* Run `ant` from within the `android` folder
* Outputs a ZIP located at `android/dist/com.localytics-android-X.X.X.zip`
* Extract the contents of this ZIP and drop the `modules` folder into your Titanium app project

#### iOS
The iOS modules builds with Python and a `build.py` file:
* Run `python build.py` from within the `iphone` folder
* Outputs a ZIP to the current directory: `com.localytics-iphone-X.X.X.zip`
* Extract the contents of this ZIP and drop the `modules` folder into your Titanium app project
