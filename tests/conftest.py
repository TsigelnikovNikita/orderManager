import pytest
from brownie import accounts, OrderManager

@pytest.fixture
def owner():
    return accounts[0]

@pytest.fixture
def orderManager(owner):
    return OrderManager.deploy({'from': owner})
