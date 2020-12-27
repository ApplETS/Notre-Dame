#!/bin/bash
# Script to decrypt all the secrets files.
# Club App|ETS

pwd
openssl version -v
# Decrypt Signets API
mkdir -p ./assets/certificates
openssl enc -aes-256-cbc -d -K "$ENCRYPTED_SIGNETS_API_CERT_PASSWORD" -in ./assets/encryptedFiles/signets_cert.crt.enc -out ./assets/certificates/signets_cert.crt