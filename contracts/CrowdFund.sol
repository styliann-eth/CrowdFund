// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.9;

/// @title PrivateInvestmentRound - DeWhales.capital members pledge eth in exchange for tokens
/// @author styliann.eth <ns2808@proton.me>

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Custom errors
error InvalidRoundStartDate(uint startAt, uint blockTimestamp);
error InvalidRoundEndDate(uint endAt, uint blockTimestamp);

contract CrowdFund is AccessControl {
    event NewRoundCreated(
        uint32 roundId,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event RoundCanceled(uint32 roundId);
    event Pledged(uint32 indexed roundId, address indexed caller, uint amount);
    event Unpledged(
        uint32 indexed roundId,
        address indexed caller,
        uint amount
    );
    event TotalClaimed(uint32 roundId);
    event InvestorRefunded(
        uint32 indexed roundId,
        address indexed caller,
        uint amount
    );

    struct Round {
        uint goal;
        uint totalEthPledged;
        uint32 startAt;
        uint32 endAt;
        bool isEthClaimed;
        uint totalTokensReceived;
        address tokenAddress;
    }

    uint32 public numOfRounds;
    mapping(uint => Round) public rounds;
    mapping(uint => mapping(address => uint)) public pledgedAmounts;

    // Investor addresses must be granted DEWHALE_ROLE by contract deployer
    bytes32 public constant DEWHALE_ROLE = keccak256("DEWHALE_ROLE");

    constructor() {
        // Contract deployer gets DEFAULT_ADMIN_ROLE
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createNewRound(
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at is too far");

        rounds[numOfRounds] = Round({
            goal: _goal,
            totalEthPledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            isEthClaimed: false,
            totalTokensReceived: 0,
            tokenAddress: address(0)
        });

        numOfRounds += 1;

        emit NewRoundCreated(numOfRounds, _goal, _startAt, _endAt);
    }

    function cancelRound(
        uint32 _roundId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Round memory round = rounds[_roundId];
        require(block.timestamp < round.startAt, "started");
        delete rounds[_roundId];
        emit RoundCanceled(_roundId);
    }

    function pledge(uint32 _roundId) external payable onlyRole(DEWHALE_ROLE) {
        Round storage round = rounds[_roundId];

        if (block.timestamp < round.startAt)
            revert InvalidRoundStartDate({
                startAt: round.startAt,
                blockTimestamp: block.timestamp
            });

        if (block.timestamp > round.endAt)
            revert InvalidRoundEndDate({
                endAt: round.endAt,
                blockTimestamp: block.timestamp
            });

        round.totalEthPledged += msg.value;
        pledgedAmounts[_roundId][msg.sender] += msg.value;

        emit Pledged(_roundId, msg.sender, msg.value);
    }

    function unpledge(
        uint32 _roundId,
        uint _amount
    ) external onlyRole(DEWHALE_ROLE) {
        Round storage round = rounds[_roundId];
        require(block.timestamp <= round.endAt, "ended");

        uint pledgedAmountBySender = pledgedAmounts[_roundId][msg.sender];

        uint amountToUnpledge = _amount <= pledgedAmountBySender
            ? _amount
            : pledgedAmountBySender;

        round.totalEthPledged -= amountToUnpledge;
        pledgedAmounts[_roundId][msg.sender] -= amountToUnpledge;

        (bool sent, ) = payable(msg.sender).call{value: amountToUnpledge}("");

        if (!sent) {
            round.totalEthPledged += amountToUnpledge;
            pledgedAmounts[_roundId][msg.sender] += amountToUnpledge;
        }

        emit Unpledged(_roundId, msg.sender, amountToUnpledge);
    }

    function claimTotalEthPledged(
        uint32 _roundId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Round storage round = rounds[_roundId];

        require(block.timestamp > round.endAt, "not ended");
        require(round.totalEthPledged >= round.goal, "totalEthPledged < goal");
        require(!round.isEthClaimed, "claimed");

        round.isEthClaimed = true;
        (bool sent, ) = payable(msg.sender).call{value: round.totalEthPledged}(
            ""
        );

        if (!sent) {
            round.isEthClaimed = false;
        }

        emit TotalClaimed(_roundId);
    }

    function refund(uint32 _roundId) external {
        Round storage round = rounds[_roundId];

        require(block.timestamp > round.endAt, "not ended");
        require(round.totalEthPledged < round.goal, "totalEthPledged >= goal");

        uint balance = pledgedAmounts[_roundId][msg.sender];
        pledgedAmounts[_roundId][msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: balance}("");

        if (!sent) {
            pledgedAmounts[_roundId][msg.sender] = balance;
        }

        emit InvestorRefunded(_roundId, msg.sender, balance);
    }

    function grantDeWhaleRole(
        address[] calldata dewhaleAddresses
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint i = 0; i < dewhaleAddresses.length; i++) {
            _grantRole(DEWHALE_ROLE, dewhaleAddresses[i]);
        }
    }

    function revokeDeWhaleRole(
        address[] calldata leaverAddresses
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint i = 0; i < leaverAddresses.length; i++) {
            _revokeRole(DEWHALE_ROLE, leaverAddresses[i]);
        }
    }

    function depositTokens(
        uint _roundId,
        address _tokenAddress,
        uint _amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Round storage round = rounds[_roundId];

        bool receivedTokens = IERC20(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (receivedTokens) {
            round.totalTokensReceived = _amount;
            round.tokenAddress = _tokenAddress;
        }
    }

    function claimTokens(uint _roundId) external {
        Round storage round = rounds[_roundId];

        require(round.totalTokensReceived > 0, "still awaiting tokens");

        uint pledgedEthAmount = pledgedAmounts[_roundId][msg.sender];

        require(pledgedEthAmount > 0, "no claim");

        uint tokensToBeClaimed = (pledgedEthAmount *
            round.totalTokensReceived) / round.totalEthPledged;

        pledgedAmounts[_roundId][msg.sender] = 0;
        bool sentTokens = IERC20(round.tokenAddress).transfer(
            msg.sender,
            tokensToBeClaimed
        );

        if (!sentTokens) {
            pledgedAmounts[_roundId][msg.sender] = pledgedEthAmount;
        }
    }
}
