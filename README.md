<div align="center">
  <h1 align="center">Starknet Onboarding</h1>
  <p align="center">
    <a href="http://makeapullrequest.com">
      <img alt="pull requests welcome badge" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/twitter/follow/onlydust_xyz?style=social&logo=twitter"
            alt="follow on Twitter"></a>
    <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg"
            alt="License"></a>
    <a href=""><img src="https://img.shields.io/badge/semver-0.0.1-blue"
            alt="License"></a>            
  </p>
  
  <h3 align="center">Starknet onboarding with a game</h3>
</div>

# Environment setup

## Prerequisites

- [Python <=3.8](https://www.python.org/downloads/)

## Installation

- `python -m venv env`
- `source env/bin/activate`
- `pip install -r requirements.txt`
- `nile install`

# How to use this repo

## Tutorial

This repo has 2 difficulty levels: beginner and advanced.

`contracts<beginner/advanced>/ex` contrains exercises with instructions on what to do.  
Run `pytest tests/test_<beginner/advanced>_ex00.py --runworkshop` and code until the tests pass.

Repeat for all contracts. Have fun!
