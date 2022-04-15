<div align="center">
  <h1 align="center">Starknet Onboarding</h1>
  <p align="center">
    <a href="http://makeapullrequest.com">
      <img alt="pull requests welcome badge" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=Magicdust_gg">
        <img src="https://img.shields.io/twitter/follow/Magicdust_gg?style=social&logo=twitter"
            alt="follow on Twitter"></a>
    <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg"
            alt="License"></a>
    <a href=""><img src="https://img.shields.io/badge/semver-0.0.1-blue"
            alt="License"></a>            
  </p>
  
  <h3 align="center">Starknet onboarding with a game</h3>
</div>

# Environment setup

This repository uses [nile](https://github.com/OpenZeppelin/nile) as CLI tool.

First you need to install python3.8. You can install it using your favorite package manager, or install it in a virtual environment using [conda](https://conda.io/).

## Using conda
Install conda following the instructions on [the website](https://docs.conda.io/en/latest/miniconda.html)

Then create a dedicated virtual environment and activate it

```bash
conda create -n onboarding python=3.8
conda activate onboarding
```

## Not using conda
If you don't use Conda, you need to create a virtualenv and activate it this way:

```bash
python3 -m venv env
source env/bin/activate
```

# How to use this repo

This tutorial has 2 difficulty levels: basic, advanced.

Please checkout the wanted branch to get started:

```bash
git switch basic
# or
git switch advanced
```

_To be continued..._

# Advance workshop

## Initial configuration

Once you have activated your virtual environment, install the required dependencies
```bash
pip install -r requirements.txt # will install cairo-nile
nile install # Will install all required dependencies to build/test/deploy starknet contracts
```

## Deploy

First, start a local node:
```bash
nile node
```

Then, deploy the contracts:
```bash
nile run scripts/deploy.py
```

Keep the addresses of the contract, you'll need them later.

## Goal

Implement your ship to catch as much dust as possible.

## Get started

To add your ship, compile it and deploy it
```bash
nile compile
nile deploy my_ship_contract

🚀 Deploying my_ship_contract
🌕 artifacts/my_ship_contract.json successfully deployed to 0x07ec10eb0758f7b1bc5aed0d5b4d30db0ab3c087eba85d60858be46c1a5e4680
```

Then, add the ship to the game's space
```bash
nile invoke <space-contract-address> add_ship <x> <y> <ship-contract-address>
```

Finally, call `next_turn` to let the game computes the next turn
```bash
nile invoke <space-contract-address> next_turn
```

