import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--runworkshop", action="store_true", default=False, help="run workshop tests"
    )


def pytest_configure(config):
    config.addinivalue_line("markers", "workshop: mark test as workshop tests to run")


def pytest_collection_modifyitems(config, items):
    if config.getoption("--runworkshop"):
        # --runworkshop given in cli: do not skip workshop tests
        return
    skip_workshop = pytest.mark.skip(reason="need --runworkshop option to run")
    for item in items:
        if "workshop" in item.keywords:
            item.add_marker(skip_workshop)
