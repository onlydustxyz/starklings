# Deploy

Prerequisitory: set ADMIN environment variable with the address of the account 
that will be the administrator (ie. owner) of the games.

```sh
export ADMIN="0x2fe83d7f898b275ca82ccaf6146b49f4827fb1b1415d3973d714874588b313d"
```

## Deploy OnlyDust ERC20

```sh
nile run ./scripts/deploy-only-dust-erc20.py
```

## Deploy Boarding Pass (ERC721)

```sh
nile run ./scripts/deploy-starkonquest-boarding-pass.py
```

## Deploy Tournament

```sh
export SEASON_ID=1
export SHIPS_PER_BATTLE=2
export MAX_PLAYER=16
nile run ./scripts/deploy-tournament.py
```

## Deploy Space

```sh
export SPACE_SIZE=100
export TURN_COUNT=50
export MAX_DUST=20
nile run ./scripts/deploy-space.py
```
