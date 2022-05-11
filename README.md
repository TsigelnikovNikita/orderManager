# orderManager

### Description of smart contract
This smart contract is designed for accepting and managering orders in the shop. A customer can create a new order. Customer sends his encrypted address using public key of the owner. Every order has status: processing, sent, delivered, complited and canceled. Customer or owner can cancel an order if order is in the "processing" status. Also you can get orders list or remove orders by filter using status (for example to get info only about "sent" and "complited" orders) or timestamp. Here I used filtering by [bit masking](https://en.wikipedia.org/wiki/Mask_(computing)). Remove orders can only owner of course.

### Stack
The smart contract is written using Solidity for the Ethereum blockchain. 
I used to [brownie](https://eth-brownie.readthedocs.io/en/stable/) as a development environment framework.

### How to install
- First you need to clone this repo to your machine:<br>
  ```git clone https://github.com/TsigelnikovNikita/orderManager.git```
- Then you need to install brownie (you can create a special venv or install in the global env. It's up to you):<br>
   ```pip install eth-brownie```
- After that you need to check that you have an installed brownie framework:<br>
  ```brownie```
- The last one is just compiling the contract!:<br>
  ```brownie compile ```

### Unit-tests
This contract has unit-tests. You can run these using:<br>
```brownie test```

### Proposal and remarks
It's just a study work. If you have any proposals or remarks please feel free and let me know about it.
