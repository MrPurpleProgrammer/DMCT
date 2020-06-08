pragma solidity ^0.5.3;

import "./DMCT.sol";

contract DMCT_Services is DMCT {

    function () external payable {}
    function returnAssetIDS() public view returns(uint[] memory assetIDS) {
        assetIDS = AssetIDS;
    }

    function returnUserByAddress(address userAddress) public view returns(string memory userName, uint[] memory portfolio){
        userName = addressToUser[userAddress].userName;
        portfolio = addressToUser[userAddress].portfolio;
    }

    function checkBalance(address owner) public view returns(uint balance) {
        balance = Models.balance(owner);
    }

    function checkOwnerOfToken(uint tokenID) public view returns(address owner) {
        if(tokenID > LI) {
            owner = LIDToLicense[tokenID].licenseOwner;
        }
        else {
            owner = ownerOfToken(tokenID);
        }
    }

    function checkTokenStatus(uint tokenID) public view returns(bool status){
        status = Models.exists(tokenID);
    }

    function checkOwnerStatus(address owner, uint tokenID) public view returns(bool status){
        status = Models.isApprovedOrOwner(owner, tokenID);
    }

    function checkLicenseStatus(uint licenseID) public view returns(bool tokenStatus, bool licenseStatus) {
        tokenStatus = Models.exists(licenseID);
        licenseStatus = LIDToLicense[licenseID].status;
    }

    function returnCertificateURL(uint certificateID) public view returns(string memory URL, uint assetID) {
        URL = CIDToCertificate[certificateID].url;
        assetID = CIDToCertificate[certificateID].assetID;
    }

    function returnCertificate(uint certificateID) public view returns(
        uint index, 
        uint assetID, //AID
        uint[] memory licenses,
        string memory url,
        string memory title,
        address creator,
        address owner,
        address[] memory ownershipHistory,
        bool status
        ) {

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

    function returnLicense(uint licenseID) public view returns(
        uint index,
        address licenseOwner,
        string memory url,
        bool status) {

        index = LIDToLicense[licenseID].index;
        licenseOwner = LIDToLicense[licenseID].licenseOwner;
        url = LIDToLicense[licenseID].url;
        status = LIDToLicense[licenseID].status;
    }

    function returnLicenseOwnerArray(uint certificateID) public view returns(address[] memory ownersArray){
        uint licenseCount = CIDToCertificate[certificateID].licenses.length;
        ownersArray = new address[](licenseCount);
        for(uint i = 0; i < licenseCount; i++) {
            ownersArray[i] = LIDToLicense[CIDToCertificate[certificateID].licenses[i]].licenseOwner;
        }
    }
}