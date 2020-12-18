FROM node:lts-alpine3.10

COPY --from=ethereumoptimism/fraud-prover:latest /opt/optimism-ts-services /opt/optimism-ts-services

WORKDIR /usr/src/app

RUN ln -s /opt/optimism-ts-services/exec/run-fraud-prover.js \
    /usr/local/bin/

COPY createKey.js /usr/src/app/createKey.js
COPY wait-for-l1-and-l2.sh /opt/wait-for-l1-and-l2.sh
RUN apk add -u bash curl jq && \
    npm i fs-promise && \
    npm i @ethersproject/wallet

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT [ "entrypoint.sh" ]