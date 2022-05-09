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
    uint8 public constant PROCESSING  = 1; // 1 << 1
    uint8 public constant SENT        = 2; // 1 << 2
    uint8 public constant DELIVERED   = 4; // 1 << 3
    uint8 public constant COMPLITED   = 8; // 1 << 4
    uint8 public constant CANCELED    = 16; // 1 << 5
    uint8 public constant ALL_STATUSES = 31;

    struct Order {
        uint orderDate;
        uint price;
        uint32 productId;
        uint32 productCount;
        uint8 status;
        string ipfs_hash;
        address customer;
    }

    uint private UUID;
    uint private availableMoney; 
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

    function _payBack(uint ID) private {
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
        newOrder.status = PROCESSING;
        newOrder.ipfs_hash = _ipfs_hash;
        newOrder.customer = msg.sender;
        emit newOrderCreated(UUID);
        UUID++;
    }

    function getOrderById(uint ID)
        external
        view
        orderIsExists(ID)
        returns(Order memory) {
        return orders[ID];
    }

    function _getOrdersByFilter(uint8 filter) private view returns(Order[] memory) {
        Order[] memory result = new Order[](UUID);
        uint counter;
        for (uint i; i < UUID; i++) {
            if (orders[i].status & filter != 0) {
                result[counter++] = orders[i];
            }
        }
        return result;
    }

    function getOrdersByFilter(uint8 filter) external view returns(Order[] memory) {
        return _getOrdersByFilter(filter);
    }

    function getOrdersList() external view returns(Order[] memory) {
        return _getOrdersByFilter(ALL_STATUSES);
    }

    function _changeOrderStatus(uint ID, uint8 newStatus)
        private
        orderIsExists(ID)
        onlyOwner
    {
        orders[ID].status = newStatus;
    }

    function _removeOrder(uint ID)
        orderIsExists(ID)
        private
    {
        delete orders[ID];
    }

    function removeOrder(uint ID)
        external
        onlyOwner
    {
        _removeOrder(ID);
    }

    function _removeOrdersByFilter(uint filter)
        private
        returns(uint)
    {
        uint removedOrdersCount;
        for (uint i; i < UUID; i++) {
            if (orders[i].status & filter != 0) {
                _removeOrder(i);
                removedOrdersCount++;
            }
        }
        return removedOrdersCount;
    }

    function removeOrdersByFilter(uint filter)
        external
        onlyOwner
        returns(uint)
    {
        return _removeOrdersByFilter(filter);
    }

    function removeOrdersByInterval(uint from, uint to)
        external
        onlyOwner
        returns(uint)
    {
        require(from < to);
        uint removedOrdersCount;
        for (uint i; i < UUID; i++) {
            if (from <= orders[i].orderDate && orders[i].orderDate <= to) {
                _removeOrder(i);
                removedOrdersCount++;
            }
        }
        return removedOrdersCount;
    }

    function removeAllOrders()
        external
        onlyOwner
    {
        _removeOrdersByFilter(ALL_STATUSES);
        UUID = 0;
    }

    function cancelOrder(uint ID, string calldata reason)
        external
        orderIsExists(ID)
    {
        require(orders[ID].status == PROCESSING, "The order is already was sent");
        require(msg.sender == owner() || msg.sender == orders[ID].customer, "You cannot cancel the order");
        _payBack(ID);
        orders[ID].status = CANCELED;
        emit orderWasCanceled(ID, reason, msg.sender);
    }

    function sendOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, SENT);
        availableMoney += orders[ID].price;
        emit orderWasSent(ID);
    }

    function deliverOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, DELIVERED);
        emit orderWasDelivered(ID);
    }

    function completeOrder(uint ID)
        external
    {
        _changeOrderStatus(ID, COMPLITED);
        emit orderWasComplited(ID);
    }
}
