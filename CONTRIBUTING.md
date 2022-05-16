## Straklings contributing guide

Thank you for investing your time in contributing to our project!

In this guide you will find the necessary instructions to get up and running with developping Starklings new features or fixing some bugs.

---

## Dev environment installation

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

> Troubleshooting: if you run on a Mac m1, you might encounter the following error: `fatal error: 'gmp.h' file not found`
> See https://github.com/OpenZeppelin/nile/issues/22 for detailled solutions.
