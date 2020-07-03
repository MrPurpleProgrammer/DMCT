pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract IPFSEngine {
    struct IpfsHash {
        bytes32 multiHash;
        bytes4 multiHash_Function;
    }

    string hash;

    function storeDataAsString(string memory _hash) public {
        hash = _hash;
    }

    function storeDataAsStruct(
        bytes32 multiHash,
        bytes4 multiHash_Function
    ) public pure returns (IpfsHash memory IpfsHashMemory) {
        IpfsHashMemory.multiHash = multiHash;
        IpfsHashMemory.multiHash_Function = multiHash_Function;
    }

    event DataStoredInTheLog(string _hash);

    function storeDataAsLog(string memory _hash) public {
        emit DataStoredInTheLog(_hash);
    }
}
