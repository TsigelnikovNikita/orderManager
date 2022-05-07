// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract OrderManager {
    enum OrderStatus {
        processing,
        complited,
        canceled
    }

    struct Order {
        uint orderDate;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        byte[32] ipfs_hash;
    }

    uint private orderId = 0;
    mapping(uint => Order) private orderes;

    event newOrder(uint orderId);

    function creadeOrder(uint32 _productId, uint32 _productCount, byte[32] memory _ipfs_hash)
        external
        payable
    {
        Order storage newOrder = orderes[orderId];
        newOrder.orderDate = block.timestamp;
        newOrder.productId = _productId;
        newOrder.productCount = _productCount;
        newOrder.status = OrderStatus.processing;
        newOrder.ipfs_hash = _ipfs_hash;
        emit newOrder(orderId);
        orderId++;
    }
}
