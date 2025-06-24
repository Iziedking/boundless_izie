#!/usr/bin/env bash
set -euo pipefail

# ----- configurable -------------------------------------------------
USDC_AMT=100000            # 0.1 USDC (6 decimals)
ETH_WEI=10000000000000     # 0.00001 ETH (10^13 wei)

USDC=0x833589FCD6eDb6E08f4c7C32D4f71B54bdA02913
MARKET=0x26759dBb201aFbA361Bec78E097Aa3942B0b4AB8
RPC=https://mainnet.base.org
GAS=25000000000            # 25 gwei
# -------------------------------------------------------------------

# Ask for PRIVATE_KEY if not already set
if [[ -z "${PRIVATE_KEY:-}" ]]; then
  read -rsp "Enter PRIVATE_KEY (0x…): " PRIVATE_KEY
  echo
fi

echo "→ Approving 0.1 USDC…"
cast send "$USDC" "approve(address,uint256)" "$MARKET" "$USDC_AMT" \
  --private-key "$PRIVATE_KEY" --rpc-url "$RPC" --type 2 --gas-price "$GAS"

echo "→ Depositing USDC stake…"
cast send "$MARKET" "depositStake(uint256)" "$USDC_AMT" \
  --private-key "$PRIVATE_KEY" --rpc-url "$RPC" --type 2 --gas-price "$GAS"

echo "→ Staking 0.00001 ETH…"
cast send "$MARKET" "stake()" \
  --value "$ETH_WEI" \
  --private-key "$PRIVATE_KEY" --rpc-url "$RPC" --type 2 --gas-price "$GAS"

echo "✓ All done — wait one block, then refresh Guild.xyz"

