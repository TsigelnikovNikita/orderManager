// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OrderManager is Ownable {
    /*
        Every status presents itself mask. It uses for filtering orders.
        For example if you need to get info only about "sent" and "complited" orders,
        you can just specify mask like "sent | complited".
        See an example in getOrdersList and _getOrdersByFilter methods.
     */
    uint8 public constant processing = 1;
    uint8 public constant sent       = 1 << 1;
    uint8 public constant delivered  = 1 << 2;
    uint8 public constant complited  = 1 << 3;
    uint8 public constant canceled   = 1 << 4;

    struct Order {
        uint orderDate;
        uint price;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        string ipfs_hash;
        address customer;
    }

    uint private UUID = 0;
    uint private availableMoney = 0; 
    mapping(uint => Order) private orders;

    event newOrderCreated(uint orderId);
    event orderWasCanceled(uint orderId, string reason, address by);
    event orderWasSent(uint orderId);
    event orderWasDelivered(uint orderId);
    event orderWasComplited(uint orderId);

    modifier orderIsExists(uint ID) {
        require(orders[ID].status != 0, "Order doesn't exists");
        _;
    }

    function getAvailableMoney()
        external
        view
        onlyOwner
        returns(uint)
    {
        return availableMoney;
    }

    function _payBack(uint ID) internal {
        payable(orders[ID].customer).transfer(orders[ID].price);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(availableMoney);
        availableMoney = 0;
    }

    function creadeOrder(uint32 _productId, uint32 _productCount, string memory _ipfs_hash)
        external
        payable
    {
        Order storage newOrder = orders[UUID];
        newOrder.orderDate = block.timestamp;
        newOrder.price = msg.value;
        newOrder.productId = _productId;
        newOrder.productCount = _productCount;
        newOrder.status = processing;
        newOrder.ipfs_hash = _ipfs_hash;
        newOrder.customer = msg.sender;
        emit newOrderCreated(UUID);
        UUID++;
    }

    function getOrderById(uint ID) external view returns(Order memory) {
        return orders[ID];
    }

    function _getOrdersByFilter(uint8 filter) private view returns(Order[] memory) {
        Order[] memory result = new Order[](UUID);
        uint counter = 0;
        for (uint i = 0; i < UUID; i++) {
            if (orders[i].status & filter != 0) {
                result[counter++] = orders[i];
            }
        }
        return result;
    }

    function getOrdersByFilter(uint8 filter) external view returns(Order[] memory) {
        return _getOrdersByFilter(filter);
    }

    function getOrderesList() external view returns(Order[] memory) {
        return _getOrdersByFilter(processing | complited | canceled);
    }

    function _changeOrderStatus(uint ID, uint8 newStatus)
        internal
        orderIsExists(ID)
        onlyOwner
    {
        orders[ID].status = newStatus;
    }

    function removeOrder(uint ID)
        external
        orderIsExists(ID)
        onlyOwner
    {
        delete orders[ID];
    }

    function cancelOrder(uint ID, string calldata reason)
        external
        orderIsExists(ID)
    {
        require(orders[ID].status == processing, "The order is already was sent");
        require(msg.sender == owner() || msg.sender == orders[ID].customer, "You cannot cancel the order");
        _payBack(ID);
        orders[ID].status = canceled;
        emit orderWasCanceled(ID, reason, msg.sender);
    }

    function sendOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, sent);
        availableMoney += orders[ID].price;
        emit orderWasSent(ID);
    }

    function deliverOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, delivered);
        emit orderWasDelivered(ID);
    }

    function completeOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, complited);
        emit orderWasComplited(ID);
    }
}
