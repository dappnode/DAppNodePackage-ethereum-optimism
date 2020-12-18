#!/bin/sh
touch /usr/src/app/wallet/wallet.env
node /usr/src/app/createKey.js
exec /opt/wait-for-l1-and-l2.sh run-fraud-prover.js
