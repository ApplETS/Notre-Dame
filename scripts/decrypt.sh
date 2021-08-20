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

# Decrypt Android Keystore, JKS and service account credentials
if [[ -n $ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD && -n $ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD && -n $ENCRYPTED_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD ]]; then
  echo "Decoding Android keystore, JKS and service account credentials"
  openssl aes-256-cbc -k "$ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD" -in ./encryptedFiles/etsm_upload_ks.jks.enc -out ./android/etsm_upload_ks.jks -d
  openssl aes-256-cbc -k "$ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD" -in ./encryptedFiles/keystore.properties.enc -out ./android/keystore.properties -d
  openssl aes-256-cbc -k "$ENCRYPTED_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD" -in ./encryptedFiles/service_account_credentials.json.encrypted -out ./service_account_credentials.json -d
fi