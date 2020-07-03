pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./DMCT.sol";

contract DMCT_Services is DMCT {
    function returnAssetIDS() public view returns (uint256[] memory assetIDS) {
        assetIDS = AssetIDS;
    }

    function returnUserByAddress(address userAddress)
        public
        view
        returns (string memory userName, uint256[] memory portfolio)
    {
        userName = addressToUser[userAddress].userName;
        portfolio = addressToUser[userAddress].portfolio;
    }

    function checkBalance(address owner) public view returns (uint256 balance) {
        balance = Models.balance(owner);
    }

    function checkOwnerOfToken(uint256 tokenID)
        public
        view
        returns (address owner)
    {
        if (tokenID > LI) {
            owner = LIDToLicense[tokenID].licenseOwner;
        } else {
            owner = ownerOfToken(tokenID);
        }
    }

    function checkTokenStatus(uint256 tokenID)
        public
        view
        returns (bool status)
    {
        status = Models.exists(tokenID);
    }

    function checkOwnerStatus(address owner, uint256 tokenID)
        public
        view
        returns (bool status)
    {
        status = Models.isApprovedOrOwner(owner, tokenID);
    }

    function checkLicenseStatus(uint256 licenseID)
        public
        view
        returns (bool tokenStatus, bool licenseStatus)
    {
        tokenStatus = Models.exists(licenseID);
        licenseStatus = LIDToLicense[licenseID].status;
    }

    function returnCertificateURL(uint256 certificateID)
        public
        view
        returns (IpfsHash memory URL, uint256 assetID)
    {
        URL = CIDToCertificate[certificateID].url;
        assetID = CIDToCertificate[certificateID].assetID;
    }

    function returnCertificate(uint256 certificateID)
        public
        view
        returns (
            uint256 index,
            uint256 assetID, //AID
            uint256[] memory licenses,
            IpfsHash memory url,
            string memory title,
            address creator,
            address owner,
            address[] memory ownershipHistory,
            bool status
        )
    {
        index = CIDToCertificate[certificateID].index;
        assetID = CIDToCertificate[certificateID].assetID;
        licenses = CIDToCertificate[certificateID].licenses;
        url = CIDToCertificate[certificateID].url;
        title = CIDToCertificate[certificateID].title;
        creator = CIDToCertificate[certificateID].certificateCreator;
        owner = CIDToCertificate[certificateID].certificateOwner;
        ownershipHistory = CIDToCertificate[certificateID].ownershipHistory;
        status = CIDToCertificate[certificateID].status;
    }

    function returnLicense(uint256 licenseID)
        public
        view
        returns (
            uint256 index,
            address licenseOwner,
            IpfsHash memory url,
            bool status
        )
    {
        index = LIDToLicense[licenseID].index;
        licenseOwner = LIDToLicense[licenseID].licenseOwner;
        url = LIDToLicense[licenseID].url;
        status = LIDToLicense[licenseID].status;
    }

    function returnLicenseOwnerArray(uint256 certificateID)
        public
        view
        returns (address[] memory ownersArray)
    {
        uint256 licenseCount = CIDToCertificate[certificateID].licenses.length;
        ownersArray = new address[](licenseCount);
        for (uint256 i = 0; i < licenseCount; i++) {
            ownersArray[i] = LIDToLicense[CIDToCertificate[certificateID]
                .licenses[i]]
                .licenseOwner;
        }
    }
}
