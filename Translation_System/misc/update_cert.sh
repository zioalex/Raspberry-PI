#!/usr/bin/env bash
set -xeou pipefail
# This script is used to update the certificate of the Jitsi server

LOCAL_CERTS_FOLDER="./certs"

scp $LOCAL_CERTS_FOLDER/privkey.pem root@translation.sennsolutions.com:/etc/ssl/translation.sennsolutions.com.key
scp $LOCAL_CERTS_FOLDER/fullchain.pem root@translation.sennsolutions.com:/etc/ssl/translation.sennsolutions.com.crt
read -p "Press enter to reboot the Jitsi server"
ssh root@translation.sennsolutions.com reboot