import time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class Handler(FileSystemEventHandler):
    def on_any_event(self, event):
        if event.event_type == "modified":
            # pylint: disable=fixme
            # TODO: Here we want to run the file tests instead of displaying its path
            print(f"Received modified event - {event.src_path}.")
            return None
        if event.is_directory:
            return None
        if event.event_type == "created":
            return None
        return None


class FilesystemWatcher:
    def __init__(self, root_dir: Path):
        self._root_dir = root_dir

    def start(self):
        event_handler = Handler()
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
