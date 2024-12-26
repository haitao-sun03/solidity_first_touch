// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract PaymentSplit {
    // 总份额数
    uint256 public totalShares;
    // 总分账数
    uint256 public totalReleases;

    // 每个受益人的份额
    mapping(address=>uint256) public shares;
    // 已经分给每个受益人的钱
    mapping(address=>uint256) public releases;

    // 受益人数组
    address[] public payees;

    // 增加受益人
    event PayeeAdded(address account, uint256 shares);
    // 合约收款
    event PaymentReceived(address from,uint256 amount);
    // 受益人提款
    event PaymentRelease(address to,uint256 amount);

    constructor(address[] memory _payees,uint256[] memory _shares) {
        require(_payees.length == _shares.length,"length not equal");
        require(_payees.length > 0,"have no _payees to add");
        for (uint8 i; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }

    }

    receive() external payable {
        emit PaymentReceived(msg.sender,msg.value);
    }

    function _addPayee(address _account,uint256 _accountShares) private {
         // 检查_account不为0地址
        require(_account != address(0), "PaymentSplitter: account is the zero address");
        // 检查_accountShares不为0
        require(_accountShares > 0, "PaymentSplitter: shares are 0");
        // 检查_account不重复
        require(shares[_account] == 0,"PaymentSplitter: _account already exists");
        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;

        emit PayeeAdded(_account, _accountShares);
    }

    function release(address _account) external {
        require(shares[_account] > 0,"PaymentSplitter: account has no shares");
         // 计算account应得的eth
        uint256 payment = releasable(_account);
        // 应得的eth不能为0
        require(payment != 0, "PaymentSplitter: account is not due payment");

        totalReleases += payment;
        releases[_account] += payment;
        (bool success,) = payable(_account).call{value:payment}("");
        require(success,"call transfer fail");
        emit PaymentRelease(_account, payment);
    }

    function releasable(address _account) private view returns(uint256 payment) {
        // 计算合约总收入
        uint256 totalReceive = address(this).balance + totalReleases;
        payment = pendingPayment(_account,totalReceive,releases[_account]);
    }

    function pendingPayment(address _account,uint256 _totalReceive,uint256 _accountRelease) private view returns(uint256) {
        return _totalReceive * shares[_account]/totalShares - _accountRelease;
    }
}