FROM python:3.13-bullseye


RUN apt-get update && \
    apt-get install -y patch dpkg dpkg-dev && \
    apt-get upgrade -y patch dpkg dpkg-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir flask

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
