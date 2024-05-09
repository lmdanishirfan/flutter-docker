# Base image with minimal dependencies
FROM ubuntu:20.04

# Update package lists
RUN apt-get update

# Install dependencies
RUN apt-get install -y curl git unzip zip

# Define Flutter version and download URL (replace with desired version)
ENV FLUTTER_VERSION=3.16.9
RUN git clone --depth 1 --branch 3.16.9 https://github.com/flutter/flutter.git /opt/flutter && \
    echo "FLUTTER_VERSION=${FLUTTER_VERSION}"

# Environment variable for flutter
ENV PATH="$PATH:/opt/flutter/bin"

RUN flutter doctor

# Working directory for your project
WORKDIR /app

# Single stage build (default) - comment out the multi-stage section above
CMD ["/bin/bash"]
