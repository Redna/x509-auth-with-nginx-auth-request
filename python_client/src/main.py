import requests
import jwt
from cryptography.x509 import load_pem_x509_certificate

from cryptography.hazmat.primitives.asymmetric.padding import AsymmetricPadding

def request_with_jwt():
    with open("certs/server/server.key") as file:
        private_key = file.read()

    token = jwt.encode({"CN": "JackAuthorized"}, private_key, algorithm="RS256")

    response = requests.get('https://nginx:443/secure_resource', 
                            headers={"authorization-token": f"Bearer {token}"}, 
                            cert=("certs/clients/client.crt", "certs/clients/client.key"),
                            verify=False)
    
    print(response.status_code)
    print(response.content)
    

def main(): 

    response = requests.get('https://nginx:443/secure_resource', cert=("certs/clients/client.crt", "certs/clients/client.key"), verify=False)

    print(response.status_code)
    print(response.content)

    print("---------")
    print("with jwt:")
    
    request_with_jwt()


if __name__ == '__main__':
    main()