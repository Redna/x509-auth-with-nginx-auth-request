FROM python:3.10-alpine3.15

COPY requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

COPY python_server/src /app/src

ENTRYPOINT [ "python", "src/main.py" ]