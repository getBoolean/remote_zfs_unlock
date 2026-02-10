# Remote ZFS Unlock

Flutter app for connecting to remote servers over SSH and managing encrypted ZFS datasets.

## Features

- Save multiple server profiles (host/port/user/auth mode).
- Authenticate with either password or private key (PEM).
- Keep secrets in platform secure storage.
- List datasets from `zfs list -H -o name,encryption,keystatus,mounted`.
- Unlock encrypted datasets using:
  - passphrase (`zfs load-key <dataset>`, passphrase over stdin)
  - uploaded keyfile (`zfs load-key -L file://... <dataset>`)
- Lock encrypted datasets by unloading key:
  - `zfs unload-key <dataset>`

## Tech stack

- SSH/SFTP: [`dartssh2`](https://pub.dev/packages/dartssh2)
- State + hooks: [`hooks_riverpod`](https://pub.dev/packages/hooks_riverpod), [`flutter_hooks`](https://pub.dev/packages/flutter_hooks)
- Local metadata DB: [`hive_ce`](https://pub.dev/packages/hive_ce)
- Secret storage: [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)

## Server requirements

- Remote host must have `zfs` installed and available for the SSH user.
- SSH user must be allowed to run:
  - `zfs list`
  - `zfs load-key`
  - `zfs unload-key`
  - `rm` for remote temp keyfile cleanup
- If `sudo` is required for `zfs`, configure server-side policy accordingly (for example a restricted `sudoers` rule).

## Usage

1. Add a server profile and choose auth mode:
   - password
   - private key (paste PEM or upload a keyfile)
2. Open the server and refresh datasets.
3. For encrypted datasets:
   - use **Unlock** to load keys (passphrase or uploaded keyfile)
   - use **Lock** to unload keys

## Security notes

- Non-secret profile metadata is stored in Hive.
- Password/private key/passphrase are stored in platform secure storage.
- The app avoids printing secrets in UI messages.
- Uploaded ZFS keyfiles are stored remotely in `/tmp` during unlock and then removed.
