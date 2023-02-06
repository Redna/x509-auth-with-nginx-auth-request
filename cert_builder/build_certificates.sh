# !/bin/sh

set -e

mkdir certs
cd certs

echo ""
echo "----------------------------------------------------"
echo "[1/6] Create CA"
echo "----------------------------------------------------"

mkdir ca
openssl req -x509 -new -newkey rsa:4096 -nodes -sha256 -days 1826 -keyout ca/ca.key -out ca/ca.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=The authority"


echo ""
echo "----------------------------------------------------"
echo "[2/6] Create server certificate"
echo "----------------------------------------------------"
mkdir server
openssl req -nodes -newkey rsa:2048 -keyout server/server.key -out server/server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=server"
openssl x509 -req -days 365 -in server/server.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out server/server.crt

echo ""
echo "----------------------------------------------------"
echo "[3/6] Create client certificate [CN: authorized_client]"
echo "----------------------------------------------------"
mkdir clients
openssl req -nodes -newkey rsa:2048 -keyout clients/client.key -out clients/client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JackAuthorized"
openssl x509 -req -days 365 -in clients/client.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out clients/client.crt

echo ""
echo "----------------------------------------------------"
echo "[4/6] Create unauthorized client certificate [CN: unauthorized]"
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout clients/unauthorized_client.key -out clients/unauthorized_client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=MickUnauthorized"
openssl x509 -req -days 365 -in clients/unauthorized_client.csr -CA ca/ca.crt -CAkey ca/ca.key -set_serial 01 -out clients/unauthorized_client.crt

echo ""
echo "----------------------------------------------------"
echo '[5/6] Create "unknown" client certificate [CN: authorized_client]'
echo "----------------------------------------------------"
openssl req -nodes -newkey rsa:2048 -keyout clients/unknown_client.key -out clients/unknown_client.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=Whoaru?"

echo ""
echo "----------------------------------------------------"
echo "[6/6] Create cert for signing JWTs"
echo "----------------------------------------------------"
mkdir jwt
openssl req -nodes -newkey rsa:2048 -keyout jwt/trusted_jwt_signer.key -out jwt/trusted_jwt_signer.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JWTSigner"
openssl x509 -req -days 365 -in jwt/trusted_jwt_signer.csr -CA ca/ca.crt -CAkey ca/ca.key -set_serial 01 -out jwt/trusted_jwt_signer.crt