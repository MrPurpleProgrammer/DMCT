
const NFCServices = artifacts.require("../contracts/DMCT/DMCT_Services.sol");

contract("NFCServices", accounts => {
    let creator = "0xb34b075257db9EFE4966cC205b46ED88F0959A14";
    let licenseTransferee1 = "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1";
    let licenseTransferee2 = "0xd2f435012CF5d2B83e0Db1C349209910Dd0c334B";
    let licenseTransferee3 = "0x46B35908Ea794886ce2fDCAD5b6B82D060F5eDFe";

    it("Verify the first account is the contract owner", async () => {
        let instance = await NFCServices.deployed();
        let owner = await instance.owner();
        assert.equal(owner, "0x49f0C9b4Ab0b0DedDABf8b62e6089C9b20f936fa"); 
    });

    it("It should create a certificate, and then destroy that certificate", async () => {
        let instance = await NFCServices.deployed();
        await instance.createCertificate("hello", "world", "www", {from: "0x49f0C9b4Ab0b0DedDABf8b62e6089C9b20f936fa"});
        await instance.checkTokenStatus(web3.utils.toBN('253927849376658573003107002963798'));
        await instance.checkOwnerStatus("0x49f0C9b4Ab0b0DedDABf8b62e6089C9b20f936fa", web3.utils.toBN('253927849376658573003107002963798'));
        let assetIDS1 = await instance.returnAssetIDS();
        await instance.destroyToken(web3.utils.toBN('253927849376658573003107002963798'), {from: "0x49f0C9b4Ab0b0DedDABf8b62e6089C9b20f936fa"});
        let assertion = await instance.checkTokenStatus(web3.utils.toBN('253927849376658573003107002963798'));
        assert.equal(assertion.valueOf(), true /*false*/);
    });
      
    it("It should create a Certificate, a License, and then transfer that certificate.", async () => {
        let instance = await NFCServices.deployed();
        await instance.createCertificate("bleh", "world1", ".com", {from: "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1"});
        await instance.checkTokenStatus(web3.utils.toBN('212502406447782057571836693670462'));
        await instance.createLicense(web3.utils.toBN('212502406447782057571836693670462'), "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1", {from: "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1"});
        await instance.createLicense(web3.utils.toBN('212502406447782057571836693670462'), "0xAa34Be56433888FAE9818c3Ac5E86EB0fdfb71F0", {from: "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1"});
        await instance.returnLicenseOwnerArray(web3.utils.toBN('212502406447782057571836693670462'));
        await instance.transferCertificte("0xAa34Be56433888FAE9818c3Ac5E86EB0fdfb71F0", web3.utils.toBN("212502406447782057571836693670462"), {from: "0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1"});
        let assertion = await instance.checkOwnerOfToken(web3.utils.toBN('212502406447782057571836693670462'));
        assert.equal(assertion, "0xAa34Be56433888FAE9818c3Ac5E86EB0fdfb71F0");
    });

    it("It should transfer a certificate, create a new License and destroy that License", async () => {
        let instance = await NFCServices.deployed();
        await instance.transferCertificte("0x46B35908Ea794886ce2fDCAD5b6B82D060F5eDFe", web3.utils.toBN("20050766946163426"), {from: "0xAa34Be56433888FAE9818c3Ac5E86EB0fdfb71F0"});
        await instance.createLicense(web3.utils.toBN('212502406447782057571836693670462'), "0x37213b67bF81E7d27C7cc8f281182EA9f123Cb4C", {from: "0x46B35908Ea794886ce2fDCAD5b6B82D060F5eDFe"});
        await instance.createLicense(web3.utils.toBN('212502406447782057571836693670462'), "0xd2f435012CF5d2B83e0Db1C349209910Dd0c334B", {from: "0x46B35908Ea794886ce2fDCAD5b6B82D060F5eDFe"});
        await instance.destroyToken(web3.utils.toBN('35849217489622179'), {from: '0x46B35908Ea794886ce2fDCAD5b6B82D060F5eDFe'});
        await instance.returnLicenseOwnerArray(web3.utils.toBN('20050766946163426')).then(function(res){assert.deepEqual(res[0] ,'0xaBA24323A02Fdab404ea2C6f5B8a486CBB8003E1');});
    });

    it("It should create a User and check changes in the portfolio", async () => {
        let instance = await NFCServices.deployed();
        await instance.createUser("PurpleSamosa", {from:"0x94ce049247b7f38c784b5435448FcaFCF34b5705"});
        await instance.createCertificate("GenesisCertificate", "HelloWorld", "www.purpleSamosa.com", {from: "0x94ce049247b7f38c784b5435448FcaFCF34b5705"});
        await instance.returnUserByAddress("0x94ce049247b7f38c784b5435448FcaFCF34b5705").then(function(res){let userName = res[0]; assert.equal(userName, "PurpleSamosa");});
    })
});
