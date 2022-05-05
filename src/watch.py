import time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class Handler(FileSystemEventHandler):
    @staticmethod
    def on_any_event(event):
        if event.is_directory:
            return None
        elif event.event_type == "created":
            return None
        elif event.event_type == "modified":
            # TODO: Here we want to run the file tests instead of displaying its path
            print("Received modified event - {}.".format(event.src_path))


def watch(dir_path: Path):
    event_handler = Handler()
    observer = Observer()
    observer.schedule(event_handler, dir_path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(5)
    except:
        observer.stop()
        print("Error")

    observer.join()
