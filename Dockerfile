FROM ubuntu:22.04

# Tools
RUN apt update -y && apt -qq install -y unzip curl wget

LABEL maintainer="nagabcube"

WORKDIR /opt

# Downloads - "hardcoded" 
RUN wget https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-x64_bin.tar.gz
RUN curl -so gradle-8.13-bin.zip https://downloads.gradle.org/distributions/gradle-8.13-bin.zip
RUN curl -so commandlinetools-linux-13114758_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -

# JAVA
RUN tar -xvf jdk-17.0.12_linux-x64_bin.tar.gz && \
    mkdir -p /usr/local/java/jdk && \
    mv jdk-17.0.12/* /usr/local/java/jdk && \
    rm -r jdk-17.0.12 && \
    rm jdk-17.0.12_linux-x64_bin.tar.gz

# ANDROID
RUN mkdir -p /usr/local/android-sdk/cmdline-tools/latest/ && \
    unzip commandlinetools-linux-13114758_latest.zip && \
    mv cmdline-tools/* /usr/local/android-sdk/cmdline-tools/latest && \
    rm -r cmdline-tools && \
    rm commandlinetools-linux-13114758_latest.zip

# GRADLE
RUN unzip gradle-8.13-bin.zip && \
    mkdir -p /usr/local/gradle && \
    mv gradle-8.13/* /usr/local/gradle && \
    rm -r gradle-8.13 && \
    rm gradle-8.13-bin.zip && \
    chmod -R o+rx /usr/local/gradle/bin && \
    chmod -R o+rx /usr/local/gradle/lib

# NODEJS-CORDOVA
RUN apt -qq install -y nodejs && \
    npm i -g cordova@12.0.0 && \
    npm i -g npm@11.6.2

ENV JAVA_HOME=/usr/local/java/jdk \
    ANDROID_SDK_ROOT=/usr/local/android-sdk \
    ANDROID_HOME=/usr/local/android-sdk \
    GRADLE_HOME=/usr/local/gradle \
    GRADLE_USER_HOME=/usr/local/gradle
ENV PATH=$PATH:$JAVA_HOME:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$GRADLE_HOME/bin

COPY android.packages android.packages

RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sdkmanager --package_file=android.packages

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /opt/android.packages && \
    apt-get autoremove -y && \
    apt-get clean
