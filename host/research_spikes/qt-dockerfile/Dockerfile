
FROM ubuntu:18.04

# Install the dependencies and rquired libraries to run qtcreator and Strata
RUN apt-get update \
        && apt-get install -y \
                    cmake \
                    build-essential \
                    wget \
                    unzip \
                    libxcb-keysyms1-dev \
                    libxcb-image0-dev \
                    libxcb-shm0-dev \
                    libxcb-icccm4-dev \
                    libxcb-sync0-dev \
                    libxcb-xfixes0-dev \
                    libxcb-shape0-dev \
                    libxcb-randr0-dev \
                    libxcb-glx0-dev \
                    libxcb-render-util0-dev \
                    libxcb1-dev \
                    libgl1-mesa-dev \
                    mesa-common-dev \
                    libfontconfig1-dev \
                    libfreetype6-dev \
                    libx11-dev \
                    libxext-dev \
                    libxfixes-dev \
                    libxi-dev \
                    libxrender-dev \
                    libx11-xcb-dev \
                    libfontconfig \
                    libdbus-glib-1-2 \
                    libglib2.0-0 \
                    libgl-dev \
                    libdbus-1-3 \
                    libfontconfig1 \
                    libxkbcommon-dev \
                    libxkbcommon-x11-0 \
                    libxcursor1 \
                    libasound2 \
                    libxcomposite1 \
                    libnss3 \
                    libxtst6 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Install Qt 5.12.2
RUN wget https://download.qt.io/archive/qt/5.12/5.12.2/qt-opensource-linux-x64-5.12.2.run
# COPY qt-opensource-linux-x64-5.12.2.run ./qt-opensource-linux-x64-5.12.2.run 
COPY qt-noninteractive.qs /qt-noninteractive.qs
RUN chmod +x ./qt-opensource-linux-x64-5.12.2.run \
        && ./qt-opensource-linux-x64-5.12.2.run --script qt-noninteractive.qs --platform minimal \
        && rm -rf ./qt-opensource-linux-x64-5.12.2.run qt-noninteractive.qs 

# Add Qt and Qtcreator to the path
ENV PATH="/opt/Qt5.12.2/5.12.2/gcc_64/bin:/opt/Qt5.12.2/Tools/QtCreator/bin:${PATH}"
