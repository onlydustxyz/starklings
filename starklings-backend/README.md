# Starklings API

Starklings backend within a single Flask API

## Installation Setup

- Tested with Python >=3.8

#### 1. Starlings Installation

Make sure you installed starlings at first :
```
cd ../
pip install poetry
poetry install

# or on MAC M1 : 
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib poetry install
```

#### 2. Flask Installation

```
python -m venv starklings-venv
source starklings-venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Launch API

- Development
```
FLASK_ENV=development flask run
```

- Production
```
FLASK_ENV=production flask run
```


## API Documentation


