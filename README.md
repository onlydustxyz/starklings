<div align="center">
  <h1 align="center">Starklings</h1>
  <p align="center">
    <a href="https://discord.gg/onlydust">
        <img src="https://img.shields.io/badge/Discord-6666FF?style=for-the-badge&logo=discord&logoColor=white">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white">
    </a>       
  </p>
  
  <h3 align="center">An interactive tutorial to get you up and running with Starknet</h3>
</div>

---

## Installation

Clone the repository to your local machine:

```shell
git clone https://github.com/onlydustxyz/starklings.git
```

Then install the tool, run:

```shell
curl -L https://raw.githubusercontent.com/onlydustxyz/starklings/master/install.sh | bash
```

## Usage

Run the tool in watch mode and follow the instructions:

```shell
starklings --watch
```

---

## Development

### Requirements

- [Python >=3.8 <3.9](https://www.python.org/downloads/)

### Setting up environment

1. Install Python version management tool: [pyenv](https://github.com/pyenv/pyenv) or [asdf](https://github.com/asdf-vm/asdf)
2. Install `Python 3.8` using the Python version management tool and activate that version
3. Clone this repository
4. Verify the active Python version: `python -V`
5. Create Python virtual environment in the project directory: `python -m venv env`
6. Activate environment: `source env/bin/activate`
7. Upgrade pip: `pip install --upgrade pip`
8. Install [Poetry](https://python-poetry.org/) — a dependency manager: `pip install poetry`
9. Install project dependencies: `poetry install`

---

## Inspiration

- [Protostar](https://github.com/software-mansion/protostar) for all the project tooling and setup, deployment, packaging
- [Rustlings](https://github.com/rust-lang/rustlings) for the amazing pedagogy and brilliant concept of progressive and interactive tutorial
