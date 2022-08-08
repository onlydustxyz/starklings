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
APP_SETTINGS=config.DevConfig python app.py
```

- Production
```
APP_SETTINGS=config.ProdConfig python app.py
```


## API Documentation


- `/exercise`
Exercise Validation route

1. Headers

| Key  | Value          |
| :--------------- |:---------------:|
| Content-Type  |   application/json      |
| Accept  |   application/json      |

2. Data (JSON)

| Key  | Value          |
| :--------------- |:---------------:|
| wallet_address  |   String: Wallet that wants to verify exercise     |
| exercise  |   String: Concatenated path of the wanted exercise (e.g storage/storage01)      |
| exercise_data  |   String: Cairo file as a string     |

3. Return

On Validation
```
{
    "result": "Exercice Succeed"
}
```

On Error
```
{
    "error": "Cairo Error Msg"
    "result": "Exercice Failed"
}
```