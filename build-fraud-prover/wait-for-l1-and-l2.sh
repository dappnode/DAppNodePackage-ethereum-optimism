#!/bin/bash

# Copyright Optimism PBC 2020
# MIT License
# github.com/ethereum-optimism

source /usr/src/app/wallet/wallet.env
cmd="$@"
JSON='{"jsonrpc":"2.0","id":0,"method":"net_version","params":[]}'

RETRIES=20
until $(curl --silent --fail \
    --output /dev/null \
    -H "Content-Type: application/json" \
    --data "$JSON" "$L1_NODE_WEB3_URL"); do
  sleep 1
  echo "Will wait $((RETRIES--)) more times for $L1_NODE_WEB3_URL to be up..."

  if [ "$RETRIES" -lt 0 ]; then
    echo "Timeout waiting for layer one node at $L1_NODE_WEB3_URL"
    exit 1
  fi
done
echo "Connected to L1 Node at $L1_NODE_WEB3_URL"

until [ $(curl --silent -X POST \
    -H "Content-Type: application/json" \
    --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"${L1_WALLET_ADDRESS}\",\"latest\"],\"id\":1}" \
    "$L1_NODE_WEB3_URL" | jq .result | tr -d "\"" ) != "0x0" ]
do
  echo "Not enough balance in wallet ${L1_WALLET_ADDRESS}. Please, obtain some KovanETH in this faucet: https://kovan.faucet.enjin.io/ or ask in gitter https://gitter.im/kovan-testnet/faucet"
  sleep 10
done

echo "${L1_WALLET_ADDRESS} is funded"

RETRIES=30
until $(curl --silent --fail \
    --output /dev/null \
    -H "Content-Type: application/json" \
    --data "$JSON" "$L2_NODE_WEB3_URL"); do
  sleep 1
  if [ ! -z "$NO_TIMEOUT" ]; then
      echo "Waiting for $L2_NODE_WEB3_URL to be up..."
      sleep 30
  elif [ "$RETRIES" -lt 0 ]; then
    echo "Timeout waiting for layer two node at $L2_NODE_WEB3_URL"
    exit 1
  else
    echo "Will wait $((RETRIES--)) more times for $L2_NODE_WEB3_URL to be up..."
  fi
done
echo "Connected to L2 Node at $L2_NODE_WEB3_URL"

if [ ! -z "$DEPLOYER_HTTP" ]; then
    RETRIES=20
    until $(curl --silent --fail \
        --output /dev/null \
        "$DEPLOYER_HTTP/addresses.json"); do
      sleep 1
      echo "Will wait $((RETRIES--)) more times for $DEPLOYER_HTTP to be up..."

      if [ "$RETRIES" -lt 0 ]; then
        echo "Timeout waiting for contract deployment"
        exit 1
      fi
    done
    echo "Contracts are deployed"
    ADDRESS_MANAGER_ADDRESS=$(curl --silent $DEPLOYER_HTTP/addresses.json | jq -r .AddressManager)
    exec env \
        ADDRESS_MANAGER_ADDRESS=$ADDRESS_MANAGER_ADDRESS \
        $cmd
else
    exec $cmd
fi