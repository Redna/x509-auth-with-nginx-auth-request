# !/bin/sh

set -e

mkdir -p {certs/ca,certs/server,certs/jwt,certs/clients}

echo ""
echo "----------------------------------------------------"
echo "[1/6] Create CA"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:4096 -keyout certs/clients/unauthorized_client.key -out certs/clients/unknown_client.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=The authority"

echo ""
echo "----------------------------------------------------"
echo "[2/6] Create server certificate"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout certs/server/server.key -out certs/server/server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=server"
openssl x509 -req -days 365 -in certs/server/server.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/server/server.crt

echo ""
echo "----------------------------------------------------"
echo "[3/6] Create client certificate [CN: authorized_client]"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/client.key -out certs/clients/client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JackAuthorized"
openssl x509 -req -days 365 -in certs/clients/client.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/clients/client.crt

echo ""
echo "----------------------------------------------------"
echo "[4/6] Create unauthorized client certificate [CN: unauthorized]"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/unauthorized_client.key -out certs/clients/unauthorized_client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=MickUnauthorized"
openssl x509 -req -days 365 -in certs/clients/unauthorized_client.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/clients/unauthorized_client.crt

echo ""
echo "----------------------------------------------------"
echo '[5/6] Create "unknown" client certificate [CN: authorized_client]'
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/unauthorized_client.key -out certs/clients/unknown_client.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=Whoaru?"

echo ""
echo "----------------------------------------------------"
echo "[6/6] Create cert for signing JWTs"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout certs/jwt/trusted_jwt_signer.key -out certs/jwt/trusted_jwt_signer.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JWTSigner"
openssl x509 -req -days 365 -in certs/jwt/trusted_jwt_signer.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/jwt/trusted_jwt_signer.crt