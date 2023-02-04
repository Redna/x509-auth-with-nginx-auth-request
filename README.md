- [Overview](#overview)
- [Setup](#setup)
  - [Folder Structure](#folder-structure)
    - [Option 1: Run the setup script to get the certificates ready for you](#option-1-run-the-setup-script-to-get-the-certificates-ready-for-you)
    - [Option 1: Run the setup script to get the certificates ready for you](#option-1-run-the-setup-script-to-get-the-certificates-ready-for-you-1)
      - [1. Certificate Authority (CA)](#1-certificate-authority-ca)
      - [2. Server Certificate](#2-server-certificate)
      - [3. Authorized Client Certificate](#3-authorized-client-certificate)
      - [Unauthorized Client Certificate](#unauthorized-client-certificate)
      - [Unknown Client Certificate](#unknown-client-certificate)
      - [JWT Signing Certificate](#jwt-signing-certificate)
- [Run the scenario](#run-the-scenario)
  - [Setup and run the different requests form the python client](#setup-and-run-the-different-requests-form-the-python-client)


# Overview
In a pretty standard enterprise setup, the authentication for clients inside the intranet can be done using client certificates. The common name of the certificate holds the unique username (enterprise id) of the user. The following scenario outlines, how a NGINX auth_request functionality can be used to authenticate and authorize a user requests with x509 client certificates, by proxying the request to a authorization server. Another use case covered in this scenario proxying the request details using Json Web Tokens. For example an application gateway forwards a request of a user without loosing its authentication information like in our case the x509 credentials. The server sends a signed JSON web token containing the valid user certificate. We'll build up the scenario pictured below: 

``` mermaid
graph TB

a[Authorized User] -- x509 certificate --> nginx(Nginx)
b[Authorized User] -- x509 certificate --> ag(Application Gateway)
ag -- Signed JWT --> nginx(Nginx)
c[Unauthorized] -- x509 certificate--> nginx

nginx -. on auth <br> success -.-> protected_a(Protected Resource A)

nginx == auth request ==> auth{Authorization <br> Server} 

nginx -. on auth <br> success -.-> protected_b(Protected Resource B)
```


> NOTE: a prerequisite is a working Docker and Docker-Compose installation

# Setup

In order to run the scenario, the first step will be to create a private certificate authority (CA). This authority will sign the client and the server certificate. All clients signed by this certificate will be trusted.

In our case the simple certificate setup looks as follows:


``` mermaid
graph TB

CA[Certificate Authority CA] -- signed --> s(Server)
CA -- signed --> c(Client)
CA -- signed --> jwt(trusted JWT signer)
CA -- signed --> uc(Unauthorized Client)
uCA[Untrusted CA] -- signed --> uac(Untrusted client)

```


## Folder Structure
For the authentication scenario the following folder structure will be created. 

    certs/
    ├── ca/
    │   ├── ca.key
    │   ├── ca.crt
    ├── server/
    │   ├── server.key
    │   ├── server.csr
    │   └── server.crt
    ├── jwt/
    │   ├── trusted_jwt_signer.key
    │   ├── trusted_jwt_signer.csr
    │   └── trusted_jwt_signer.crt
    └── clients/
        ├── client.crt
        ├── client.csr
        ├── client.key
        ├── unauthorized_client.crt
        ├── unauthorized_client.csr
        ├── unauthorized_client.key
        ├── unauthorized_client.crt
        ├── unauthorized_client.csr
        ├── unauthorized_client.key
        ├── unknown_client.crt
        ├── unknown_client.csr
        └── unknown_client.key


The fastest and easiest way to setup the structure illustrated above is to run **Option 1** - However, if you like, you can follow along **Option 2** to create all certificates one by one.

### Option 1: Run the setup script to get the certificates ready for you
```
# Run it in project root

sh ./scripts/build_certificates
```


### Option 1: Run the setup script to get the certificates ready for you

Start it by creating the necessary folders:
```
mkdir -p {certs/ca,certs/server,certs/jwt,certs/clients}
```

#### 1. Certificate Authority (CA)

As mentioned in the beginning the CA will be used to sign the server certificates and all cients.

```
openssl req -nodes -newkey rsa:4096 -keyout certs/clients/unauthorized_client.key -out certs/clients/unknown_client.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=The authority"
```
> Feel free to adjust the values for the -subj parameter

#### 2. Server Certificate

This certificate is used by the server to authenticate itself when runing the auth_request. 

```
openssl req -nodes -newkey rsa:2048 -keyout certs/server/server.key -out certs/server/server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=server"
```

The `server.csr` signing request needs to be sign by our trusted CA.

```
openssl x509 -req -days 365 -in certs/server/server.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/server/server.crt
```

#### 3. Authorized Client Certificate

This certificate is used to authenticate a client against our authority service. For our exapmle we chose the Common Name (CN) JackAuthorized. This will be hardcoded in our server and verified.

```
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/client.key -out certs/clients/client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JackAuthorized"
```

The `client.csr` signing request needs to be sign by our trusted CA.

```
openssl x509 -req -days 365 -in certs/clients/client.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/clients/client.crt
```

#### Unauthorized Client Certificate

This certificate will be used to authenticate a client against our authority service. This should be for our example an not authorized common name.

```
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/unauthorized_client.key -out certs/clients/unauthorized_client.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=MickUnauthorized"
```

```
openssl x509 -req -days 365 -in certs/clients/unauthorized_client.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/clients/unauthorized_client.crt
```

#### Unknown Client Certificate

To test if the authentication works properly we need to create a standard certificate which will not be signed by our CA.

```
openssl req -nodes -newkey rsa:2048 -keyout certs/clients/unknown_client.key -out certs/clients/unknown_client.crt -subj "/C=GB/ST=London/L=London/O=Some Other Global Security/OU=IT Department/CN=Whoaru?"
```

#### JWT Signing Certificate 

In order to encode and decode a JWT properly, we need to create another certifcate and sign it by the authority.

```
openssl req -nodes -newkey rsa:2048 -keyout certs/jwt/trusted_jwt_signer.key -out certs/jwt/trusted_jwt_signer.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=JWTSigner"
```

```
openssl x509 -req -days 365 -in client/jwt/trusted_jwt_signer.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -set_serial 01 -out certs/jwt/trusted_jwt_signer.crt
```

# Run the scenario

> NOTE: it used to work in my environment (classic :D), somehow the nginx and python server cannot communicate anymore. So I am not able to run it properly anymore. Hopefully, you have more luck


Verify the setup by running: `docker-compose up` (maybe `sudo docker-compse up` is working for you)

Use curl to run a request to our protect server with the valid user certificate

`curl https://localhost:443 --cert certs/clients/client.crt --key certs/clients/client.key -k`


## Setup and run the different requests form the python client 
To create a new virtual environment run the following commands:

```bash
cd python_client
python -m venv venv
pip install -r requirements.txt
```

Then run the app using `python client/main.py`





