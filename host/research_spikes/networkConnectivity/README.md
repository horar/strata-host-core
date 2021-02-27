# Strata Network connectivity

* strataClient: An application that act as a Strata Platform which
  can broadcast itself and listens for upcoming TCP connection from
  Strata Host.

* strataHost: An application that act as a Strata Host that listens
  for broadcast messages and when a certain message is found, it
  initiates a TCP connection with Strata platform. The application
  also supports multiple clients connections.