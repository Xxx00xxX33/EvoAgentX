# Use Python 3.11 slim image
FROM python:3.11-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .
COPY evoagentx/app/requirements.txt ./app_requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r app_requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

# Expose port (default 8000)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Command to run the application
CMD ["python", "-m", "uvicorn", "evoagentx.app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]