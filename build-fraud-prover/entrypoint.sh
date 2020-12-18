#!/bin/sh
touch /usr/src/app/wallet/wallet.env
node /usr/src/app/createKey.js
source /usr/src/app/wallet/wallet.env
exec /opt/wait-for-l1-and-l2.sh run-fraud-prover.js
