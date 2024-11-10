// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    function transferFrom(address _from,address _to,uint _nftId) external ;    
}

contract EnglishAuction {

    event Start();
    event Bid(address indexed bidder,uint price);
    event WithDraw(address indexed withdrawer,uint backVal);
    event End(address highestBidder,uint highestPrice);



    IERC721 immutable public nft;
    uint immutable public nftId;

    address payable immutable public seller;

    bool public started;
    bool public ended;
    // 用于判断是否可以结束拍卖
    uint public endAt;

    address public highestBidder;
    uint public highestPrice;

    // 用于记录没有拍到的人的拍卖价,用于退款
    mapping(address=>uint) public bids;

    constructor(address _nft,uint _nftId,uint startPrice) {
        nft = IERC721(_nft);
        nftId = _nftId;
        highestPrice = startPrice;
        seller = payable (msg.sender);

    }

    function start() external {
        require(msg.sender == seller,"not seller");
        require(!started,"started");

        started = true;
        endAt = block.timestamp + 60;
        nft.transferFrom(seller, address(this), nftId);

        emit Start();
    }

    function bid() external  payable {
        require(started,"not start");
        require(!ended,"ended");
        require(msg.value > highestPrice,"msg.value <= highestPrice");

        // 有最高出价后,记录之前最高价,但排除第一次的起拍价(这次不是真正的出价)
        if(highestBidder != address(0)) {
            bids[highestBidder] += highestPrice;
        }

        highestBidder = msg.sender;
        highestPrice = msg.value;

        emit Bid(highestBidder,highestPrice);
    }

    function withdraw() external {
        uint backVal = bids[msg.sender];
        require(backVal != 0,"not bidder");

        bids[msg.sender] = 0;
        payable (msg.sender).transfer(backVal);

        emit WithDraw(msg.sender,backVal);
    }

    function end() external {
        require(started,"not start");
        require(!ended,"ended");
        require(block.timestamp > endAt,"is not endAt");

        ended = true;

        if(highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestPrice);
        }else {
            nft.transferFrom(address(this), seller, nftId);
        }
        
        emit End(highestBidder,highestPrice);
    }

}