# GitHub Secrets Setup

Set these repository secrets before running the release workflow:

1. `KEYSTORE_BASE64`
   - Base64-encoded Android release keystore.
   - Example: `base64 -w 0 android/keystore/laqta-release.jks`

2. `KEYSTORE_PASSWORD`
   - Store password for the release keystore.

3. `KEY_ALIAS`
   - Release key alias inside the keystore.

4. `KEY_PASSWORD`
   - Password for the release key alias.

5. `API_BASE_URL`
   - Production API URL, for example `https://api.laqta.cloud`.

Never commit keystores, key.properties, debug-info, or symbol files.
