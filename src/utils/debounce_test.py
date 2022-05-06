from time import sleep
from .debounce import debounce


def test_debounce(mocker):
    stub = mocker.stub()

    @debounce(0.1)
    def debounced_function():
        stub()

    debounced_function()
    debounced_function()

    sleep(0.2)

    assert stub.call_count == 1
