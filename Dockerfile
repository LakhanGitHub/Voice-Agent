# Use Python 3.11 slim image
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock* ./

# Set environment variables to disable bytecode and use system Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1

# Install dependencies using uv
RUN uv pip install --system --no-cache -r pyproject.toml

# Copy application code (entire directory)
COPY . .

# Expose port 5000 (Flask default port)
EXPOSE 5000

# Set environment variables for Flask
ENV FLASK_APP=app.py \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5000

# Command to run Flask application with Gunicorn (production server)
# Use $PORT environment variable for Render.com compatibility
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 --timeout 120 app:app"]