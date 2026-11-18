# Android releases

After building an Android version for the user, publish the verified ARM64 APK to
GitHub Releases in deforxdev/voloball. Use the v<version>-android tag and the
VOLOBALL-Android-<version>-ARM64.apk asset name expected by the in-game updater.
Use the same signing certificate as the preceding Android build, and verify that
the public release lists the asset before reporting completion. Use
tools/publish_android_release.py with authorized GitHub credentials.
