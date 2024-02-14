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
ENV AWS_CLI_VERSION 1.32.31
ENV AXE_SELENIUM_LIBRARY_VERSION 2.1.6
ENV BROWSER_LIBRARY_VERSION 18.0.0
ENV GOOGLE_CHROME_VERSION 121.0.6167.85
ENV FIREFOX_VERSION 122.0.1+build1-0ubuntu0.20.04.1
ENV GECKO_DRIVER_VERSION v0.34.0
ENV DATABASE_LIBRARY_VERSION 1.4.3
ENV DATADRIVER_VERSION 1.10.0
ENV DATETIMETZ_VERSION 1.0.6
ENV MICROSOFT_EDGE_VERSION 121.0.2277.83
ENV FAKER_VERSION 5.0.0
ENV FTP_LIBRARY_VERSION 1.9
ENV IMAP_LIBRARY_VERSION 0.4.6
ENV PABOT_VERSION 2.18.0
ENV REQUESTS_VERSION 0.9.5
ENV ROBOT_FRAMEWORK_VERSION 7.0
ENV SELENIUM_LIBRARY_VERSION 6.2.0
ENV SSH_LIBRARY_VERSION 3.8.0
ENV XVFB_VERSION 1.20
ENV AUTORECORDER_VERSION 0.1.4
ENV NODEJS_VERSION 20.11.0

# By default, no reports are uploaded to AWS S3
ENV AWS_UPLOAD_TO_S3 false

ENV DISPLAY :0

ENV PATH="$PATH:/usr/local/lib/nodejs/node-v${NODEJS_VERSION}-linux-x64/bin:$PATH"

RUN echo $PATH

# Prepare binaries to be executed
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

RUN chmod +x /opt/robotframework/bin/run-tests-in-virtual-screen.sh

# Disable ipv6
RUN sysctl -w net.ipv6.conf.all.disable_ipv6=1 \
    && sysctl -w net.ipv6.conf.default.disable_ipv6=1

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
    xdg-utils \
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
    python3-pip \
    python3-yaml \
    tzdata \
    xvfb \
    dirmngr \
    wget \
    unzip \
    curl \
    # AutoRecorder deps
    python3-gi \
    gobject-introspection \
    python3-gi-cairo \
    gir1.2-gtk-3.0 && \
    rm -rf /var/lib/apt/lists/*

# Install nodejs
RUN wget "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz" \
    && mkdir -p /usr/local/lib/nodejs \
    && tar -xJvf "node-v${NODEJS_VERSION}-linux-x64.tar.xz" -C /usr/local/lib/nodejs

# Install npm
RUN curl -qL https://www.npmjs.com/install.sh | sh
  
RUN wget "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb" \
    && apt install -y ./"google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb" \
    && rm "google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb"

RUN wget "http://security.ubuntu.com/ubuntu/pool/main/f/firefox/firefox_${FIREFOX_VERSION}_amd64.deb" \
    && wget "https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-${GECKO_DRIVER_VERSION}-linux64.tar.gz" \
    && apt install -y ./"firefox_${FIREFOX_VERSION}_amd64.deb" \
    && tar xzf geckodriver-${GECKO_DRIVER_VERSION}-linux64.tar.gz \
    && mkdir -p /opt/robotframework/drivers/ \
    && mv geckodriver /opt/robotframework/drivers/geckodriver \
    && rm "firefox_${FIREFOX_VERSION}_amd64.deb" \
    && rm "geckodriver-${GECKO_DRIVER_VERSION}-linux64.tar.gz"

# Install ChromeDriver
RUN wget -q "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${GOOGLE_CHROME_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip chromedriver-linux64.zip && \
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm chromedriver-linux64.zip

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
  robotframework-autorecorder==$AUTORECORDER_VERSION \
  axe-selenium-python==$AXE_SELENIUM_LIBRARY_VERSION \
  # Install awscli to be able to upload test reports to AWS S3
  awscli==$AWS_CLI_VERSION

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
