//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract DutchAuction {
    
    struct Product {
        address owner;
        string name;
        uint productId;
        uint orignalPrice;
        bool ifSold;

    }

    Product[] public products;

    mapping(address => Product[]) public isOwned;

    modifier NotSold(uint _productId) {
        require(!products[_productId - 1].ifSold, "Product has already been sold!");
        _;
    }

    function listProduct(string memory _name, uint _orignalPrice) external {
        // products.push({name: _name, orignalPrice: _orignalPrice, initialDiscount: _initialDiscount, productId : products.length, currentPrice: _orignalPrice *(_initialDiscount/100)});
        
        Product memory newProduct = Product({
        owner: msg.sender,
        name: _name,
        productId: products.length + 1,
        orignalPrice: _orignalPrice,
        ifSold: false
    });

    products.push(newProduct);

    }

    function getProductPrice(uint _productId) external NotSold(_productId)  view returns(uint) {
        return products[_productId - 1].orignalPrice;
    }

    function reducePrice(uint _amountToBeReduced, uint _productId) external NotSold(_productId){
        require(msg.sender == products[_productId - 1].owner, "You are not the owner of this product!");
        Product storage product = products[_productId - 1];
        product.orignalPrice -= _amountToBeReduced;
    } 

    function buyProduct(uint _productId) external payable NotSold(_productId) {
        require(msg.sender.balance >= products[_productId - 1].orignalPrice, "Insufficient Balance!");
        require(msg.value == products[_productId - 1].orignalPrice, "Please provide sufficient funds to proceed with transaction!");
        payable(products[_productId - 1].owner).transfer(msg.value);
        

        products[_productId - 1].owner = msg.sender;
        products[_productId - 1].ifSold = true;

        isOwned[msg.sender].push(products[_productId - 1]);
    }
     
}