from brownie import accounts, exceptions
import pytest

def test_remove_order(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    status = 1
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    orderManager.getOrderById(0)
    orderManager.removeOrder(0)
    with pytest.raises(exceptions.VirtualMachineError) as ex:
        orderManager.getOrderById(0)
    assert "Order doesn't exists" in str(ex.value)
