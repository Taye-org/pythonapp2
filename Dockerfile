FROM  3.13.3-alpine3.21
    
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir flask

COPY  . .

EXPOSE 5000
CMD ["python", "app.py"]
