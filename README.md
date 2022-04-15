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

# Initial configuration

Once you have activated your virtual environment, install the required dependencies
```bash
pip install -r requirements.txt # will install cairo-nile
nile install # Will install all required dependencies to build/test/deploy starknet contracts
```

# What to do ?

Run:
```
pytest tests/test_ex00.py 
```

It return errors.  
Edit the `contracts/ex00.cairo` file until all tests pass.  
There are instructions as comments to help you.

Repeat for all contracts. Have fun !

Once you are done with all five exercises you can try a bonus one.
Try to emit an event each time an user ranks change, and catch this event on the layer one. Then do whatever you want with it: emit another event, mint an NFT, do a firework. The objective is for you to learn how to do layer 2 -> layer 1 messaging. And if you are curious, maybe try messaging the other direction.