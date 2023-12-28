FROM ubuntu:18.04

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk wget
# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Set environment variables
ENV ANDROID_SDK_TOOLS 7583922
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
ENV ANDROID_BUILD_TOOLS_VERSION 33.0.0
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_VERSION 33
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk/cmdline-tools/latest
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O commandlinetools.zip $ANDROID_SDK_URL
RUN unzip commandlinetools.zip && rm commandlinetools.zip

# Move command line tools to the correct directory
USER root
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" && chown -R developer "$ANDROID_HOME"
USER developer
RUN mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"

# Accept licenses and install necessary Android SDK components
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platform-tools" "platforms;android-${ANDROID_VERSION}"
ENV PATH "$PATH:$ANDROID_HOME/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git && cd flutter && git checkout stable
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dart SDK
RUN flutter doctor