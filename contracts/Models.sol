pragma solidity ^0.5.3;

import "node_modules/@openzeppelin/contracts/ownership/Ownable.sol";
import "node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Models is ERC721, Ownable {
    //Events
    event returnAID(uint AssetID);
    event returnCID(uint CertificateID);
    event returnLID(uint LicenseID);
    
    //Global Variabless
    uint[] public CertificateIDS; 
    uint[] public LicenseIDS;
    uint[] public AssetIDS;

    struct User {
        address userAddress;
        string userName;
        uint[] portfolio;
    }
    struct License {
        uint index;
        uint licenseID; 
        address licenseOwner;
        string url;
        bool status;
    }
    struct Certificate {
        uint index;
        uint certificateID; //CID
        uint assetID; //AID
        uint[] licenses;
        string url;
        string title;
        address certificateCreator;
        address certificateOwner;
        address[] ownershipHistory;
        bool status;
    }

    //Local Variables Declarations
    uint internal _IDSIZE = 32;
    uint internal _IDMODULUS = 10 ** _IDSIZE;
    uint internal AI = 10**(_IDSIZE);
    uint internal CI = 2*(10**(_IDSIZE));
    uint internal LI = 3*(10**(_IDSIZE));

    //Mapping
    mapping(uint => Certificate) CIDToCertificate;
    mapping(uint => License) LIDToLicense;
    mapping(uint => uint) public LIDToCID;
    mapping(uint => uint)  AIDToCID;
    mapping(uint => uint) CIDToAIDIndex;
    mapping(address => User) addressToUser;

    function () external payable {
        
    }

    //Security Access Modifiers 
    modifier onlyCreator(uint ID) {
        if(ID < LI) {
            require(msg.sender == CIDToCertificate[ID].certificateCreator, "You are not the creator of this certificate");
        }
        else if (ID > LI) {
            uint CID = LIDToCID[ID];
            require(msg.sender == CIDToCertificate[CID].certificateCreator, "You are not the creator of this license");
        }
        _;
    }

    modifier onlyCertificateOwner(uint CID) {
        require(CID < LI, "CID is larger than the LI");
        require(ownerOfToken(CID) == msg.sender, "Msg.sender is not the owner of the token");
        require(msg.sender == CIDToCertificate[CID].certificateOwner,  "You are not the owner of this certificate");
        _;
    }

    modifier onlyLicenseOwner(uint LID) {
        require(LID > LI, "LID is less than LI");
        require(msg.sender == LIDToLicense[LID].licenseOwner, "Msg.sender is not the license owner");
        require(ownerOfToken(LID) == msg.sender, "Msg.sender is not the owner of the token");
        _;
    }

    //SHA Encoding Functions
    function generateAssetID(string memory data) internal view returns (uint assetID) {
        assetID = AI + (uint(sha256(abi.encodePacked(data))) % _IDMODULUS);
    }

    function generateLicenseID(uint certificateID, address licenseCreator, address licenseOwner) internal view returns (uint licenseID) {
        licenseID = LI + (uint(sha256(abi.encodePacked(certificateID, licenseCreator, licenseOwner))) % _IDMODULUS);
    }
    
    function generateCertificateID(uint assetID, address creator) internal view returns (uint certificateID) {
        certificateID = CI + (uint(sha256(abi.encodePacked(assetID, creator))) % _IDMODULUS);
    }

    //ERC721 Functions
    function mint(address owner, uint256 ID) internal {
        super._mint(owner, ID);
    }

    function burn(address owner, uint tokenID) internal {
        super._burn(owner, tokenID);
    }

    function transferToken(address from, address to, uint tokenID) internal {
        super.safeTransferFrom(from, to, tokenID);
    }

    function isApprovedOrOwner(address _owner, uint _tokenID) internal view returns(bool status) {
        status = super._isApprovedOrOwner(_owner, _tokenID);
    }

    function balance(address owner) internal view returns (uint _balance) {
        _balance = super.balanceOf(owner);
    }

    function exists(uint _tokenID) internal view returns(bool status) {
        status = super._exists(_tokenID);
    }

    function ownerOfToken(uint tokenID) internal view returns(address owner) {
        owner = super.ownerOf(tokenID);
    }

    //Ownable Functions

    //Safemath Functions
}
