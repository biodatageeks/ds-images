#!/bin/bash
/opt/code-server-*-linux-amd64/bin/code-server --install-extension ms-python.python
/opt/code-server-*-linux-amd64/bin/code-server --auth none --bind-addr 0.0.0.0:7000 --disable-update-check --disable-telemetry -vvv