// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IOrderMixin {
    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        address maker;
        address receiver;
        address allowedSender;
        uint256 makingAmount;
        uint256 takingAmount;
        uint256 offsets;
        bytes interactions;
    }
}

interface IPreInteraction {
    function preInteraction(
        IOrderMixin.Order calldata order,
        bytes calldata extension,
        bytes32 orderHash,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 remainingMakingAmount,
        bytes calldata extraData
    ) external view;
}

contract REP8SubscriptionPreInteraction is IPreInteraction {
    mapping(address => bool) public isSubscribed;
    address public immutable owner;

    event Subscribed(address indexed user);

    constructor() {
        owner = msg.sender;
    }

    function subscribe() external {
        require(!isSubscribed[msg.sender], "Already subscribed");
        isSubscribed[msg.sender] = true;
        emit Subscribed(msg.sender);
    }

    function preInteraction(
        IOrderMixin.Order calldata /*order*/,
        bytes calldata /*extension*/,
        bytes32 /*orderHash*/,
        address taker,
        uint256 /*makingAmount*/,
        uint256 /*takingAmount*/,
        uint256 /*remainingMakingAmount*/,
        bytes calldata /*extraData*/
    ) external view override {
        require(isSubscribed[taker], "Not subscribed, cannot fill this order");
    }
}
