// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OrderManager is Ownable {
    uint8 private constant processing = 1;
    uint8 private constant sent       = 1 << 1;
    uint8 private constant delivered  = 1 << 2;
    uint8 private constant complited  = 1 << 3;
    uint8 private constant canceled   = 1 << 4;

    struct Order {
        uint orderDate;
        uint price;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        bytes1[32] ipfs_hash;
        address customer;
    }

    uint private orderId = 0;
    uint private availableMoney = 0; 
    mapping(uint => Order) private orderes;

    event newOrderCreated(uint orderId);

    modifier orderIsExists(uint ID) {
        require(orderes[ID].status != 0, "Order doesn't exists");
        _;
    }

    function _payBack(uint ID) internal {
        payable(orderes[ID].customer).transfer(orderes[ID].price);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(availableMoney);
        availableMoney = 0;
    }

    function creadeOrder(uint32 _productId, uint32 _productCount, bytes1[32] memory _ipfs_hash)
        external
        payable
    {
        Order storage newOrder = orderes[orderId];
        newOrder.orderDate = block.timestamp;
        newOrder.price = msg.value;
        newOrder.productId = _productId;
        newOrder.productCount = _productCount;
        newOrder.status = processing;
        newOrder.ipfs_hash = _ipfs_hash;
        newOrder.customer = msg.sender;
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

    function changeOrderStatus(uint ID, uint8 newStatus)
        external
        orderIsExists(ID)
        onlyOwner
    {
        orderes[ID].status = newStatus;
    }

    function removeOrder(uint ID)
        external
        orderIsExists(ID)
        onlyOwner
    {
        delete orderes[ID];
    }

    function cancelOrder(uint ID, string calldata reason) external {
        require(orderes[ID].status == processing, "The order is already was sent");
        require(msg.sender == owner() || msg.sender == orderes[ID].customer, "You cannot cancel the order");
        _payBack(ID);
        orderes[ID].status = canceled;
        availableMoney -= orderes[ID].price;
    }

    function sendOrder(uint ID) external onlyOwner {
        orderes[ID].status = sent;
        availableMoney += orderes[ID].price;
    }

    function deliverOrder(uint ID) external onlyOwner {
        orderes[ID].status = delivered;
    }

    function completeOrder(uint ID) external onlyOwner {
        orderes[ID].status = complited;
    }
}
