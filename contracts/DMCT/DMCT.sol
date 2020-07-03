pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../Models.sol";
import "../Artisan.sol";

contract DMCT is Models, Artisan {
    //Events
    event ReturnCreateCertificate(
        uint256 index,
        uint256 CID,
        address msgsender,
        address[] onwershipHistory,
        uint256[] licenses
    );
    event ReturnCertificateLicenses(uint256[] Licenses);
    event ReturnDestroyToken(bool tokenStatus);
    event ReturnTransferCertificate(
        address creator,
        address owner,
        address[] ownershipHistory,
        uint256[] licenses
    );
    event ReturnTestData(uint256 Number, string String, address Address);
    event ReturnTestBoolData(bool Boolean);
    event ReturnTestArrayData(uint256[] Number);
    event ReturnMessage(string message);
    uint256 i = 0; //loop counter

    //Create Functions
    function createCertificate(
        string memory title,
        bytes8 assetHash,
        bytes32 urlHash,
        bytes4 urlHash_Function
    ) public returns (uint256 certificateID, uint256 assetID) {
        IpfsHash memory IpfsUrl;
        IpfsUrl.multiHash = urlHash;
        IpfsUrl.multiHash_Function = urlHash_Function;
        assetID = generateAssetID(assetHash, IpfsUrl);
        while (i < AssetIDS.length) {
            Asset memory _asset = AIDToAsset[AssetIDS[i]];
            require(AssetIDS[i] != assetID, "AssetID already exists");
            require(_asset.assetHash != assetHash, "AssetHash already exists");
            require(
                _asset.assetUrl.multiHash != IpfsUrl.multiHash,
                "AssetCID already exists"
            );
            i++;
        }
        certificateID = generateCertificateID(assetID, msg.sender);
        AIDToCID[assetID] = certificateID;
        AssetIDS.push(assetID);
        uint256 assetIndex = AssetIDS.length - 1;
        Asset memory asset = Asset(assetIndex, assetID, assetHash, IpfsUrl);
        AIDToAsset[assetID] = asset;
        CIDToAIDIndex[certificateID] = assetIndex;
        Certificate memory certificate = Certificate(
            CertificateIDS.length,
            certificateID,
            assetID,
            new uint256[](0),
            IpfsUrl,
            title,
            msg.sender,
            msg.sender,
            new address[](0),
            true
        );
        CertificateIDS.push(certificateID);
        CIDToCertificate[certificateID] = certificate;
        CIDToCertificate[certificateID].ownershipHistory.push(msg.sender);
        addressToUser[msg.sender].portfolio.push(certificateID);
        //ERC721 Mint
        Models.mint(msg.sender, certificateID);
        emit ReturnCreateCertificate(
            certificate.index,
            certificate.certificateID,
            msg.sender,
            CIDToCertificate[certificateID].ownershipHistory,
            CIDToCertificate[certificateID].licenses
        );
    }

    function createLicense(
        uint256 certificateID,
        address licenseOwner,
        bytes32 urlHash,
        bytes4 urlHash_Function
    ) public onlyCertificateOwner(certificateID) returns (uint256 licenseID) {
        licenseID = generateLicenseID(
            certificateID,
            CIDToCertificate[certificateID].certificateOwner,
            licenseOwner
        );
        IpfsHash memory licenseUrl = IpfsHash(urlHash, urlHash_Function);
        License memory license = License(
            LicenseIDS.length,
            licenseID,
            licenseOwner,
            licenseUrl,
            true
        );
        LicenseIDS.push(licenseID);
        Models.mint(
            CIDToCertificate[certificateID].certificateOwner,
            licenseID
        );
        CIDToCertificate[certificateID].licenses.push(licenseID);
        LIDToLicense[licenseID] = license;
        addressToUser[msg.sender].portfolio.push(licenseID);
        LIDToCID[licenseID] = certificateID;
        emit ReturnCertificateLicenses(
            CIDToCertificate[certificateID].licenses
        );
    }

    function destroyToken(uint256 tokenID) public {
        if (tokenID >= LI) {
            while (
                i <= CIDToCertificate[LIDToCID[tokenID]].licenses.length - 1
            ) {
                if (
                    CIDToCertificate[LIDToCID[tokenID]].licenses[i] == tokenID
                ) {
                    CIDToCertificate[LIDToCID[tokenID]]
                        .licenses[i] = CIDToCertificate[LIDToCID[tokenID]]
                        .licenses[CIDToCertificate[LIDToCID[tokenID]]
                        .licenses
                        .length - 1];
                    delete CIDToCertificate[LIDToCID[tokenID]]
                        .licenses[CIDToCertificate[LIDToCID[tokenID]]
                        .licenses
                        .length - 1];
                    CIDToCertificate[LIDToCID[tokenID]].licenses.pop();
                    break;
                }
                i++;
            }
            LIDToLicense[tokenID].status = false;
            Models.burn(msg.sender, tokenID);
            emit ReturnDestroyToken(Models.exists(tokenID));
        } else {
            uint256 index = CIDToAIDIndex[tokenID];
            uint256 CID = AIDToCID[AssetIDS[AssetIDS.length - 1]];
            if(CertificateIDS[CertificateIDS.length - 1] != CID) {
                emit ReturnMessage('CertIDS and AssetIDS are not indexed in sequence');
            }
            AssetIDS[index] = AssetIDS[AssetIDS.length - 1];
            CIDToAIDIndex[CID] = index;
            delete AssetIDS[AssetIDS.length - 1];
            AssetIDS.pop();
            CIDToCertificate[tokenID].status = false;
            Models.burn(msg.sender, tokenID);
            emit ReturnDestroyToken(Models.exists(tokenID));
        }
    }

    function transferCertificte(address to, uint256 certificateID) public onlyCertificateOwner(certificateID) {
        require(
            isApprovedOrOwner(msg.sender, certificateID) == true,
            "You are not an allowed to transfer this certificate"
        );
        require(certificateID < LI, "You cannot transfer Licenses");
        require(
            CIDToCertificate[certificateID].certificateOwner != to,
            "This user already owns this certificate"
        );
        require(
            CIDToCertificate[certificateID].status == true,
            "This certificate is closed"
        );
        transferToken(msg.sender, to, certificateID);
        CIDToCertificate[certificateID].certificateOwner = to;
        CIDToCertificate[certificateID].ownershipHistory.push(to);
        if (CIDToCertificate[certificateID].licenses.length > 0) {
            while (i <= CIDToCertificate[certificateID].licenses.length - 1) {
                transferToken(
                    msg.sender,
                    to,
                    CIDToCertificate[certificateID].licenses[i]
                );
                i++;
            }
        }
        emit ReturnTransferCertificate(
            CIDToCertificate[certificateID].certificateCreator,
            CIDToCertificate[certificateID].certificateOwner,
            CIDToCertificate[certificateID].ownershipHistory,
            CIDToCertificate[certificateID].licenses
        );
    }
}
