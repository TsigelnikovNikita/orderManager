import pytest
from brownie import accounts, chain

def test_get_orders_list(orderManager):
    expected_orders = []
    for i in range(10):
        price = i * (10 ** 18)
        productId = i + 12
        productCount = i
        status = 1
        ipfs_hash = 'QmTfCejgo2wTwqnDJs8Lu1pCNeCrCDuE4GAwkna93zdd7d'
        customer = accounts[(i + 1) % 10]

        orderManager.creadeOrder(productId, productCount, ipfs_hash, {'from': customer, 'amount': price})
        orderDate = chain[-1].timestamp

        expected_orders.append(
                (orderDate, price, productId, productCount, status, ipfs_hash, customer)
            )

    orders = orderManager.getOrdersList()
    for order, expected_order in zip(orders, expected_orders):
            assert order[0] == expected_order[0]
            assert order[1] == expected_order[1]
            assert order[2] == expected_order[2]
            assert order[3] == expected_order[3]
            assert order[4] == expected_order[4]
            assert order[5] == expected_order[5]
            assert order[6] == expected_order[6]
