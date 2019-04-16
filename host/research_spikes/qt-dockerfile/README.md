
In order to run the docker container and be able to view Qt gui x11 forwarding should be enabled on the host machine.

To build the image `Docker build -t qtimage .`
To run the image onm mac `docker run -it --name qtimage -e DISPLAY=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}'):0 -v /tmp/.X11-unix:/tmp/.X11-unix -v <Path to spyglass reppo>:/spyglass --privileged qtimage`

to be able to build Strata there are couple of modifications on CMake files that need to done (they are not necessary for UI development):
1. Disable building HSC.
2. Disable building the Platform Registration Tool.
3. Disable building Couchbase.