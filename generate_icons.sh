#!/bin/bash

# Script to generate app icons from app_icon.png
# Uses macOS sips command to resize images

SOURCE_ICON="assets/images/app_icon.png"
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_DIR="android/app/src/main/res"

echo "Generating iOS icons..."

# iOS icons
mkdir -p "$IOS_DIR"

# 1024x1024 (App Store)
sips -z 1024 1024 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-1024x1024@1x.png"

# 20x20
sips -z 20 20 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-20x20@1x.png"
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-20x20@2x.png"
sips -z 60 60 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-20x20@3x.png"

# 29x29
sips -z 29 29 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-29x29@1x.png"
sips -z 58 58 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-29x29@2x.png"
sips -z 87 87 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-29x29@3x.png"

# 40x40
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-40x40@1x.png"
sips -z 80 80 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-40x40@2x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-40x40@3x.png"

# 60x60
sips -z 120 120 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-60x60@2x.png"
sips -z 180 180 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-60x60@3x.png"

# 76x76
sips -z 76 76 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-76x76@1x.png"
sips -z 152 152 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-76x76@2x.png"

# 83.5x83.5
sips -z 167 167 "$SOURCE_ICON" --out "$IOS_DIR/Icon-App-83.5x83.5@2x.png"

echo "Generating Android icons..."

# Android icons
mkdir -p "$ANDROID_DIR/mipmap-mdpi"
mkdir -p "$ANDROID_DIR/mipmap-hdpi"
mkdir -p "$ANDROID_DIR/mipmap-xhdpi"
mkdir -p "$ANDROID_DIR/mipmap-xxhdpi"
mkdir -p "$ANDROID_DIR/mipmap-xxxhdpi"

# mdpi: 48x48
sips -z 48 48 "$SOURCE_ICON" --out "$ANDROID_DIR/mipmap-mdpi/ic_launcher.png"

# hdpi: 72x72
sips -z 72 72 "$SOURCE_ICON" --out "$ANDROID_DIR/mipmap-hdpi/ic_launcher.png"

# xhdpi: 96x96
sips -z 96 96 "$SOURCE_ICON" --out "$ANDROID_DIR/mipmap-xhdpi/ic_launcher.png"

# xxhdpi: 144x144
sips -z 144 144 "$SOURCE_ICON" --out "$ANDROID_DIR/mipmap-xxhdpi/ic_launcher.png"

# xxxhdpi: 192x192
sips -z 192 192 "$SOURCE_ICON" --out "$ANDROID_DIR/mipmap-xxxhdpi/ic_launcher.png"

echo "Icons generated successfully!"
echo "Now rebuild your app: flutter clean && flutter run"

