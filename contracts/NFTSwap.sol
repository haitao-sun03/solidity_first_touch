// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC721} from "./ERC721.sol";

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external  returns (bytes4);
}


contract NFTSwap  is IERC721Receiver {
    event List(address owner, address nftAddr,uint256 tokenId,uint256 price);
    event Revoke(address owner,address nftAddr,uint256 tokenId);
    event Update(address owner,address nftAddr,uint256 tokenId,uint256 newPrice);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    // 订单，包含该订单nft的所有者owner以及该nft的卖价
    struct Order {
        address owner;
        uint256 price;
    }
    // nftAddr + tokenId => Order
    mapping(address=>mapping(uint256=>Order)) nftList;

    function list(address nftAddr,uint256 tokenId,uint256 _price) external {
        require(nftList[nftAddr][tokenId].price == 0,"already list");
        require(_price > 0,"price must gt 0");
        IERC721 nft = IERC721(nftAddr);

        nft.safeTransferFrom(msg.sender,address(this), tokenId);
        Order storage order = nftList[nftAddr][tokenId];
        order.owner = msg.sender;
        order.price = _price;

        emit List(msg.sender,nftAddr,tokenId,_price);
    }

     function revoke(address nftAddr,uint256 tokenId) external {
        Order storage order = nftList[nftAddr][tokenId];
        require(order.price > 0,"order not exist");
        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "NFT not in contract");
        require(msg.sender == order.owner, "Only owner can revoke");
        delete nftList[nftAddr][tokenId];
        nft.safeTransferFrom(address(this), msg.sender,tokenId);

        emit Revoke(msg.sender,nftAddr,tokenId);
    }

    function update(address nftAddr,uint256 tokenId,uint256 newPrice) external {
        Order storage order = nftList[nftAddr][tokenId];
        require(order.price > 0,"order not exist");
        order.price = newPrice;

        emit Update(msg.sender,nftAddr,tokenId,newPrice);
    }

    function purchase(address nftAddr,uint256 tokenId) external payable  {
        Order storage order = nftList[nftAddr][tokenId];
        require(order.price > 0,"order not exist");
        require(msg.value >= order.price,"need more ETH");

        delete nftList[nftAddr][tokenId];

        IERC721 nft = IERC721(nftAddr);
        nft.safeTransferFrom(address(this),msg.sender,tokenId);

        (bool success,) = address(order.owner).call{value:order.price}("");
        require(success,"pay owner fail");
        if(msg.value - order.price > 0) {
            (bool success1,) = address(msg.sender).call{value:msg.value - order.price}("");
            require(success1,"refund to puchaser fail");
        }

        

        emit Purchase(msg.sender, nftAddr, tokenId, order.price);
     
    }


    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
    fallback() external {}





}