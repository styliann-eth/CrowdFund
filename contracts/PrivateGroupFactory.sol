// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

/// @title PrivateGroupFactory - Deploy new PrivateRounds contracts
/// @author styliann.eth <ns2808@proton.me>

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PrivateRounds.sol";

contract PrivateGroupFactory is Ownable {
    event NewGroupCreated(
        uint32 groupId,
        address groupAddress,
        address groupCreator
    );
    event GroupInfoChanged(
        uint32 groupId,
        string groupName,
        string groupDescription,
        string groupImageUrl,
        string groupInfoUrl
    );

    PrivateRounds[] public groups;

    constructor() {
        // IguanaDEX Safe gets DEFAULT_ADMIN_ROLE
        _transferOwnership(0xE6ae1e6B67ad5D92F9a16B4CcaB45210DA43c8Da);

        // For testing on BSC Testnet
        _transferOwnership(0x712F493C6AdBFaC93bDCE6b83E1C2b48761ACA6F);
    }

    function createNewGroup(
        string memory _groupName,
        string memory _description,
        string memory _imageUrl,
        string memory _infoUrl
    ) public onlyOwner {
        PrivateRounds group = new PrivateRounds(msg.sender, _groupName);
        groups.push(group);

        uint32 groupId = uint32(groups.length - 1);

        emit NewGroupCreated(groupId, address(group), msg.sender);
        emit GroupInfoChanged(
            groupId,
            _groupName,
            _description,
            _imageUrl,
            _infoUrl
        );
    }

    function changeGroupInfo(
        uint32 _groupId,
        string memory _groupName,
        string memory _description,
        string memory _imageUrl,
        string memory _infoUrl
    ) public onlyOwner {
        emit GroupInfoChanged(
            _groupId,
            _groupName,
            _description,
            _imageUrl,
            _infoUrl
        );
    }
}
