
FROM python:3.13-slim-bookworm

RUN apt-get update && \
    apt-get install -y --only-upgrade zlib1g



WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir flask

COPY  . .

EXPOSE 5000
CMD ["python", "app.py"]