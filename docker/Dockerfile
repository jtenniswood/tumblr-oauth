# Build stage
FROM python:3.14-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.14-alpine AS production

# Install runtime dependencies only
RUN apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Create non-root user
RUN adduser -D -u 1000 flaskuser

# Set working directory
WORKDIR /app

# Copy Python packages from builder stage
COPY --from=builder /root/.local /home/flaskuser/.local

# Copy only necessary application files
COPY app.py .
COPY requirements.txt .
COPY templates/ templates/

# Set ownership and switch to non-root user
RUN chown -R flaskuser:flaskuser /app
USER flaskuser

# Add local packages to PATH
ENV PATH=/home/flaskuser/.local/bin:$PATH
ENV PYTHONPATH=/home/flaskuser/.local/lib/python3.11/site-packages

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Run the application with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "app:app"] 