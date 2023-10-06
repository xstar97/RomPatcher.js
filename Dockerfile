# Use an official Python runtime as a parent image
FROM python:3.8-alpine

# Set a custom port as a default (3000 if not specified)
ENV PORT=3000

# Create a directory to store your files
WORKDIR /app

# Install curl and Git for healthcheck and cloning the repository
RUN apk update && apk add --no-cache curl git

# Install Twisted, a Python package for creating network servers
RUN pip install twisted

# Define an argument for the RomPatcher.js tag
ARG UPSTREAM_TAG

# Add an echo to indicate that the project is being cloned
RUN echo "Cloning RomPatcher.js project with tag ${UPSTREAM_TAG}..."

# Clone the specified RomPatcher.js tag from the GitHub repository into the private "public_path" directory
RUN git clone --depth 1 --branch ${UPSTREAM_TAG} https://github.com/marcrobledo/RomPatcher.js.git /public

# Verification step: Check if /public directory exists
RUN if [ ! -d /public ]; then \
      echo "GitHub repository was not cloned successfully into /public"; \
      exit 1; \
    fi

# Expose the port specified by the PORT environment variable
EXPOSE $PORT

# Copy your Twisted Python script into the container (assuming you have a script named app.py)
COPY app.py /app

# Start the Twisted HTTPS server using a shell command to substitute the environment variable
CMD sh -c "echo 'Starting server on port $PORT' && twistd web --https=$PORT --path=/public"

# Add a healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl --fail https://localhost:$PORT || exit 1
