from brownie import accounts, chain

def test_create_order(orderManager):
    price = 10 ** 18
    productId = 123
    productCount = 2
    status = 1
    ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
    customer = accounts[1]

    orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
    orderDate = chain[-1].timestamp
    order = orderManager.getOrderById(0)

    assert order[0] == orderDate
    assert order[1] == price
    assert order[2] == productId
    assert order[3] == productCount
    assert order[4] == status
    assert order[5] == ipfs_hash
    assert order[6] == customer
