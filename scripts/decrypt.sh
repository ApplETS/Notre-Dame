#!/bin/bash
# Script to decrypt all the secrets files.
# Club App|ETS

pwd
openssl version -v

# Decrypt Signets API
if [[ -n "$ENCRYPTED_SIGNETS_API_CERT_PASSWORD" ]]; then
  mkdir -p ./assets/certificates
  echo "Decoding SignETS certificates"
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_SIGNETS_API_CERT_PASSWORD" -in ./encryptedFiles/signets_cert.crt.enc -out ./assets/certificates/signets_cert.crt -md md5
fi

# Decrypt Google service files (Android and iOS).
if [[ -n "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" ]]; then
  echo "Decoding google-services files"
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" -in ./encryptedFiles/firebase_app_id_file.json.enc -out ./ios/firebase_app_id_file.json -md md5
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" -in ./encryptedFiles/google-services.json.enc -out ./android/app/src/google-services.json -md md5
  openssl enc -aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_GOOGLE_SERVICE_PASSWORD" -in ./encryptedFiles/GoogleService-Info.plist.enc -out ./ios/Runner/GoogleService-Info.plist -md md5
fi

# Decrypt Android Keystore, JKS and service account credentials
if [[ -n $ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD && -n $ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD ]]; then
  echo "Decoding Android keystore and JKS"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD" -in ./encryptedFiles/etsm_ks.jks.enc -out ./android/etsm_ks.jks -md md5
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD" -in ./encryptedFiles/keystore.properties.enc -out ./android/keystore.properties -md md5
fi

# Decrypt debug Android Keystore, JKS and service account credentials
if [[ -n ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD_DEBUG && -n ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD_DEBUG ]]; then
  echo "Decoding debug Android keystore and JKS"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_ETSMOBILE_KEYSTORE_PASSWORD_DEBUG" -in ./encryptedFiles/debug_keystore.jks.enc -out ./android/debug_keystore.jks -md md5
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_KEYSTORE_PROPERTIES_PASSWORD_DEBUG" -in ./encryptedFiles/debug_keystore.properties.enc -out ./android/debug_keystore.properties -md md5
fi

if [[ -n $ENCRYPTED_ANDROID_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD ]]; then
  echo "Decoding Android service account credentials"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_ANDROID_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD" -in ./encryptedFiles/android_service_account_credentials.json.enc -out ./android/service_account_credentials.json -md md5
fi

if [[ -n $ENCRYPTED_IOS_MATCHFILE_PASSWORD ]]; then
  echo "Decoding Fastlane Matchfile for iOS"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_IOS_MATCHFILE_PASSWORD" -in ./encryptedFiles/Matchfile.enc -out ./ios/fastlane/Matchfile -md md5
fi

if [[ -n $ENCRYPTED_IOS_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD ]]; then
  echo "Decoding iOS service account credentials"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_IOS_SERVICE_ACCOUNT_CREDENTIALS_PASSWORD" -in ./encryptedFiles/ios_service_account_credentials.json.enc -out ./ios/service_account_credentials.json -md md5
fi

if [[ -n $ENCRYPTED_MSAL_CONFIG_PASSWORD ]]; then
  echo "Decoding MSAL config"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_MSAL_CONFIG_PASSWORD" -in ./encryptedFiles/msal_config.json.enc -out ./assets/msal_config.json -md md5
fi

if [[ -n $ENCRYPTED_CONFIG_PROPERTIES ]]; then
  echo "Decoding config.properties"
  openssl aes-256-cbc -pbkdf2 -d -k "$ENCRYPTED_CONFIG_PROPERTIES" -in ./encryptedFiles/config.properties.enc -out ./android/config.properties -md md5
fi
