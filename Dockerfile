

# Base image with minimal dependencies
FROM ubuntu:20.04
# Set DEBIAN_FRONTEND to noninteractive to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# "11076708" as of 2024/03/04
ENV ANDROID_SDK_TOOLS_VERSION="11076708"
ENV NDK_VERSION="26.2.11394342"
# Update package lists
RUN apt-get update

# Install dependencies
RUN apt-get install -y curl git unzip zip openjdk-17-jdk wget

# Define Flutter version and download URL (replace with desired version)
ENV FLUTTER_VERSION=3.19.0
RUN git clone --depth 1 --branch 3.19.0 https://github.com/flutter/flutter.git /opt/flutter && \
    echo "FLUTTER_VERSION=${FLUTTER_VERSION}"

# Environment variable for flutter
ENV PATH="$PATH:/opt/flutter/bin"
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin"

# Install Android SDK
RUN wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip"




# Create necessary directory structure for the Android SDK
RUN mkdir -p "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    cd "$ANDROID_HOME" && \
    mv cmdline-tools latest && \
    mkdir cmdline-tools && \
    mv latest cmdline-tools


# Print the contents of the bin directory
RUN ls -l $ANDROID_SDK_ROOT/cmdline-tools/latest/bin
# Set permissions and ensure sdkmanager is executable
RUN chmod +x $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager

# Accept Android SDK licenses
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses

# Install required Android SDK components
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "ndk;${NDK_VERSION}"

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

RUN flutter doctor

# Accept Android SDK licenses automatically
RUN yes | flutter doctor --android-licenses

# Working directory for your project
WORKDIR /app

# Single stage build (default) - comment out the multi-stage section above
CMD ["/bin/bash"]
