#!/bin/bash
# Script to decrypt all the secrets files.
# Club App|ETS

pwd
openssl version -v
# Decrypt Signets API
mkdir -p ./assets/certificates
openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_SIGNETS_API_CERT_PASSWORD" -in ./encryptedFiles/signets_cert.crt.enc -out ./assets/certificates/signets_cert.crt -md md5

# Decrypt Google service files (Android and iOS).
if [[ -n "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" ]]; then
  echo "Decoding google-services files"
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" -in ./encryptedFiles/google-services.json.enc -out ./android/app/google-services.json -md md5
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" -in ./encryptedFiles/GoogleService-Info.plist.enc -out ./ios/Runner/GoogleService-Info.plist -md md5
fi
