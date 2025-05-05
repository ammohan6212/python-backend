# Dockerfile

# Use official Python image
FROM python:3.14-rc-alpine3.20

# Set the working directory inside the container
WORKDIR /app

# Copy the application code to the container
COPY app.py /app/app.py

# Install Flask dependency
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the app
CMD ["python", "app.py"]
