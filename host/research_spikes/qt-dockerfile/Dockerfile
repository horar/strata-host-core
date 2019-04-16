
FROM ubuntu:18.04

# install the dependencies 
RUN apt-get update && apt-get install -y cmake build-essential wget libfontconfig libdbus-glib-1-2 libX11* unzip
RUN apt-get install -y libfontconfig1-dev libfreetype6-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev
RUN apt-get install -y libxcb-keysyms1-dev \
                    libxcb-image0-dev \
                    libxcb-shm0-dev \
                    libxcb-icccm4-dev \
                    libxcb-sync0-dev \
                    libxcb-xfixes0-dev \
                    libxcb-shape0-dev \
                    libxcb-randr0-dev \
                    libxcb-render-util0-dev \
                    libgl1-mesa-dev \
                    mesa-common-dev \
                    libfontconfig1 \
                    libxkbcommon-dev \
                    libxkbcommon-x11-0 \
                    libxcursor1 \
                    libasound2 \
                    libxcomposite1 \
                    libnss3 

# install Qt 5.12.2
RUN wget https://download.qt.io/archive/qt/5.12/5.12.2/qt-opensource-linux-x64-5.12.2.run
# COPY qt-opensource-linux-x64-5.12.2.run ./qt-opensource-linux-x64-5.12.2.run # downloaded qt localy to make things faster
RUN chmod +x ./qt-opensource-linux-x64-5.12.2.run
COPY qt-noninteractive.qs /qt-noninteractive.qs
RUN ./qt-opensource-linux-x64-5.12.2.run --script qt-noninteractive.qs --platform minimal --verbose
RUN rm -rf ./qt-opensource-linux-x64-5.12.2.run qt-noninteractive.qs 
# add qt to the path
RUN export PATH=/opt/Qt5.12.2/5.12.2/gcc_64/bin:$PATH
RUN export PATH=/opt/Qt5.12.2/Tools/QtCreator/:$PATH
