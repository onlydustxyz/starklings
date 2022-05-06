# Taken from https://stackoverflow.com/questions/61476962/python-decorator-for-debouncing-including-function-arguments#:~:text=Debouncing%20means%20to%20supress%20the,if%20no%20new%20function%20calls

import threading


def debounce(wait_time):
    """
    Decorator that will debounce a function so that it is called after wait_time seconds
    If it is called multiple times, will wait for the last call to be debounced and run only this one.
    """

    def decorator(function):
        def debounced(*args, **kwargs):
            def call_function():
                debounced.timer = None
                return function(*args, **kwargs)

            # if we already have a call to the function currently waiting to be executed, reset the timer
            if debounced.timer is not None:
                debounced.timer.cancel()

            # after wait_time, call the function provided to the decorator with its arguments
            debounced.timer = threading.Timer(wait_time, call_function)
            debounced.timer.start()

        debounced.timer = None
        return debounced

    return decorator
