# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Setting the working directory in the container
WORKDIR /app

# Copying current directory contents into the container at location /app
COPY . .

# Installing packages specified in requirements.txt
RUN pip install -r requirements.txt

# Exposing port 8080
EXPOSE 8080

# Setting the entrypoint to use gunicorn to serve the app
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]