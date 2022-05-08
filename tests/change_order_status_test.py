import pytest
from brownie import accounts, exceptions

def test_change_order_status_to_sent(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]
    expected_status = orderManager.sent()

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    orderManager.sendOrder(0)
    order = orderManager.getOrderById(0)

    assert order[4] == expected_status

def test_change_order_status_to_delivered(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]
    expected_status = orderManager.delivered()

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    orderManager.deliverOrder(0)
    order = orderManager.getOrderById(0)

    assert order[4] == expected_status

def test_change_order_status_to_complited(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]
    expected_status = orderManager.complited()

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    orderManager.completeOrder(0)
    order = orderManager.getOrderById(0)

    assert order[4] == expected_status

def test_change_order_status_to_canceled(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]

    prev_customer_balance = customer.balance()
    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    assert customer.balance() == prev_customer_balance - price

    prev_customer_balance = customer.balance()
    orderManager.cancelOrder(0, "reason")
    assert customer.balance() == prev_customer_balance + price

def test_change_order_status_by_not_owner(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    with pytest.raises(exceptions.VirtualMachineError) as ex:
        orderManager.completeOrder(0, {'from': customer})
    assert "Ownable: caller is not the owner" in str(ex.value)
