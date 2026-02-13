# App Store / TestFlight Release Preparation Guide

This document outlines the steps needed to prepare Remote ZFS Unlock for release on the Apple App Store and TestFlight.

## ✅ Completed Automatically

The following items have been configured in this repository:

1. **iOS Info.plist Updates**
   - Added `NSLocalNetworkUsageDescription` for SSH network access
   - Added `ITSAppUsesNonExemptEncryption` declaration (set to `false` - standard SSH encryption)

2. **macOS Entitlements**
   - Added `com.apple.security.network.client` for outbound SSH connections
   - Added `com.apple.security.files.user-selected.read-only` for keyfile imports

3. **Privacy Policy**
   - Created `PRIVACY_POLICY.md` document
   - Available in repository for reference and linking in App Store listing

4. **App Icons**
   - iOS app icons are present (all required sizes)
   - macOS app icons are present (all required sizes)

## 🔧 Manual Steps Required

### 1. Apple Developer Account Setup

- [ ] Enroll in Apple Developer Program ($99/year)
  - Visit: https://developer.apple.com/programs/
  - Required for App Store and TestFlight distribution

### 2. App Store Connect Configuration

- [ ] Create App Record in App Store Connect
  - Go to: https://appstoreconnect.apple.com
  - Click "My Apps" → "+" → "New App"
  - Platform: iOS and/or macOS
  - Bundle ID: `dev.getboolean.remoteZfsUnlock` (already configured in Xcode)
  - SKU: Choose unique identifier (e.g., `remote-zfs-unlock`)
  - User Access: Full Access

### 3. App Information

- [ ] **App Name:** "Remote ZFS Unlock"
- [ ] **Subtitle:** (Optional, max 30 characters) e.g., "Manage ZFS over SSH"
- [ ] **Privacy Policy URL:** Host `PRIVACY_POLICY.md` somewhere public or convert to webpage
  - Options:
    - GitHub Pages: https://getboolean.github.io/remote_zfs_unlock/PRIVACY_POLICY
    - Use GitHub raw URL
    - Host on your own domain
- [ ] **Category:**
  - Primary: Developer Tools or Utilities
  - Secondary: (Optional)

### 4. App Description

Use or adapt this description for the App Store:

```
Remote ZFS Unlock lets you manage ZFS datasets on remote servers directly from your iOS or macOS device.

FEATURES
• Connect to remote servers via SSH
• List ZFS datasets
• Unlock encrypted datasets with passphrase or keyfile
• Lock encrypted datasets
• Create new encrypted datasets
• Support for password and key-based SSH authentication

REQUIREMENTS
• Remote server with ZFS installed
• SSH access to remote server
• User must have permissions to run zfs commands

SECURITY
• Credentials stored in device Keychain
• Direct SSH connection to your server
• No data sent to third parties
• Dataset keys never persisted to disk

OPEN SOURCE
This app is open source and available on GitHub.
```

### 5. Screenshots

- [ ] **iOS Screenshots** (Required for each device size you support):
  - 6.7" Display (iPhone 14 Pro Max, etc.) - At least 1, up to 10
  - 6.5" Display (iPhone 11 Pro Max, etc.) - At least 1, up to 10
  - 5.5" Display (iPhone 8 Plus, etc.) - At least 1, up to 10
  - 12.9" Display (iPad Pro 12.9", etc.) - At least 1, up to 10

- [ ] **macOS Screenshots** (If releasing on macOS):
  - At least 1, up to 10 screenshots

**Tips for Screenshots:**
- Show main UI with server list
- Show SSH connection dialog
- Show dataset list
- Show unlock/lock functionality
- Use consistent, professional appearance
- Consider adding descriptive captions

### 6. App Review Information

- [ ] **Sign-In Information** (If app requires authentication):
  - Note: This app doesn't require app-level authentication
  - However, reviewers need to test SSH functionality
  - Options:
    1. Provide demo server credentials in review notes
    2. Provide detailed instructions for reviewers to set up their own test environment
    3. Include demo mode or mock data for reviewers

- [ ] **Contact Information:**
  - First Name, Last Name
  - Phone Number
  - Email Address

- [ ] **Demo Account or Instructions:**
  Since this app requires a ZFS server, provide either:
  ```
  Option A - Demo Server:
  Hostname: [demo server]
  Port: 22
  Username: [demo user]
  Password/Key: [credentials]
  
  Option B - Testing Instructions:
  This app requires a ZFS-enabled server. For testing:
  1. Use a local VM or test server with ZFS
  2. Create test datasets: zpool create testpool /path/to/disk
  3. Test with provided credentials in the app
  
  We can provide a temporary demo server for review upon request.
  ```

### 7. Pricing and Availability

- [ ] **Price:** Free (or select price tier)
- [ ] **Availability:** Select countries/regions
- [ ] **Pre-Orders:** Optional

### 8. Code Signing & Provisioning

- [ ] Create App ID in Apple Developer Portal
  - Bundle ID: `dev.getboolean.remoteZfsUnlock`
  - Enable capabilities: None required (network and file access are handled by entitlements)

- [ ] Create Provisioning Profiles:
  - Development profile (for testing)
  - App Store profile (for distribution)

- [ ] Configure Xcode Project:
  - Open `ios/Runner.xcworkspace` (for iOS) or `macos/Runner.xcworkspace` (for macOS)
  - Select Runner target → Signing & Capabilities
  - Choose your team
  - Select provisioning profile
  - Ensure Bundle Identifier matches: `dev.getboolean.remoteZfsUnlock`

### 9. Build and Submit

#### For iOS:

```bash
# Clean and build release
flutter clean
flutter pub get
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device (arm64)" or a connected device
# 2. Product → Archive
# 3. When archive completes, click "Distribute App"
# 4. Select "App Store Connect"
# 5. Follow wizard to upload to App Store Connect
```

#### For macOS:

```bash
# Clean and build release
flutter clean
flutter pub get
flutter build macos --release

# Open Xcode
open macos/Runner.xcworkspace

# In Xcode:
# 1. Product → Archive
# 2. When archive completes, click "Distribute App"
# 3. Select "App Store Connect"
# 4. Follow wizard to upload to App Store Connect
```

### 10. TestFlight (Optional but Recommended)

- [ ] Enable TestFlight testing in App Store Connect
- [ ] Add internal testers (your team)
- [ ] Add external testers (beta users)
- [ ] Provide "What to Test" notes for each build
- [ ] Collect and address feedback before full release

### 11. Export Compliance

The app uses SSH encryption, which is standard encryption. In most cases:

- [ ] In App Store Connect, you'll be asked: "Does your app use encryption?"
  - Answer: **Yes**
- [ ] Next question: "Does your app qualify for any of the exemptions provided in Category 5, Part 2 of the U.S. Export Administration Regulations?"
  - Answer: **Yes** (if using standard SSH libraries without custom encryption)
- [ ] The app uses standard encryption (SSH protocol) and should qualify for exemption

**Note:** `ITSAppUsesNonExemptEncryption` is already set to `false` in Info.plist, indicating the app uses standard encryption.

### 12. App Review Submission

- [ ] Fill in all required metadata
- [ ] Upload screenshots
- [ ] Set pricing and availability
- [ ] Add release notes (what's new in this version)
- [ ] Choose manual or automatic release after approval
- [ ] Submit for Review

**Expected Timeline:**
- First review: 1-3 days (can be longer)
- Updates: Usually 1-2 days

### 13. Post-Release

- [ ] Monitor user reviews
- [ ] Respond to user feedback
- [ ] Plan for updates and maintenance
- [ ] Keep privacy policy updated

## 📋 Pre-Submission Checklist

Before submitting, verify:

- [ ] App builds successfully in Release mode
- [ ] All features work on physical devices (not just simulator)
- [ ] No crashes or obvious bugs
- [ ] UI is polished and consistent
- [ ] All text is clear and properly formatted
- [ ] App performance is acceptable
- [ ] Privacy policy is accessible
- [ ] Demo credentials work (if providing demo server)
- [ ] SSH connections work correctly
- [ ] File picker works for keyfiles
- [ ] All entitlements are correctly configured

## 📚 Additional Resources

- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help:** https://help.apple.com/app-store-connect/
- **Human Interface Guidelines (iOS):** https://developer.apple.com/design/human-interface-guidelines/ios
- **Human Interface Guidelines (macOS):** https://developer.apple.com/design/human-interface-guidelines/macos
- **TestFlight Documentation:** https://developer.apple.com/testflight/

## ⚠️ Common Rejection Reasons to Avoid

1. **Incomplete App Information:** Ensure all metadata fields are complete
2. **Poor App Quality:** Test thoroughly before submission
3. **Privacy Policy Issues:** Ensure privacy policy URL is accessible
4. **Demo Account Issues:** Provide working credentials or clear instructions
5. **Crashes:** Test on multiple devices and iOS/macOS versions
6. **Misleading Description:** Ensure description matches app functionality
7. **Incomplete Features:** All advertised features must work

## 🔄 Version Updates

For future updates:

1. Update version in `pubspec.yaml` (e.g., `1.1.0+1` → `1.2.0+2`)
2. Update CHANGELOG or release notes
3. Build new version
4. Upload to App Store Connect
5. Add "What's New" notes
6. Submit for review

## 📞 Support

For issues specific to this app:
- GitHub Issues: https://github.com/getBoolean/remote_zfs_unlock/issues

For App Store/TestFlight issues:
- Apple Developer Support: https://developer.apple.com/contact/
