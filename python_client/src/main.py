from time import sleep
import requests
import jwt
from cryptography.x509 import load_pem_x509_certificate

from cryptography.hazmat.primitives.asymmetric.padding import AsymmetricPadding

def open_key(path):
    with open(path) as file:
        return file.read()

def request_with_jwt(private_key):

    token = jwt.encode({"CN": "JackAuthorized"}, private_key, algorithm="RS256")

    response = requests.get('https://nginx:443/secure_resource', 
                            headers={"authorization-token": f"Bearer {token}"}, 
                            cert=("certs/jwt/trusted_jwt_signer.crt", "certs/jwt/trusted_jwt_signer.key"),
                            verify=False)
    
    print(response.status_code)
    print(response.content)
    

def main(): 

    print("--------------------- 1 Without JWT ---------------------")
    response = requests.get('https://nginx:443/secure_resource', cert=("certs/clients/client.crt", "certs/clients/client.key"), verify=False)

    print(response.status_code)
    print(response.content)
    sleep(1)
    
    print("--------------------- 2 Without JWT invalid -------------")
    response = requests.get('https://nginx:443/secure_resource', cert=("certs/clients/unauthorized_client.crt", "certs/clients/unauthorized_client.key"), verify=False)

    print(response.status_code)
    print(response.content)
    sleep(1)

    print("---------------------------------------------------------")

    print("--------------------- 3. With valid JWT ------------------")
  
    request_with_jwt(open_key("certs/jwt/trusted_jwt_signer.key"))
    sleep(1)

    print("---------------------------------------------------------")

    print("--------------------- 4. With invalid JWT ----------------")
    
    request_with_jwt(open_key("certs/clients/client.key"))
    sleep(1)

    print("---------------------------------------------------------")

if __name__ == '__main__':
    main()