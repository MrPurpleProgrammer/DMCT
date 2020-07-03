pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IPFSEngine.sol";

contract Models is ERC721, Ownable, IPFSEngine {
    using SafeMath for uint256;
    constructor() public ERC721("Digital Media Copyright Token", "DMCT") {}

    //Events
    event returnAID(uint256 AssetID);
    event returnCID(uint256 CertificateID);
    event returnLID(uint256 LicenseID);

    //Global Variables
    uint256[] public CertificateIDS;
    uint256[] public LicenseIDS;
    uint256[] public AssetIDS;

    struct User {
        address userAddress;
        string userName;
        uint256[] portfolio;
    }
    struct Asset {
        uint256 index;
        uint256 assetID;
        bytes8 assetHash;
        IpfsHash assetUrl;
    }
    struct License {
        uint256 index;
        uint256 licenseID;
        address licenseOwner;
        IpfsHash url;
        bool status;
    }
    struct Certificate {
        uint256 index;
        uint256 certificateID; //CID
        uint256 assetID; //AID
        uint256[] licenses;
        IpfsHash url;
        string title;
        address certificateCreator;
        address certificateOwner;
        address[] ownershipHistory;
        bool status;
    }

    //Local Variables Declarations
    uint256 internal _IDSIZE = 32;
    uint256 internal _IDMODULUS = 10**_IDSIZE;
    uint256 internal AI = 10**(_IDSIZE);
    uint256 internal CI = 2 * (10**(_IDSIZE));
    uint256 internal LI = 3 * (10**(_IDSIZE));

    //Mappings
    mapping(uint256 => Asset) AIDToAsset;
    mapping(uint256 => Certificate) CIDToCertificate;
    mapping(uint256 => License) LIDToLicense;
    mapping(uint256 => uint256) public LIDToCID;
    mapping(uint256 => uint256) AIDToCID;
    mapping(uint256 => uint256) CIDToAIDIndex;
    mapping(address => User) addressToUser;

    //Security Access Modifiers
    modifier onlyCreator(uint256 ID) {
        if (ID < LI) {
            require(
                msg.sender == CIDToCertificate[ID].certificateCreator,
                "You are not the creator of this certificate"
            );
        } else if (ID > LI) {
            uint256 CID = LIDToCID[ID];
            require(
                msg.sender == CIDToCertificate[CID].certificateCreator,
                "You are not the creator of this license"
            );
        }
        _;
    }

    modifier onlyCertificateOwner(uint256 CID) {
        require(CID < LI, "CID is larger than the LI");
        require(
            ownerOfToken(CID) == msg.sender,
            "Msg.sender is not the owner of the token"
        );
        require(
            msg.sender == CIDToCertificate[CID].certificateOwner,
            "You are not the owner of this certificate"
        );
        _;
    }

    modifier onlyLicenseOwner(uint256 LID) {
        require(LID > LI, "LID is less than LI");
        require(
            msg.sender == LIDToLicense[LID].licenseOwner,
            "Msg.sender is not the license owner"
        );
        require(
            ownerOfToken(LID) == msg.sender,
            "Msg.sender is not the owner of the token"
        );
        _;
    }

    //SHA Encoding Functions
    function generateAssetID(bytes8 assetHash, IpfsHash memory ipfsUrl)
        internal
        view
        returns (uint256 assetID)
    {
        assetID = SafeMath.add(AI, (uint256(sha256(abi.encodePacked(assetHash, ipfsUrl.multiHash))) % _IDMODULUS));
    }

    function generateLicenseID(
        uint256 certificateID,
        address licenseCreator,
        address licenseOwner
    ) internal view returns (uint256 licenseID) {
        licenseID = SafeMath.add(LI, (uint256(sha256(abi.encodePacked(certificateID,licenseCreator,licenseOwner))) % _IDMODULUS));
    }

    function generateCertificateID(uint256 assetID, address creator)
        internal
        view
        returns (uint256 certificateID)
    {
        certificateID = SafeMath.add(CI, (uint256(sha256(abi.encodePacked(assetID, creator))) % _IDMODULUS));
    }

    //ERC721 Functions
    function mint(address owner, uint256 ID) internal {
        super._mint(owner, ID);
    }

    function burn(address owner, uint256 tokenID) internal {
        require(isApprovedOrOwner(owner, tokenID) == true, 'You are not authorized to burn this token');
        super._burn(tokenID);
    }

    function transferToken(
        address from,
        address to,
        uint256 tokenID
    ) internal {
        super.safeTransferFrom(from, to, tokenID);
    }

    function isApprovedOrOwner(address _owner, uint256 _tokenID)
        internal
        view
        returns (bool status)
    {
        status = super._isApprovedOrOwner(_owner, _tokenID);
    }

    function balance(address owner) internal view returns (uint256 _balance) {
        _balance = super.balanceOf(owner);
    }

    function exists(uint256 _tokenID) internal view returns (bool status) {
        status = super._exists(_tokenID);
    }

    function ownerOfToken(uint256 tokenID)
        internal
        view
        returns (address owner)
    {
        owner = super.ownerOf(tokenID);
    }

    //Ownable Functions

    //Safemath Functions
}
