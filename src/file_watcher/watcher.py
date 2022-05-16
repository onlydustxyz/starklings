from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from src.utils.debounce import debounce


class Handler(FileSystemEventHandler):
    def __init__(self, callback):
        self._callback = debounce(0.1)(callback)

    def on_modified(self, event):
        self._callback(event)


class FileWatcher:
    def __init__(self, root_dir: Path):
        self._root_dir = root_dir
        self._observer = Observer()

    def start(self, callback):
        event_handler = Handler(callback)
        self._observer.schedule(event_handler, self._root_dir, recursive=True)
        self._observer.start()

    def stop(self):
        self._observer.stop()
        self._observer.join()
