FROM --platform=linux/amd64 ubuntu:22.04

MAINTAINER Vadym Vikulin <vadym.vikulin@rivchain.org>
LABEL description Robot Framework in Docker.

# Set the reports directory environment variable
ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

# Set the tests directory environment variable
ENV ROBOT_TESTS_DIR /opt/robotframework/tests

# Set the working directory environment variable
ENV ROBOT_WORK_DIR /opt/robotframework/temp

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Setup the timezone to use, defaults to UTC
ENV TZ UTC

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Define the default user who'll run the tests
ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

# Dependency versions
ENV AWS_CLI_VERSION 1.29.40
ENV AXE_SELENIUM_LIBRARY_VERSION 2.1.6
ENV BROWSER_LIBRARY_VERSION 18.0.0
ENV GOOGLE_CHROME_VERSION 110.0.5481.77
ENV FIREFOX_VERSION 120.0.1+build1-0ubuntu0.20.04
ENV DATABASE_LIBRARY_VERSION 1.4.3
ENV DATADRIVER_VERSION 1.10.0
ENV DATETIMETZ_VERSION 1.0.6
ENV MICROSOFT_EDGE_VERSION 121.0.2277.83
ENV FAKER_VERSION 5.0.0
ENV FTP_LIBRARY_VERSION 1.9
ENV GECKO_DRIVER_VERSION v0.34.0
ENV IMAP_LIBRARY_VERSION 0.4.6
ENV PABOT_VERSION 2.18.0
ENV REQUESTS_VERSION 0.9.5
ENV ROBOT_FRAMEWORK_VERSION 7.0
ENV SELENIUM_LIBRARY_VERSION 6.2.0
ENV SSH_LIBRARY_VERSION 3.8.0
ENV XVFB_VERSION 1.20

# By default, no reports are uploaded to AWS S3
ENV AWS_UPLOAD_TO_S3 false

ENV DISPLAY :0

# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/google-chrome.sh /opt/robotframework/bin/google-chrome
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # Chrome deps
    fonts-liberation \
    libasound2 \
    libgbm1 \
    libnspr4 \
    libnss3 \
    libu2f-udev \
    libvulkan1 \
    # Chrome deps
    #FF deps
    lsb-release \
    libgdk-pixbuf2.0-0 \
    xul-ext-ubufox \
    libcanberra0 \
    libdbusmenu-glib4 \
    libdbusmenu-gtk3-4 \
    #FF deps
    gcc \
    g++ \
    npm \
    nodejs \
    python3-pip \
    python3-yaml \
    tzdata \
    xvfb \
    dirmngr \
    wget \
    unzip \
    curl && \
    # Install latest NodeJS
    npm install -g n && n lts && \
    rm -rf /var/lib/apt/lists/*
  
RUN wget "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb" \
    && apt install -y ./"google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb" \
    && rm "google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb"

RUN wget "https://launchpad.net/~ubuntu-mozilla-security/+archive/ubuntu/ppa/+build/27033836/+files/firefox_${FIREFOX_VERSION}.1_amd64.deb" \
    && wget "https://launchpad.net/~ubuntu-mozilla-security/+archive/ubuntu/ppa/+build/27033836/+files/firefox-geckodriver_${FIREFOX_VERSION}.1_amd64.deb" \
    && apt install -y ./"firefox_${FIREFOX_VERSION}.1_amd64.deb" \
    && apt install -y ./"firefox-geckodriver_${FIREFOX_VERSION}.1_amd64.deb" \
    && rm "firefox_${FIREFOX_VERSION}.1_amd64.deb" \
    && rm "firefox-geckodriver_${FIREFOX_VERSION}.1_amd64.deb"


# FIXME: below is a workaround, as the path is ignored
RUN mv /usr/bin/google-chrome /usr/bin/google-chrome-original \
  && ln -sfv /opt/robotframework/bin/google-chrome /usr/bin/google-chrome

# Install ChromeDriver
RUN wget -q "https://chromedriver.storage.googleapis.com/${GOOGLE_CHROME_VERSION}/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm chromedriver_linux64.zip

# Install Robot Framework and associated libraries
RUN pip3 install \
  --no-cache-dir \
  robotframework==$ROBOT_FRAMEWORK_VERSION \
  robotframework-browser==$BROWSER_LIBRARY_VERSION \
  robotframework-databaselibrary==$DATABASE_LIBRARY_VERSION \
  robotframework-datadriver==$DATADRIVER_VERSION \
  robotframework-datadriver[XLS] \
  robotframework-datetime-tz==$DATETIMETZ_VERSION \
  robotframework-faker==$FAKER_VERSION \
  robotframework-ftplibrary==$FTP_LIBRARY_VERSION \
  robotframework-imaplibrary2==$IMAP_LIBRARY_VERSION \
  robotframework-pabot==$PABOT_VERSION \
  robotframework-requests==$REQUESTS_VERSION \
  robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
  robotframework-sshlibrary==$SSH_LIBRARY_VERSION \
  axe-selenium-python==$AXE_SELENIUM_LIBRARY_VERSION \
  # Install awscli to be able to upload test reports to AWS S3
  awscli==$AWS_CLI_VERSION \
  # Install an older Selenium version to avoid issues when running tests
  # https://github.com/robotframework/SeleniumLibrary/issues/1835
  selenium==4.9.0

# Playwright deps
RUN npx playwright install-deps

# Install Microsoft Edge & webdriver
RUN wget -q "https://packages.microsoft.com/keys/microsoft.asc" -O- | apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | tee /etc/apt/sources.list.d/microsoft-edge.list \
  && apt-get update && \
    apt-get install -y \
    microsoft-edge-stable=${MICROSOFT_EDGE_VERSION}-1 \
    wget \
zip && \
    wget -q "https://msedgedriver.azureedge.net/${MICROSOFT_EDGE_VERSION}/edgedriver_linux64.zip" && \
    unzip edgedriver_linux64.zip -d edge && \
    mkdir -p /opt/robotframework/drivers && \
    mv edge/msedgedriver /opt/robotframework/drivers/msedgedriver && \
    rm -Rf edgedriver_linux64.zip edge/ && \
    apt-get remove -y \
    zip && \
    apt-get autoremove -y

ENV PATH=/opt/microsoft/msedge:$PATH

# FIXME: Playwright currently doesn't support relying on system browsers, which is why the `--skip-browsers` parameter cannot be used here.
RUN rfbrowser init

# Create the default report and work folders with the default user to avoid runtime issues
# These folders are writeable by anyone, to ensure the user can be changed on the command line.
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR}

# Allow any user to write logs
RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

# Set up a volume for the generated reports
VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

# A dedicated work folder to allow for the creation of temporary files
WORKDIR ${ROBOT_WORK_DIR}

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
