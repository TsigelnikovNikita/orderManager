// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderManager {
    uint8 private processing = 1;
    uint8 private complited  = 1 << 1;
    uint8 private canceled   = 1 << 2;

    struct Order {
        uint orderDate;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        bytes1[32] ipfs_hash;
    }

    uint private orderId = 0;
    mapping(uint => Order) private orderes;

    event newOrderCreated(uint orderId);

    function creadeOrder(uint32 _productId, uint32 _productCount, bytes1[32] memory _ipfs_hash)
        external
        payable
    {
        Order storage newOrder = orderes[orderId];
        newOrder.orderDate = block.timestamp;
        newOrder.productId = _productId;
        newOrder.productCount = _productCount;
        newOrder.status = processing;
        newOrder.ipfs_hash = _ipfs_hash;
        emit newOrderCreated(orderId);
        orderId++;
    }

    function getOrderById(uint ID) external view returns(Order memory) {
        return orderes[ID];
    }

    function _getOrderesByFilter(uint8 filter) private view returns(Order[] memory) {
        Order[] memory result = new Order[](orderId);
        uint counter = 0;
        for (uint i = 0; i < orderId; i++) {
            if (orderes[i].status & filter != 0) {
                result[counter++] = orderes[i];
            }
        }
        return result;
    }

    function getOrderesByFilter(uint8 filter) external view returns(Order[] memory) {
        return _getOrderesByFilter(filter);
    }

    function getOrderesList() external view returns(Order[] memory) {
        return _getOrderesByFilter(processing | complited | canceled);
    }
}
