FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY web_to_gcs.py web_to_gcs.py
COPY load_yellow_taxi_data.py load_yellow_taxi_data.py
COPY gcs.json /app/

# Set environment variables for Google Cloud credentials
ENV GCP_GCS_BUCKET="nyc-tl-data-aafaf"

# Run the script
CMD ["python", "web_to_gcs.py"]
