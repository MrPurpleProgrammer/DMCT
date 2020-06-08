pragma solidity ^0.5.3;

import "../Models.sol";
import "../Artisan.sol";

contract DMCT is Models, Artisan {

    //Events
    event ReturnCreateCertificate(uint index, uint CID, address msgsender, address[] onwershipHistory, uint[] licenses);
    event ReturnCertificateLicenses(uint[] Licenses);
    event ReturnDestroyToken(bool tokenStatus);
    event ReturnTransferCertificate(address creator, address owner, address[] ownershipHistory, uint[] licenses);
    event ReturnTestData(uint Number, string String, address Address);
    event ReturnTestBoolData(bool Boolean);
    event ReturnTestArrayData(uint[] Number);
    uint i = 0; //loop counter
    function () external payable {
    }
    //Create Functions
    function createLicense(uint certificateID, address licenseOwner) public onlyCertificateOwner(certificateID) returns (uint licenseID) {
        licenseID = generateLicenseID(certificateID, CIDToCertificate[certificateID].certificateOwner, licenseOwner);
        License memory license = License(LicenseIDS.length, licenseID, licenseOwner, CIDToCertificate[certificateID].url, true);
        LicenseIDS.push(licenseID);
        Models.mint(CIDToCertificate[certificateID].certificateOwner, licenseID);
        CIDToCertificate[certificateID].licenses.push(licenseID);
        LIDToLicense[licenseID] = license;
        addressToUser[msg.sender].portfolio.push(licenseID);
        LIDToCID[licenseID] = certificateID;
        emit ReturnCertificateLicenses(CIDToCertificate[certificateID].licenses);
    }

    function createCertificate(string memory title, string memory data, string memory url) public returns (uint certificateID, uint assetID) { 
        assetID = generateAssetID(data);
        while(i < AssetIDS.length) {
            require(AssetIDS[i] != assetID, "Asset already exists");
            i++;
        }
        certificateID = generateCertificateID(assetID, msg.sender);
        AIDToCID[assetID] = certificateID;
        CIDToAIDIndex[certificateID] = AssetIDS.push(assetID)-1;
        Certificate memory certificate = Certificate(CertificateIDS.length, certificateID, assetID, new uint[](0), url, title, msg.sender, msg.sender, new address[](0), true);
        CertificateIDS.push(certificateID);
        CIDToCertificate[certificateID] = certificate;
        CIDToCertificate[certificateID].ownershipHistory.push(msg.sender);
        addressToUser[msg.sender].portfolio.push(certificateID);
        //ERC721 Mint
        Models.mint(msg.sender, certificateID);
        emit ReturnCreateCertificate(certificate.index, certificate.certificateID, msg.sender, CIDToCertificate[certificateID].ownershipHistory, CIDToCertificate[certificateID].licenses);
    }

    function destroyToken(uint tokenID) public {
        if(tokenID >= LI) {
            while(i <= CIDToCertificate[LIDToCID[tokenID]].licenses.length-1) {
                if(CIDToCertificate[LIDToCID[tokenID]].licenses[i] == tokenID) {
                    CIDToCertificate[LIDToCID[tokenID]].licenses[i] = CIDToCertificate[LIDToCID[tokenID]].licenses[CIDToCertificate[LIDToCID[tokenID]].licenses.length-1];
                    delete CIDToCertificate[LIDToCID[tokenID]].licenses[CIDToCertificate[LIDToCID[tokenID]].licenses.length-1];
                    CIDToCertificate[LIDToCID[tokenID]].licenses.length--;
                    break;
                }
                i++;
            }
            LIDToLicense[tokenID].status = false;
            Models.burn(msg.sender, tokenID);
            emit ReturnDestroyToken(Models.exists(tokenID));
        }
        else {
            uint index = CIDToAIDIndex[tokenID];
            uint CID = AIDToCID[AssetIDS[AssetIDS.length-1]];
            AssetIDS[index] = AssetIDS[AssetIDS.length-1];
            CIDToAIDIndex[CID] = index;
            delete AssetIDS[AssetIDS.length-1];
            AssetIDS.length--;
            CIDToCertificate[tokenID].status = false; 
            Models.burn(msg.sender, tokenID);
            emit ReturnDestroyToken(Models.exists(tokenID));
        }
    }

    function transferCertificte(address to, uint certificateID) public {
        require(isApprovedOrOwner(msg.sender, certificateID) == true, "You are not an allowed to transfer this certificate");
        require(certificateID < LI, "You cannot transfer Licenses");
        require(CIDToCertificate[certificateID].certificateOwner != to, "This user already owns this certificate");
        require(CIDToCertificate[certificateID].status == true, "This certificate is closed");
        transferToken(msg.sender, to, certificateID);
        CIDToCertificate[certificateID].certificateOwner = to;
        CIDToCertificate[certificateID].ownershipHistory.push(to);
        if(CIDToCertificate[certificateID].licenses.length > 0) {
            while(i <= CIDToCertificate[certificateID].licenses.length-1) {
                transferToken(msg.sender, to, CIDToCertificate[certificateID].licenses[i]);
                i++;
            }
        }
        emit ReturnTransferCertificate(CIDToCertificate[certificateID].certificateCreator, CIDToCertificate[certificateID].certificateOwner, CIDToCertificate[certificateID].ownershipHistory, CIDToCertificate[certificateID].licenses);
    }
}