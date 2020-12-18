#!/bin/sh
touch /usr/src/app/wallet/wallet.env
node /usr/src/app/createKey.js
. /usr/src/app/wallet/wallet.env
exec env \
    L1_WALLET_KEY=$L1_WALLET_KEY \
    /opt/wait-for-l1-and-l2.sh run-fraud-prover.js
