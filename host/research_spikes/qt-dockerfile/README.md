
In order to run the docker container and be able to view Qt gui x11 forwarding should be enabled on the host machine.

1. Build the image `docker build -t qtimage:5.12.3 .`
2. Run the image `docker run -it --privileged -e DISPLAY=host.docker.internal:0 -v <PATH_TO_SPYGLASS>:/spyglass --name qtcreator-container qtimage:5.12.3`
3. to be able to build Strata there are couple of modifications on CMake files that need to done (they are not necessary for UI development):
	- Disable building the Platform Registration Tool.
	- Disable building Couchbase.

3. Run `qtcreator` to open Qtcreator
