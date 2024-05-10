

# Base image with minimal dependencies
FROM ubuntu:20.04
# Set DEBIAN_FRONTEND to noninteractive to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# "11076708" as of 2024/03/04
ENV ANDROID_SDK_TOOLS_VERSION="11076708"
# Update package lists
RUN apt-get update

# Install dependencies
RUN apt-get install -y curl git unzip zip openjdk-17-jdk

# Define Flutter version and download URL (replace with desired version)
ENV FLUTTER_VERSION=3.16.9
RUN git clone --depth 1 --branch 3.16.9 https://github.com/flutter/flutter.git /opt/flutter && \
    echo "FLUTTER_VERSION=${FLUTTER_VERSION}"

# Environment variable for flutter
ENV PATH="$PATH:/opt/flutter/bin"
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin"

# Install Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT && \
    cd $ANDROID_SDK_ROOT && \
    curl -o sdk-tools-linux.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip" && \
    unzip -d cmdline-tools sdk-tools-linux.zip && \
    rm sdk-tools-linux.zip

# Set permissions and ensure sdkmanager is executable
RUN chmod +x $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager

# Accept Android SDK licenses
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses

# Print the contents of the bin directory
RUN ls -l $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin

# Install required Android SDK components
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"


RUN flutter doctor

# Working directory for your project
WORKDIR /app

# Single stage build (default) - comment out the multi-stage section above
CMD ["/bin/bash"]
