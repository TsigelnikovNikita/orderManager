// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract OrderManager {
    uint private orderId = 0;

    struct Order {
        uint orderDate;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        byte[32] ipfs_hash;
    }

    mapping(uint => Order) private orderes;

    function creadeOrder(uint32 _productId, uint32 _productCount, byte[32] memory _ipfs_hash)
        external
        payable
    {
        Order storage newOrder = orderes[orderId++];
        newOrder.orderDate = block.timestamp;
        newOrder.productId = _productId;
        newOrder.productCount = _productCount;
        newOrder.status = 1; // TODO temporary
        newOrder.ipfs_hash = _ipfs_hash;
    }
}
