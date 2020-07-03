pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Models.sol";

contract Artisan is Models {
    event ReturnCreateUser(
        address userAddress,
        string userName,
        uint256[] portfolio
    );

    function createUser(string memory userName) public {
        require(
            addressToUser[msg.sender].userAddress ==
                0x0000000000000000000000000000000000000000,
            "This User already exists"
        );
        addressToUser[msg.sender] = User(
            msg.sender,
            userName,
            new uint256[](0)
        );
        emit ReturnCreateUser(
            addressToUser[msg.sender].userAddress,
            addressToUser[msg.sender].userName,
            addressToUser[msg.sender].portfolio
        );
    }

    function updateUser(string memory userName) public {
        require(
            addressToUser[msg.sender].userAddress !=
                0x0000000000000000000000000000000000000000,
            "User does not exist"
        );
        addressToUser[msg.sender].userName = userName;
    }

    function deleteUser() public {
        addressToUser[msg.sender]
            .userAddress = 0x0000000000000000000000000000000000000000;
        addressToUser[msg.sender].userName = "";
        addressToUser[msg.sender].portfolio = [0];
    }
}
