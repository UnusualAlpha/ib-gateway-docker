#!/bin/sh

sleep 30

if [ "$TRADING_MODE" = "paper" ]; then
  echo "Forking :::4000 onto 0.0.0.0:4002 for Paper TWS\n"
  socat TCP-LISTEN:4002,fork TCP:127.0.0.1:4000
else
  echo "Forking :::4000 onto 0.0.0.0:4001 for Live TWS\n"
  socat TCP-LISTEN:4001,fork TCP:127.0.0.1:4000
fi

# To the best of my knowledge, the fix port does not 
# depend on the mode
echo "Forking :::4020 onto 0.0.0.0:4010 for FIX\n"
socat TCP-LISTEN:4010,fork TCP:127.0.0.1:4020
