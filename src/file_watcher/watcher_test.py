from pathlib import Path
from time import sleep
from src.file_watcher.watcher import FileWatcher


def test_file_watcher(mocker):
    current_directry = Path(__file__).parent
    dummy_file_path = current_directry / "dummy_file.cairo"
    watcher = FileWatcher(current_directry)
    stub = mocker.stub()
    watcher.start(stub)

    assert stub.call_count == 0
    content = None
    with open(dummy_file_path, "r+", encoding="utf-8") as dummy_file:
        content = dummy_file.read()
        dummy_file.write("dummy")

    sleep(0.2)

    try:
        assert stub.call_count == 1
        assert stub.call_args[0][0].src_path in str(dummy_file_path)
    finally:
        with open(dummy_file_path, "w", encoding="utf-8") as dummy_file:
            dummy_file.write(content)
