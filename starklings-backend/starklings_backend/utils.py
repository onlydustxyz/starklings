import requests
import json
import os
import re
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.networks import TESTNET, MAINNET
from starknet_py.contract import Contract
import asyncio


regex = re.compile(r"([A-Za-z0-9]+[.-_])*[A-Za-z0-9]+@[A-Za-z0-9-]+(\.[A-Z|a-z]{2,})+")


def verify_email(email):
    if re.fullmatch(regex, email):
        return True
    else:
        return False


class Requester:
    def __init__(self, base_url, **kwargs):
        self.base_url = base_url
        self.session = requests.Session()
        for arg in kwargs:
            if isinstance(kwargs[arg], dict):
                kwargs[arg] = self.__deep_merge(getattr(self.session, arg), kwargs[arg])
            setattr(self.session, arg, kwargs[arg])

    def request(self, method, url, **kwargs):
        return self.session.request(method, self.base_url + url, **kwargs)

    def head(self, url, **kwargs):
        return self.session.head(self.base_url + url, **kwargs)

    def get(self, url, **kwargs):
        return self.session.get(self.base_url + url, **kwargs)

    def post(self, url, data, **kwargs):
        return self.session.post(self.base_url + url, data=data, **kwargs)

    def put(self, url, **kwargs):
        return self.session.put(self.base_url + url, **kwargs)

    def patch(self, url, **kwargs):
        return self.session.patch(self.base_url + url, **kwargs)

    def delete(self, url, **kwargs):
        return self.session.delete(self.base_url + url, **kwargs)

    @staticmethod
    def __deep_merge(source, destination):
        for key, value in source.items():
            if isinstance(value, dict):
                node = destination.setdefault(key, {})
                Requester.__deep_merge(value, node)
            else:
                destination[key] = value
        return destination


class VerifySignature:
    SUPPORTED_NETWORKS = ["mainnet", "testnet"]

    def __init__(self, abi, network, contract_address):
        with open(abi, "r") as reader:
            abi = json.load(reader)
        assert network in self.SUPPORTED_NETWORKS
        network = self.set_network(network)
        self.contract = Contract(
            contract_address,
            abi,
            network,
        )

    def set_network(self, network):
        if network == "testnet":
            return GatewayClient(TESTNET)
        elif network == "mainnet":
            return GatewayClient(MAINNET)

    def __call__(self, message_hash, signature):
        try:

            asyncio.run(
                self.contract.functions["is_valid_signature"].call(
                    message_hash, (signature[0], signature[1])
                )
            )
            return "Valid Signature", None
        except Exception as e:
            return "Invalid Signature", 400