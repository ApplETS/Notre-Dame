#!/bin/bash
# Script to decrypt all the secrets files.
# Club App|ETS

pwd
openssl version -v
# Decrypt Signets API
openssl aes-256-cbc -d -k "${{ secrets.ENCRYPTED_SIGNETS_API_CERT_PASSWORD }}" -in ./assets/encryptedFiles/signets_cert.crt.enc -out ./assets/certificates/signets_cert.crt