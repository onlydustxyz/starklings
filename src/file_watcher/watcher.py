import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from src.utils.debounce import debounce


class Handler(FileSystemEventHandler):
    def __init__(self, callback):
        self._callback = debounce(0.1)(callback)

    def on_any_event(self, event):
        if event.event_type == "modified":
            self._callback(event)


class FileWatcher:
    def __init__(self, root_dir: Path):
        self._root_dir = root_dir

    def start(self, callback):
        event_handler = Handler(callback)
        observer = Observer()
        observer.schedule(event_handler, self._root_dir, recursive=True)
        observer.start()
        try:
            while True:
                time.sleep(5)
        # pylint: disable=broad-except
        except Exception:
            observer.stop()
            print("Error")

        observer.join()
