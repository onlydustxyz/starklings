import os


def protostar_bin():
    home = os.environ.get("HOME")
    return f"{home}/.protostar/dist/protostar/protostar"
