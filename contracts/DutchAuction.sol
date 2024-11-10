// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IERC721 {
    function transferFrom(address _from,address _to,uint _nftId) external ;    
}

contract DutchAuction {
    IERC721 public immutable nft;
    uint public immutable nftId;
    address payable public immutable seller;

    uint public immutable startingPrice;
    uint public immutable discountRate;

    uint public immutable startAt;
    uint public immutable DURATION = 7 days;
    uint public immutable expireAt;

    constructor(address _nft,uint _nftId,uint _startingPrice, uint  _discountRate){
        nft = IERC721(_nft);
        nftId = _nftId;
        // 部署合约的人即为销售人
        seller = payable(msg.sender);

        startingPrice = _startingPrice;
        discountRate = _discountRate;

        require(startingPrice >= discountRate*DURATION,"startingPrice < discountRate*DURATION");

        startAt = block.timestamp;
        expireAt = startAt + DURATION;

    }

    function getPrice() public view returns (uint) {
        require(expireAt > block.timestamp,"already expired");
        return startingPrice - discountRate * (block.timestamp - startAt);
    }

    // 调用buy的人是购买者
    function buy() external payable {
        require(block.timestamp < expireAt,"auction expired");
        uint price = getPrice();
        require(msg.value > price,"ETH < target price");
        nft.transferFrom(seller, msg.sender, nftId);
        
        uint refund = msg.value - price;
        if(refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        // 拍卖成功后,将合约中的余额转给nft销售者seller
        seller.transfer(address(this).balance);


    }
}