import time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class Handler(FileSystemEventHandler):
    @staticmethod
    def on_any_event(event):
        if event.event_type == "modified":
            # TODO: Here we want to run the file tests instead of displaying its path
            print("Received modified event - {}.".format(event.src_path))
            return None
        elif event.is_directory:
            return None
        elif event.event_type == "created":
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
        except:
            observer.stop()
            print("Error")

        observer.join()
