Initial docker container structure to simmulate sub-set of Strata infrastructure.
Only for local development.

Just start (opt. in demon mod):
```
    docker-compose up -d
```

To inspect the log files:
```
    docker-compose logs -f
```
After couple of seconds CB is up, then open following address http://localhost:8091 and configure
the server (with respect to sync-cb json config file).

Notes:
- sync-gw:
    * it starts much faster in compare to CB server
    * keep it auto-restarting until CB is configured/started
    * this may be solved via health-check script (future work, maybe)
- nginx
    * it is only a local http-based file server simulation

