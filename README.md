<div align="center">
  <img src="https://github.com/user-attachments/assets/4f3de1c5-6405-4d98-8581-29a93d84890c" alt="Flutter Logo" width="150"/>
  
  # Remote ZFS Unlock
  
  **Securely manage encrypted ZFS datasets on remote servers over SSH**
  
  [![Latest Release](https://img.shields.io/github/v/release/getBoolean/remote_zfs_unlock?label=Download&style=for-the-badge)](https://github.com/getBoolean/remote_zfs_unlock/releases/latest)
  [![License](https://img.shields.io/github/license/getBoolean/remote_zfs_unlock?style=for-the-badge)](LICENSE)
  
  [📥 Download](#-download) • [✨ Features](#-features) • [🚀 Demo](#-demo) • [📖 Usage](#-usage)
</div>

---

## 📥 Download

Get the latest version **v1.0.0+2** for your platform:

| Platform | Download |
|----------|----------|
| 🪟 **Windows** | [remote_zfs_unlock-v1.0.0+2-windows.msix](https://github.com/getBoolean/remote_zfs_unlock/releases/download/v1.0.0%2B2/remote_zfs_unlock-v1.0.0%2B2-windows.msix) |
| 🍎 **macOS** | [remote_zfs_unlock-v1.0.0+2-macos.dmg](https://github.com/getBoolean/remote_zfs_unlock/releases/download/v1.0.0%2B2/remote_zfs_unlock-v1.0.0%2B2-macos.dmg) |
| 🐧 **Linux** | [remote_zfs_unlock-v1.0.0+2-linux.rpm](https://github.com/getBoolean/remote_zfs_unlock/releases/download/v1.0.0%2B2/remote_zfs_unlock-v1.0.0%2B2-linux.rpm) |
| 🤖 **Android** | [remote_zfs_unlock-v1.0.0+2-android-universal.apk](https://github.com/getBoolean/remote_zfs_unlock/releases/download/v1.0.0%2B2/remote_zfs_unlock-v1.0.0%2B2-android-universal.apk) |
| 📱 **iOS** | [remote_zfs_unlock-v1.0.0+2-ios.ipa](https://github.com/getBoolean/remote_zfs_unlock/releases/download/v1.0.0%2B2/remote_zfs_unlock-v1.0.0%2B2-ios.ipa) |

> 💡 **Tip:** Visit the [Releases page](https://github.com/getBoolean/remote_zfs_unlock/releases/latest) for additional formats and installation instructions.

---

## ✨ Features

Remote ZFS Unlock provides a seamless interface for managing encrypted ZFS datasets on remote servers:

- 📋 **List datasets** - View all ZFS datasets on your remote server
- 🔓 **Unlock encrypted datasets** with multiple authentication methods:
  - Passphrase
  - Uploaded keyfile
  - Path to keyfile on remote server
- 🔒 **Lock datasets** - Securely unload keys to lock encrypted datasets
- ➕ **Create new datasets** - Set up encrypted datasets with passphrase or keyfile encryption
- 🔐 **Secure authentication** - Connect via SSH using password or private key
- 🛡️ **Security-first** - Credentials stored in platform secure storage, no dataset keys retained

---

## 🚀 Demo

Try the live demo at [https://getboolean.github.io/remote_zfs_unlock/main](https://getboolean.github.io/remote_zfs_unlock/main)

> ⚠️ **Note:** SSH is currently not functioning on Web. Download a native app for full functionality.

---

## 📖 Usage

### Getting Started

1. **Add a server profile**
   - Enter your server hostname and SSH port
   - Choose authentication method:
     - 🔑 Password authentication
     - 📄 Private key (paste PEM or upload keyfile)

2. **Connect to your server**
   - Open the server connection
   - View all available ZFS datasets

3. **Manage encrypted datasets**
   - Click **Unlock** to mount and load keys
     - Enter passphrase directly
     - Upload keyfile from your device
     - Specify path to keyfile on remote server
   - Click **Lock** to unmount and unload keys

---

## 🔧 Server Requirements

Your remote server needs the following:

- ✅ `zfs` installed and available for the SSH user
- ✅ SSH user must be permitted to run:
  - `zfs list`
  - `zfs load-key`
  - `zfs unload-key`
  - `ls`
- ✅ If `sudo` is required for `zfs`, configure appropriate `sudoers` rules

---

## 🛡️ Security

Security is a core principle of Remote ZFS Unlock:

- 🔐 **Non-secret metadata** stored in local Hive database
- 🔒 **Server credentials** (passwords/PEM keys) stored in platform secure storage
- 🚫 **Dataset passphrases/keyfiles** are never stored locally
- 👁️ **No secrets in logs** - The app avoids printing secrets in UI messages
- 🔑 **Secure transfer** - ZFS keyfiles transmitted over encrypted SSH connection

---

## 🛠️ Tech Stack

Built with modern Flutter and Dart technologies:

- **SSH:** [`dartssh2`](https://pub.dev/packages/dartssh2) - Robust SSH client
- **State Management:** [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) - Reactive state
- **Data Models:** [`dart_mappable`](https://pub.dev/packages/dart_mappable) - Type-safe serialization
- **Local Storage:** [`hive_ce`](https://pub.dev/packages/hive_ce) - Fast NoSQL database
- **Secure Storage:** [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) - Platform keychain integration

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
