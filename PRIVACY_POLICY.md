# Privacy Policy for Remote ZFS Unlock

**Last Updated:** February 2026

## Overview

Remote ZFS Unlock is a tool for managing ZFS datasets on remote servers over SSH. We take your privacy seriously and are committed to protecting your data.

## Data Collection and Storage

### What We Collect

The app stores the following information locally on your device:

1. **Server Connection Details:**
   - Server hostname/IP address
   - SSH port number
   - SSH username
   - Connection preferences

2. **Authentication Credentials (Stored Securely):**
   - SSH passwords (when using password authentication)
   - SSH private keys (when using key-based authentication)

### How We Store Your Data

- **Non-sensitive metadata** (server hostnames, usernames, ports) is stored in local database using Hive.
- **Sensitive credentials** (passwords, private keys) are stored in platform-specific secure storage:
  - iOS: Keychain
  - macOS: Keychain
  - Android: EncryptedSharedPreferences
  - Linux/Windows: Platform secure storage

### What We Don't Collect

- We do **NOT** collect, transmit, or store any data on external servers
- We do **NOT** store ZFS dataset passphrases or keyfiles
- We do **NOT** track your usage or behavior
- We do **NOT** share any information with third parties
- We do **NOT** use analytics or advertising services

## Data Usage

The data collected is used exclusively for:

- Establishing SSH connections to your specified remote servers
- Authenticating with your remote servers
- Executing ZFS commands on remote servers

All operations are performed directly between your device and your remote servers. No intermediary services are used.

## Data Security

- Authentication credentials are stored using platform-native secure storage mechanisms
- SSH connections use standard SSH encryption (SSH-2 protocol)
- Dataset passphrases and keyfiles are never persisted to disk
- The app avoids printing sensitive information in UI messages

## Network Access

The app requires network access to:

- Connect to remote servers via SSH protocol (typically port 22)
- No other network connections are made

## File Access

The app requires file access to:

- Import SSH private key files
- Import ZFS encryption keyfiles (temporarily, for upload to remote server)

Files are only accessed when explicitly selected by you through the file picker.

## User Control

You have full control over your data:

- All data is stored locally on your device
- You can delete server profiles at any time from within the app
- Deleting a server profile removes all associated data
- Uninstalling the app removes all stored data

## Changes to This Policy

We may update this Privacy Policy from time to time. Any changes will be reflected in the "Last Updated" date above. Continued use of the app after changes constitutes acceptance of the updated policy.

## Contact

For questions or concerns about this privacy policy, please open an issue on our GitHub repository: https://github.com/getBoolean/remote_zfs_unlock

## Open Source

This app is open source. You can review the source code to verify these privacy claims at: https://github.com/getBoolean/remote_zfs_unlock
