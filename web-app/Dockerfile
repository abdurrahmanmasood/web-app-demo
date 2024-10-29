# Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8080 to match GKE conventions
EXPOSE 8080

# Set the entrypoint to use gunicorn to serve the app
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
