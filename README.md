# Remote ZFS Unlock

An app for managing ZFS datasets on remote servers over SSH.

## Features

- List datasets
- Unlock encrypted datasets using:
  - passphrase
  - uploaded keyfile
  - path to keyfile
- Lock encrypted datasets by unloading key
- Create datasets
  - encrypt by passphrase or uploaded keyfile

## Tech stack

- SSH: [`dartssh2`](https://pub.dev/packages/dartssh2)
- State + hooks: [`hooks_riverpod`](https://pub.dev/packages/hooks_riverpod), [`flutter_hooks`](https://pub.dev/packages/flutter_hooks)
- Models: [`dart_mappable`](https://pub.dev/packages/dart_mappable)
- Local DB: [`hive_ce`](https://pub.dev/packages/hive_ce)
- Secret storage: [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)

## Server requirements

- Remote host must have `zfs` installed and available for the SSH user.
- SSH user must be allowed to run:
  - `zfs list`
  - `zfs load-key`
  - `zfs unload-key`
  - `ls`
- If `sudo` is required for `zfs`, configure server-side policy accordingly (for example a restricted `sudoers` rule).

## Demo

A live demo is setup at https://getboolean.github.io/remote_zfs_unlock/main but SSH is currently not functioning on Web

## Usage

1. Add a server profile and choose auth mode:
   - password
   - private key (paste PEM or upload a keyfile)
2. Open the server.
3. For encrypted datasets:
   - use **Unlock** to mount and load keys (passphrase or uploaded keyfile)
   - use **Lock** to unmount and unload keys

## Security notes

- Non-secret profile metadata is stored in Hive.
- Server Password/PEM is stored in platform secure storage.
- Dataset passphrase/keyfiles are not stored.
- The app avoids printing secrets in UI messages.
- Uploaded ZFS keyfiles are sent over the SSH shell
