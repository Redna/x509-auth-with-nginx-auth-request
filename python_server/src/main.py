
import requests
import jwt
import uvicorn

from fastapi import FastAPI, HTTPException, Header
from starlette import status
from cryptography.x509 import load_pem_x509_certificate


ALLOWED_CN = ["JackAuthorized"]

app = FastAPI()

with open("./certs/clients/client.crt", "rb") as file:
    public_cert = load_pem_x509_certificate(file.read())
    public_key = public_cert.public_key()



@app.get("/")
def root():
    return {"message": "Hello World"}


@app.get("/auth")
def auth(authorization_token: list[str] | None = Header(default=None), www_authenticate: list[str] | None = Header(default=None)):
    print(www_authenticate)

    if authorization_token:
        token = authorization_token[0].split(" ")[1]

        try:
            decoded_token = jwt.decode(token, public_cert.public_key(), algorithms=["RS256"])
        except Exception as e:
            detail = f"Not allowed to access service! Error: {e}"
            
            print(detail)

            raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail) 

        to_verify_cn = decoded_token["CN"]
        print(f"successfully decoded JWT: {to_verify_cn}")

    elif www_authenticate:
        to_verify_cn = www_authenticate[0]
        print(f"Using cn from www_authenticate: {to_verify_cn}")

    if to_verify_cn and to_verify_cn in ALLOWED_CN:
        return "ok"

    raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not allowed to access service!")


if __name__ == '__main__':
    uvicorn.run("main:app", host="0.0.0.0", port=5000, log_level="info", ssl_certfile="./certs/server/server.crt", ssl_keyfile="./certs/server/server.key")