
pragma solidity ^0.4.18;

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        return oraclize_setNetwork();
        networkID; // silence the warning and remain backwards compatible
    }
    function oraclize_setNetwork() internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    //    function __callback(bytes32 myid, string result) public {
    //        __callback(myid, result, new bytes(0));
    //    }
    //    function __callback(bytes32 myid, string result, bytes proof) public {
    //        return;
    //        myid; result; proof; // Silence compiler warnings
    //    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal pure returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function strCompare(string _a, string _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal pure returns (int) {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] arr) internal pure returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
    }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
    }


    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {
        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        require((_nbytes > 0) && (_nbytes <= 32));
        // Convert from seconds to ledger timer ticks
        _delay *= 10;
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly {
            mstore(add(delay, 0x20), _delay)
        }

        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);

        bytes memory delay_bytes8_left = new bytes(8);

        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }

        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));
        return queryId;
    }

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(keccak256(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
        bool sigok;

        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = byte(1); //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        require(proofVerified);

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){
        bool match_ = true;

        require(prefix.length == n_random_bytes);

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {
        uint minLength = length + toOffset;

        // Buffer too small
        require(to.length >= minLength); // Should be a better way?

        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    // Duplicate Solidity's ecrecover, but catching the CALL return value
    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

        // NOTE: we can reuse the request memory because we deal with
        //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
            return (false, 0);

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

        // Here we are loading the last 32 bytes. We exploit the fact that
        // 'mload' will pad with zeroes if we overread.
        // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))

        // Alternative solution:
        // 'byte' is not working due to the Solidity parser, so lets
        // use the second best option, 'and'
        // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
            v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract UnicornManagement {
    using SafeMath for uint;

    address public ownerAddress;
    address public managerAddress;
    address public communityAddress;
    address public walletAddress;
    address public candyToken;
    address public candyPowerToken;
    address public dividendManagerAddress; //onlyCommunity
    //    address public blackBoxAddress; //onlyOwner
    //    address public breedingAddress; //onlyOwner

    uint public createDividendPercent = 375; //OnlyManager 4 digits. 10.5% = 1050
    uint public sellDividendPercent = 375; //OnlyManager 4 digits. 10.5% = 1050
    uint public subFreezingPrice = 1000000000000000000; //
    uint64 public subFreezingTime = 1 hours;
    uint public subTourFreezingPrice = 1000000000000000000; //
    uint64 public subTourFreezingTime = 1 hours;
    uint public createUnicornPrice = 50000000000000000;
    uint public createUnicornPriceInCandy = 25000000000000000000; //25 tokens
    uint public oraclizeFee = 3000000000000000; //0.003 ETH

    bool public paused = true;

    mapping(address => bool) tournaments;//address

    event GamePaused();
    event GameResumed();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event NewManagerAddress(address managerAddress);
    event NewCommunityAddress(address communityAddress);
    event NewDividendManagerAddress(address dividendManagerAddress);
    event NewWalletAddress(address walletAddress);
    event NewCreateUnicornPrice(uint price, uint priceCandy);
    event NewOraclizeFee(uint fee);
    event NewSubFreezingPrice(uint price);
    event NewSubFreezingTime(uint time);
    event NewSubTourFreezingPrice(uint price);
    event NewSubTourFreezingTime(uint time);
    event NewCreateUnicornPrice(uint price);
    event NewCreateDividendPercent(uint percent);
    event NewSellDividendPercent(uint percent);
    event AddTournament(address tournamentAddress);
    event DelTournament(address tournamentAddress);
    event NewBlackBoxAddress(address blackBoxAddress);
    event NewBreedingAddress(address breedingAddress);


    modifier onlyOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == managerAddress);
        _;
    }

    modifier onlyCommunity() {
        require(msg.sender == communityAddress);
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function UnicornManagement(address _candyToken, address _candyPowerToken) public {
        ownerAddress = msg.sender;
        managerAddress = msg.sender;
        communityAddress = msg.sender;
        walletAddress = msg.sender;
        candyToken = _candyToken;
        candyPowerToken = _candyPowerToken;
    }


    function setManagerAddress(address _managerAddress) external onlyOwner {
        require(_managerAddress != address(0));
        managerAddress = _managerAddress;
        NewManagerAddress(_managerAddress);
    }

    function setDividendManager(address _dividendManagerAddress) external onlyOwner {
        require(_dividendManagerAddress != address(0));
        dividendManagerAddress = _dividendManagerAddress;
        NewDividendManagerAddress(_dividendManagerAddress);
    }

    function setWallet(address _walletAddress) external onlyOwner {
        require(_walletAddress != address(0));
        walletAddress = _walletAddress;
        NewWalletAddress(_walletAddress);
    }

    function setTournament(address _tournamentAddress) external onlyOwner {
        require(_tournamentAddress != address(0));
        tournaments[_tournamentAddress] = true;
        AddTournament(_tournamentAddress);
    }

    function delTournament(address _tournamentAddress) external onlyOwner {
        require(tournaments[_tournamentAddress]);
        tournaments[_tournamentAddress] = false;
        DelTournament(_tournamentAddress);
    }

    function transferOwnership(address _ownerAddress) external onlyOwner {
        require(_ownerAddress != address(0));
        ownerAddress = _ownerAddress;
        OwnershipTransferred(ownerAddress, _ownerAddress);
    }


    function setCreateDividendPercent(uint _percent) public onlyManager {
        require(_percent < 2500);
        //no more then 25%
        createDividendPercent = _percent;
        NewCreateDividendPercent(_percent);
    }

    function setSellDividendPercent(uint _percent) public onlyManager {
        require(_percent < 2500);
        //no more then 25%
        sellDividendPercent = _percent;
        NewSellDividendPercent(_percent);
    }

    //time in minutes
    function setSubFreezingTime(uint64 _time) external onlyManager {
        subFreezingTime = _time * 1 minutes;
        NewSubFreezingTime(_time);
    }

    //price in CandyCoins
    function setSubFreezingPrice(uint _price) external onlyManager {
        subFreezingPrice = _price;
        NewSubFreezingPrice(_price);
    }


    //time in minutes
    function setSubTourFreezingTime(uint64 _time) external onlyManager {
        subTourFreezingTime = _time * 1 minutes;
        NewSubTourFreezingTime(_time);
    }

    //price in CandyCoins
    function setSubTourFreezingPrice(uint _price) external onlyManager {
        subTourFreezingPrice = _price;
        NewSubTourFreezingPrice(_price);
    }

    //in weis
    function setOraclizeFee(uint _fee) external onlyManager {
        oraclizeFee = _fee;
        NewOraclizeFee(_fee);
    }

    //price in weis
    function setCreateUnicornPrice(uint _price, uint _candyPrice) external onlyManager {
        createUnicornPrice = _price;
        createUnicornPriceInCandy = _candyPrice;
        NewCreateUnicornPrice(_price, _candyPrice);
    }

    function setCommunity(address _communityAddress) external onlyCommunity {
        require(_communityAddress != address(0));
        communityAddress = _communityAddress;
        NewCommunityAddress(_communityAddress);
    }




    //    function setBlackBox(address _blackBoxAddress) external onlyOwner whenPaused {
    //        require(_blackBoxAddress != address(0));
    //        blackBoxAddress = _blackBoxAddress;
    //        NewBlackBoxAddress(_blackBoxAddress);
    //    }

    //    function setBreeding(address _breedingAddress) external onlyOwner whenPaused {
    //        require(_breedingAddress != address(0));
    //        breedingAddress = _breedingAddress;
    //        NewBreedingAddress(_breedingAddress);
    //        //        breedingContract = UnicornBreeding(breedingAddress);
    //    }




    function pause() external onlyOwner whenNotPaused {
        paused = true;
        GamePaused();
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        GameResumed();
    }



    function isTournament(address _tournamentAddress) external view returns (bool) {
        return tournaments[_tournamentAddress];
    }

    function getCreateUnicornFullPrice() external view returns (uint) {
        return createUnicornPrice.add(oraclizeFee);
    }

    function getCreateUnicornFullPriceInCandy() external view returns (uint) {
        return createUnicornPriceInCandy;
    }

    function getHybridizationFullPrice(uint _price) external view returns (uint) {
        return _price.add(valueFromPercent(_price, createDividendPercent));//.add(oraclizeFee);
    }

    function getSellUnicornFullPrice(uint _price) external view returns (uint) {
        return _price.add(valueFromPercent(_price, sellDividendPercent));//.add(oraclizeFee);
    }

    //1% - 100, 10% - 1000 50% - 5000
    function valueFromPercent(uint _value, uint _percent) internal pure returns (uint amount)    {
        uint _amount = _value.mul(_percent).div(10000);
        return (_amount);
    }
}

contract DividendManagerInterface {
    function payDividend() external payable;
}

contract UnicornManagementInterface {

    function ownerAddress() external view returns (address);
    function managerAddress() external view returns (address);
    function communityAddress() external view returns (address);
    function dividendManagerAddress() external view returns (address);
    function walletAddress() external view returns (address);
    //    function blackBoxAddress() external view returns (address);
    //    function breedingAddress() external view returns (address);
    function candyToken() external view returns (address);
    function candyPowerToken() external view returns (address);

    function createDividendPercent() external view returns (uint);
    function sellDividendPercent() external view returns (uint);
    function subFreezingPrice() external view returns (uint);
    function subFreezingTime() external view returns (uint64);
    function subTourFreezingPrice() external view returns (uint);
    function subTourFreezingTime() external view returns (uint64);
    function createUnicornPrice() external view returns (uint);
    function createUnicornPriceInCandy() external view returns (uint);
    function oraclizeFee() external view returns (uint);

    function paused() external view returns (bool);

    //    function transferOwnership(address _ownerAddress) external;
    //    function setTournament(address _tournamentAddress) external;
    //    function delTournament(address _tournamentAddress) external;
    function isTournament(address _tournamentAddress) external view returns (bool);
    //    function setBlackBoxAddress(address _blackBoxAddress) external;
    //    function setBreedingAddress(address _breedingAddress) external;
    //    function setDividendManager(address _dividendManagerAddress) external;
    //    function setCreateDividendPercent(uint _percent) public;
    //    function setSellDividendPercent(uint _percent) public;
    //    function setOraclizeFee(uint _fee) external;
    //    function setSubFreezingPrice(uint _price) external;
    //    function setSubFreezingTime(uint _time) external;
    //    function setCreateUnicornFullPrice(uint _price, uint _candyPrice) external;
    function getCreateUnicornFullPrice() external view returns (uint);
    function getHybridizationFullPrice(uint _price) external view returns (uint);
    function getSellUnicornFullPrice(uint _price) external view returns (uint);
    function getCreateUnicornFullPriceInCandy() external view returns (uint);
    function pause() public;
    function unpause() public;
}

contract UnicornAccessControl {

    UnicornManagementInterface public unicornManagement;

    function UnicornAccessControl(address _unicornManagementAddress) public {
        unicornManagement = UnicornManagementInterface(_unicornManagementAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == unicornManagement.ownerAddress());
        _;
    }

    modifier onlyManager() {
        require(msg.sender == unicornManagement.managerAddress());
        _;
    }

    modifier onlyCommunity() {
        require(msg.sender == unicornManagement.communityAddress());
        _;
    }

    modifier onlyOLevel() {
        require(msg.sender == unicornManagement.ownerAddress() || msg.sender == unicornManagement.managerAddress());
        _;
    }

    modifier onlyTournament() {
        require(unicornManagement.isTournament(msg.sender));
        _;
    }

    modifier whenNotPaused() {
        require(!unicornManagement.paused());
        _;
    }

    modifier whenPaused {
        require(unicornManagement.paused());
        _;
    }

    //    modifier onlyBlackBox() {
    //        require(msg.sender == unicornManagement.blackBoxAddress());
    //        _;
    //    }
    //
    //    modifier onlyBreeding() {
    //        require(msg.sender == unicornManagement.breedingAddress());
    //        _;
    //    }

}


contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
}


contract UnicornBreedingInterface {
    function setGen(uint _unicornId, bytes _gen) public;
}

contract BlackBoxInterface {
    //    function isBlackBox() public pure returns (bool);
    function createGen0(uint unicornId, uint typeId) public payable;
    function genCore(uint childUnicornId, uint unicorn1_id, uint unicorn2_id) public payable;
}

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 _unicornId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _unicornId);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _unicornId) public view returns (address _owner);
    function transfer(address _to, uint256 _unicornId) public;
    function approve(address _to, uint256 _unicornId) public;
    //    function takeOwnership(uint256 _unicornId) public; //TODO
    function totalSupply() public constant returns (uint);
    function owns(address _claimant, uint256 _unicornId) public view returns (bool);
    function allowance(address _claimant, uint256 _unicornId) public view returns (bool);
    function transferFrom(address _from, address _to, uint256 _unicornId) public;
}


contract BlackBoxAccessControl is UnicornAccessControl {
    address public breedingAddress;
    UnicornBreedingInterface internal breedingContract;


    function isGamePaused() external view returns (bool) {
        return unicornManagement.paused();
    }

    modifier onlyBreeding() {
        require(msg.sender == breedingAddress);
        _;
    }

    function setBreeding(address _breedingAddress) onlyOwner whenPaused external {
        require(_breedingAddress != address(0));
        breedingAddress = _breedingAddress;
        breedingContract = UnicornBreedingInterface(breedingAddress);
    }

}


contract BlackBoxController is BlackBoxAccessControl, usingOraclize  {
    struct Request {
        string request;
        uint queueIndex;
    }
    mapping(bytes32 => uint) validIds; //oraclize query hash -> unicorn_id - 1 for require validIds[hash] > 0
    mapping(uint => Request) requests;
    // queue_index => unicornId
    mapping(uint => uint) public queue;
    uint public queueSize = 0;
    uint gasLimit = 400000;

    string genCoreUrl = "BAdL0Wo6ujCMz/QLJL5daj57R00OusTUuymK+XEVmGI8BgjdpUbTYZCLBv0D524Oe9306mZJO6VOMBGjgrni8uGfa6X+Ckc3bsJghmv3ae5vlIpB6Gj0WoljUv0n8wZHENG+zWZsrzNPwc60SVHmmGCgH4fqmtMYPSjIJDMzQhZ2JpG43qrceNyghrB9cMUCvatwOdDUhOou5WvhGGboNvY1HIqtgoenv4FtyUCANt7VLwHkGg==";
    string gen0Url = "BDymKBpAwjmJ4wwB1OGkJQnn3puTj6dEYUYJ6Ej1yzl6Wh16elvSBKA29Ml23BBKFowk6jfFsR2YWqhdH9kiusY/RZqsdNDH/NstdjKhx36qvmy47q184mzdQaClLbde9LNEw+TC5ya19SVpLj9EBoyEvUf7JIBAbM5mm+gn2iUi/MMCMW3S3hGTSNeH6yPtEFXAni8nIcx5g5YXp3Hw6jstA1IVaHiw2xuY1WiSZJA1fnahBl9mZ6o=";

    string Gen0Query1 = '\n{"unicorn_blockchain_id":';
    string Gen0Query2 = ',"type":';
    string Gen0Query3 = ',"owner_blockchain_id":1}';

    string genCoreQuery1 = '\n{"parents": [{"unicorn_blockchain_id":';

    event LogNewOraclizeQuery(string description);
    event Gene0Request(uint indexed unicornId, uint unicornType);
    event GeneHybritizationRequest(uint indexed unicornId, uint firstAncestorUnicornId, uint secondAncestorUnicornId);

    event Gene0RequestRetry(uint indexed unicornId);
    event GeneHybritizationRequestRetry(uint indexed unicornId);
    event FundsTransferred(address dividendManager, uint value);



    function BlackBoxController(address _unicornManagementAddress) UnicornAccessControl(_unicornManagementAddress) public {
        oraclize_setCustomGasPrice(2000000000 wei);
    }

    function() public payable {
        //
    }

    //
    function __callback(bytes32 hash, string result) public {
        require(validIds[hash] > 0);
        require(msg.sender == oraclize_cbAddress());

        bytes memory gen = bytes(result);
        uint unicornId = validIds[hash] - 1;

        breedingContract.setGen(unicornId,gen);
        //        logRes(result);

        if (bytes(requests[unicornId].request).length > 0) {
            requests[queue[--queueSize]].queueIndex = requests[unicornId].queueIndex;
            queue[requests[unicornId].queueIndex] = queue[queueSize];
            delete queue[queueSize];
            delete requests[unicornId];
        }

        delete validIds[hash];
    }


    //TODO gas limit
    function genCore(uint childUnicornId, uint unicorn1_id, uint unicorn2_id) onlyBreeding public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            revert();
        } else {
            string memory query = strConcat(genCoreQuery1, uint2str(unicorn1_id),
                '},{"unicorn_blockchain_id":', uint2str(unicorn2_id), '}],"parent_idx": 1,"unicorn_blockchain_id":');

            query = strConcat(query, uint2str(childUnicornId), '}');

            bytes32 queryId = oraclize_query("URL", genCoreUrl, query, gasLimit);

            requests[childUnicornId] = Request({
                request: query,
                queueIndex: queueSize++
                });

            queue[requests[childUnicornId].queueIndex] = childUnicornId;

            validIds[queryId] = childUnicornId + 1; //for require validIds[hash] > 0
            GeneHybritizationRequest(childUnicornId, unicorn1_id, unicorn2_id);
        }
    }

    //TODO gas limit eth_gasPrice
    function createGen0(uint _unicornId, uint _type) onlyBreeding public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            revert();
        } else {

            string memory query = strConcat(Gen0Query1, uint2str(_unicornId), Gen0Query2, uint2str(_type), Gen0Query3);

            bytes32 queryId = oraclize_query("URL", gen0Url, query, gasLimit);

            requests[_unicornId] = Request({
                request: query,
                queueIndex: queueSize++
                });

            queue[requests[_unicornId].queueIndex] = _unicornId;

            validIds[queryId] = _unicornId + 1; //for require validIds[hash] > 0
            Gene0Request(_unicornId, _type);
        }
    }


    function setGasPrice(uint _newPrice) public onlyOwner {
        oraclize_setCustomGasPrice(_newPrice * 1 wei);
    }

    function setGasLimit(uint _newGasLimit) public onlyOwner {
        gasLimit = _newGasLimit;
    }

    function setGenCoreUrl(string _genCoreUrl) public onlyOwner {
        genCoreUrl = _genCoreUrl;
    }

    function setGen0Url(string _gen0Url) public onlyOwner {
        gen0Url = _gen0Url;
    }

    function transferEthersToDividendManager(uint _value) onlyManager public {
        require(this.balance >= _value);
        DividendManagerInterface dividendManager = DividendManagerInterface(unicornManagement.dividendManagerAddress());
        dividendManager.payDividend.value(_value)();
        FundsTransferred(unicornManagement.dividendManagerAddress(), _value);
    }


    function setGenManual(uint unicornId, string gen) public onlyOwner{
        breedingContract.setGen(unicornId, bytes(gen));
    }


    function genCoreManual(uint _unicornId) onlyOwner public {
        require(bytes(requests[_unicornId].request).length > 0);
        if (oraclize_getPrice("URL") > this.balance) {
            revert();
        } else {
            bytes32 queryId = oraclize_query("URL", genCoreUrl, requests[_unicornId].request, gasLimit);

            validIds[queryId] = _unicornId + 1; //for require validIds[hash] > 0
            GeneHybritizationRequestRetry(_unicornId);
        }
    }


    function createGen0Manual(uint _unicornId) onlyOwner public payable {
        require(bytes(requests[_unicornId].request).length > 0);
        if (oraclize_getPrice("URL") > this.balance) {
            // LogNewOraclizeQuery("CreateGen0 query was NOT sent, please add some ETH to cover for the query fee");
            revert();
        } else {
            bytes32 queryId = oraclize_query("URL", gen0Url, requests[_unicornId].request, gasLimit);

            validIds[queryId] = _unicornId + 1; //for require validIds[hash] > 0
            Gene0RequestRetry(_unicornId);
        }
    }

}


contract UnicornBreedingAccessControl is UnicornAccessControl {
    address public blackBoxAddress; //onlyOwner
    address public geneLabAddress; //onlyOwner
    BlackBoxInterface internal blackBoxContract; //onlyOwner
    //mapping(address => bool) tournaments;//


    modifier onlyBlackBox() {
        require(msg.sender == blackBoxAddress);
        _;
    }

    modifier onlyGeneLab() {
        require(msg.sender == geneLabAddress);
        _;
    }

    function isGamePaused() external view returns (bool) {
        return unicornManagement.paused();
    }

    function setBlackBox(address _blackBoxAddress) external onlyOwner whenPaused    {
        require(_blackBoxAddress != address(0));
        blackBoxContract = BlackBoxInterface(_blackBoxAddress);
        blackBoxAddress = _blackBoxAddress;
    }

    //TODO Pause for dependences functions
    function setGeneLab(address _geneLabAddress) external onlyOwner  {
        require(_geneLabAddress != address(0));
        geneLabAddress = _geneLabAddress;
    }
}

contract UnicornBase is ERC721, UnicornBreedingAccessControl {
    using SafeMath for uint;

    //TODO
    string public constant name = "UnicornGO";
    string public constant symbol = "UNG";

    event UnicornGeneSet(uint indexed unicornId);
    event UnicornGeneUpdate(uint indexed unicornId);
    event UnicornFreezingTimeSet(uint indexed unicornId, uint time);
    event UnicornTourFreezingTimeSet(uint indexed unicornId, uint time);

    event NewOffer(address indexed owner, uint256 indexed offerId, uint256 indexed unicornId, uint price);
    event UnicornSold(address indexed newOwner, uint256 indexed offerId, uint256 indexed unicornId);
    event OfferDelete(address indexed owner, uint256 indexed offerId, uint256 indexed unicornId);
    //event OfferAutoCancel(uint indexed offerId, uint indexed unicornId);

    struct Unicorn {
        bytes gen;
        uint64 birthTime;
        uint64 freezingEndTime;
        uint64 freezingTourEndTime;
        string name;
    }


    uint8 maxFreezingIndex = 7;
    uint32[8] internal freezing = [
    uint32(1 hours),    //1 hour
    uint32(2 hours),    //2 - 4 hours
    uint32(8 hours),    //8 - 12 hours
    uint32(16 hours),   //16 - 24 hours
    uint32(36 hours),   //36 - 48 hours
    uint32(72 hours),   //72 - 96 hours
    uint32(120 hours),  //120 - 144 hours
    uint32(168 hours)   //168 hours
    ];

    //count for random plus from 0 to ..
    uint32[8] internal freezingPlusCount = [
    0, 3, 5, 9, 13, 25, 25, 0
    ];

    // Total amount of unicorns
    uint256 private totalUnicorns;

    //Mapping from unicorn ID to Unicorn struct
    mapping(uint256 => Unicorn) public unicorns;

    // Mapping from unicorn ID to owner
    mapping(uint256 => address) private unicornOwner;

    // Mapping from unicorn ID to approved address
    mapping(uint256 => address) private unicornApprovals;

    // Mapping from owner to list of owned unicorn IDs
    mapping(address => uint256[]) private ownedUnicorns;

    // Mapping from unicorn ID to index of the owner unicorns list
    // т.е. ID уникорна => порядковый номер в списке владельца
    mapping(uint256 => uint256) private ownedUnicornsIndex;

    mapping(uint256 => bool) private unicornApprovalsForGeneLab;

    uint public lastOfferId = 0;

    struct Offer{
        uint unicorn_id;
        uint price;
        uint marketIndex;
        //        bool accepted;
        bool exists;

    }

    // Mapping from offer ID to Offer struct
    mapping (uint => Offer) public offers;
    // Mapping from unicorn ID to offer ID
    mapping (uint => uint) public unicornOffer;
    // queue_index => offerId
    mapping(uint => uint) public market;
    uint public marketSize = 0;

    modifier onlyOwnerOf(uint256 _unicornId) {
        require(owns(msg.sender, _unicornId));
        _;
    }

    /**
    * @dev Gets the owner of the specified unicorn ID
    * @param _unicornId uint256 ID of the unicorn to query the owner of
    * @return owner address currently marked as the owner of the given unicorn ID
    */
    function ownerOf(uint256 _unicornId) public view returns (address) {
        return unicornOwner[_unicornId];
        //        address owner = unicornOwner[_unicornId];
        //        require(owner != address(0));
        //        return owner;
    }

    function totalSupply() public view returns (uint256) {
        return totalUnicorns;
    }

    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return ownedUnicorns[_owner].length;
    }

    /**
    * @dev Gets the list of unicorns owned by a given address
    * @param _owner address to query the unicorns of
    * @return uint256[] representing the list of unicorns owned by the passed address
    */
    function unicornsOf(address _owner) public view returns (uint256[]) {
        return ownedUnicorns[_owner];
    }

    /**
    * @dev Gets the approved address to take ownership of a given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to query the approval of
    * @return address currently approved to take ownership of the given unicorn ID
    */
    function approvedFor(uint256 _unicornId) public view returns (address) {
        return unicornApprovals[_unicornId];
    }

    /**
    * @dev Tells whether the msg.sender is approved for the given unicorn ID or not
    * This function is not private so it can be extended in further implementations like the operatable ERC721
    * @param _owner address of the owner to query the approval of
    * @param _unicornId uint256 ID of the unicorn to query the approval of
    * @return bool whether the msg.sender is approved for the given unicorn ID or not
    */
    function allowance(address _owner, uint256 _unicornId) public view returns (bool) {
        return approvedFor(_unicornId) == _owner;
    }

    /**
    * @dev Approves another address to claim for the ownership of the given unicorn ID
    * @param _to address to be approved for the given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to be approved
    */
    function approve(address _to, uint256 _unicornId) public onlyOwnerOf(_unicornId) {
        //модификатор onlyOwnerOf гарантирует, что owner = msg.sender
        //        address owner = ownerOf(_unicornId);
        require(_to != msg.sender);
        if (approvedFor(_unicornId) != address(0) || _to != address(0)) {
            unicornApprovals[_unicornId] = _to;
            Approval(msg.sender, _to, _unicornId);
        }
    }

    /**
    * @dev Claims the ownership of a given unicorn ID
    * @param _unicornId uint256 ID of the unicorn being claimed by the msg.sender
    */
    function takeOwnership(uint256 _unicornId) public {
        require(allowance(msg.sender, _unicornId));
        clearApprovalAndTransfer(ownerOf(_unicornId), msg.sender, _unicornId);
    }

    /**
    * @dev Transfers the ownership of a given unicorn ID to another address
    * @param _to address to receive the ownership of the given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to be transferred
    */
    function transfer(address _to, uint256 _unicornId) public onlyOwnerOf(_unicornId) {
        clearApprovalAndTransfer(msg.sender, _to, _unicornId);
    }

    /**
    * @dev Internal function to clear current approval and transfer the ownership of a given unicorn ID
    * @param _from address which you want to send unicorns from
    * @param _to address which you want to transfer the unicorn to
    * @param _unicornId uint256 ID of the unicorn to be transferred
    */
    function clearApprovalAndTransfer(address _from, address _to, uint256 _unicornId) internal {
        require(owns(_from, _unicornId));
        require(_to != address(0));
        require(_to != ownerOf(_unicornId));

        if (offers[unicornOffer[_unicornId]].exists) {
            _removeFromMarket(_unicornId);
            //OfferAutoCancel(unicornOffer[_unicornId], _unicornId);
        }

        clearApproval(_from, _unicornId);
        removeUnicorn(_from, _unicornId);
        addUnicorn(_to, _unicornId);
        Transfer(_from, _to, _unicornId);
    }

    /**
    * @dev Internal function to clear current approval of a given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to be transferred
    */
    function clearApproval(address _owner, uint256 _unicornId) private {
        require(owns(_owner, _unicornId));
        unicornApprovals[_unicornId] = 0;
        Approval(_owner, 0, _unicornId);
    }

    /**
    * @dev Internal function to add a unicorn ID to the list of a given address
    * @param _to address representing the new owner of the given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to be added to the unicorns list of the given address
    */
    function addUnicorn(address _to, uint256 _unicornId) private {
        require(unicornOwner[_unicornId] == address(0));
        unicornOwner[_unicornId] = _to;
        //        uint256 length = balanceOf(_to);
        uint256 length = ownedUnicorns[_to].length;
        ownedUnicorns[_to].push(_unicornId);
        ownedUnicornsIndex[_unicornId] = length;
        totalUnicorns = totalUnicorns.add(1);
    }

    /**
    * @dev Internal function to remove a unicorn ID from the list of a given address
    * @param _from address representing the previous owner of the given unicorn ID
    * @param _unicornId uint256 ID of the unicorn to be removed from the unicorns list of the given address
    */
    function removeUnicorn(address _from, uint256 _unicornId) private {
        require(owns(_from, _unicornId));

        uint256 unicornIndex = ownedUnicornsIndex[_unicornId];
        //        uint256 lastUnicornIndex = balanceOf(_from).sub(1);
        uint256 lastUnicornIndex = ownedUnicorns[_from].length.sub(1);
        uint256 lastUnicorn = ownedUnicorns[_from][lastUnicornIndex];

        unicornOwner[_unicornId] = 0;
        ownedUnicorns[_from][unicornIndex] = lastUnicorn;
        ownedUnicorns[_from][lastUnicornIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both unicornIndex and lastUnicornIndex are going to
        // be zero. Then we can make sure that we will remove _unicornId from the ownedUnicorns list since we are first swapping
        // the lastUnicorn to the first position, and then dropping the element placed in the last position of the list

        ownedUnicorns[_from].length--;
        ownedUnicornsIndex[_unicornId] = 0;
        ownedUnicornsIndex[lastUnicorn] = unicornIndex;
        totalUnicorns = totalUnicorns.sub(1);
    }

    /**
    * @dev Mint unicorn function
    * @param _to The address that will own the minted unicorn
    * @param _unicornId uint256 ID of the unicorn to be minted by the msg.sender
    */
    //    function _mint(address _to, uint256 _unicornId, Unicorn _unicorn) internal {
    //        require(_to != address(0));
    //        addUnicorn(_to, _unicornId);
    //        //store new unicorn data
    //        unicorns[_unicornId] = _unicorn;
    //        Transfer(0x0, _to, _unicornId);
    //    }

    /**
    * @dev Burns a specific unicorn
    * @param _unicornId uint256 ID of the unicorn being burned by the msg.sender
    */

    function _burn(uint256 _unicornId) onlyOwnerOf(_unicornId) internal {
        if (approvedFor(_unicornId) != 0) {
            clearApproval(msg.sender, _unicornId);
        }
        removeUnicorn(msg.sender, _unicornId);
        //destroy unicorn data
        delete unicorns[_unicornId];
        Transfer(msg.sender, 0x0, _unicornId);
    }

    //specific

    function _createUnicorn(address _owner) internal returns (uint)    {
        require(_owner != address(0));
        uint256 _unicornId = totalUnicorns;
        addUnicorn(_owner, _unicornId);
        //store new unicorn data
        unicorns[_unicornId] = Unicorn({
            gen : new bytes(0),
            birthTime : uint64(now),
            freezingEndTime : 0,
            freezingTourEndTime: 0,
            name: ''
            });
        Transfer(0x0, _owner, _unicornId);
        //        _mint(_owner, _unicornId, _unicorn);
        return _unicornId;
    }


    function owns(address _claimant, uint256 _unicornId) public view returns (bool) {
        return ownerOf(_unicornId) == _claimant && ownerOf(_unicornId) != address(0);
    }


    function transferFrom(address _from, address _to, uint256 _unicornId) public {
        require(_to != address(this));
        require(allowance(msg.sender, _unicornId));
        clearApprovalAndTransfer(_from, _to, _unicornId);
    }


    function fromHexChar(uint8 _c) internal pure returns (uint8) {
        return _c - (_c < 58 ? 48 : (_c < 97 ? 55 : 87));
    }


    function getUnicornGenByte(uint _unicornId, uint _byteNo) public view returns (uint8) {
        uint n = _byteNo << 1; // = _byteNo * 2
        //        require(unicorns[_unicornId].gen.length >= n + 1);
        if (unicorns[_unicornId].gen.length < n + 1) {
            return 0;
        }
        return fromHexChar(uint8(unicorns[_unicornId].gen[n])) << 4 | fromHexChar(uint8(unicorns[_unicornId].gen[n + 1]));
    }


    function setName(uint256 _unicornId, string _name ) public onlyOwnerOf(_unicornId) returns (bool) {
        bytes memory tmp = bytes(unicorns[_unicornId].name);
        require(tmp.length == 0);

        unicorns[_unicornId].name = _name;
        return true;
    }


    function setFreezing(uint _unicornId) internal {
        unicorns[_unicornId].freezingEndTime = uint64(_getFreezeTime(getUnicornGenByte(_unicornId, 163)) + now);
        UnicornFreezingTimeSet(_unicornId, unicorns[_unicornId].freezingEndTime);
    }

    function setTourFreezing(uint _unicornId) public onlyTournament {
        unicorns[_unicornId].freezingTourEndTime = uint64(_getFreezeTime(getUnicornGenByte(_unicornId, 168)) + now);
        UnicornTourFreezingTimeSet(_unicornId, unicorns[_unicornId].freezingTourEndTime);
    }

    function _getFreezeTime(uint8 freezingIndex) internal view returns (uint time) {
        freezingIndex %= maxFreezingIndex;
        time = freezing[freezingIndex];
        if (freezingPlusCount[freezingIndex] != 0) {
            time += (uint(block.blockhash(block.number - 1)) % freezingPlusCount[freezingIndex]) * 1 hours;
        }
    }


    function setGen(uint _unicornId, bytes _gen) onlyBlackBox public {
        require(unicorns[_unicornId].gen.length == 0);
        unicorns[_unicornId].gen = _gen;
        UnicornGeneSet(_unicornId);
    }

    function getGen(uint _unicornId) external view returns (bytes){
        return unicorns[_unicornId].gen;
    }


    function approveForGeneLab(uint256 _unicornId) public onlyOwnerOf(_unicornId) {
        unicornApprovalsForGeneLab[_unicornId] = true;
    }


    function clearApprovalForGeneLab(uint256 _unicornId) public onlyOwnerOf(_unicornId) {
        delete unicornApprovalsForGeneLab[_unicornId];
    }


    function updateGen(uint _unicornId, bytes _gen) onlyGeneLab public {
        require(unicornApprovalsForGeneLab[_unicornId]);
        unicorns[_unicornId].gen = _gen;
        delete unicornApprovalsForGeneLab[_unicornId];
        UnicornGeneUpdate(_unicornId);
    }


    function _addToMarket(uint _unicornId, uint _price) internal {
        uint256 _offerId = ++lastOfferId;
        offers[_offerId] = Offer({
            unicorn_id: _unicornId,
            price: _price,
            exists: true,
            marketIndex: marketSize++
            });

        unicornOffer[_unicornId] = _offerId;
        market[offers[_offerId].marketIndex] = _offerId;

        NewOffer(msg.sender, _offerId, _unicornId, _price);
    }

    function _removeFromMarket(uint _unicornId) internal {
        offers[market[--marketSize]].marketIndex = offers[unicornOffer[_unicornId]].marketIndex;
        market[offers[unicornOffer[_unicornId]].marketIndex] = market[marketSize];

        OfferDelete(msg.sender, unicornOffer[_unicornId], _unicornId);

        delete market[marketSize];
        delete offers[unicornOffer[_unicornId]];
        delete unicornOffer[_unicornId];
    }


}


contract UnicornControl is UnicornBase {
    using SafeMath for uint;

    event HybridizationAdded(uint indexed lastHybridizationId, uint indexed unicornId, uint price);
    event HybridizationAccepted(uint indexed hybridizationId, uint indexed unicornId, uint newUnicornId);
    event HybridizationCancelled(uint indexed hybridizationId);
    event FundsTransferred(address dividendManager, uint value);
    event CreateUnicorn(address indexed owner, uint indexed unicornId, uint indexed parent1, uint  parent2);
    event NewGen0Limit(uint limit);
    event NewGen0Step(uint step);


    ERC20 public candyToken; //SET on deploy
    ERC20 public candyPowerToken; //SET on deploy

    //counter for gen0
    uint public gen0Limit = 30000;
    uint public gen0Count = 0;
    uint public gen0Step = 1000;

    uint internal maxType = 2;
    //limits for presale
    uint32[3] public typeLimits = [
    150, 40, 10
    ];

    uint[3] public typeCounter = [
    0, 0, 0
    ];

    //    uint public oraclizeFee;

    uint public lastHybridizationId = 0;

    struct Hybridization{
        uint unicorn_id;
        uint price;
        uint second_unicorn_id;
        bool accepted;
        bool exists;
    }

    // Mapping from hybridization ID to Hybridization struct
    mapping (uint => Hybridization) public hybridizations;
    // Mapping from unicorn ID to list of it hybridization IDs
    mapping (uint => uint[]) private unicornHybridizations;
    // Mapping from hybridization ID to index of the unicorn ID hybridizations list
    mapping(uint => uint) private unicornHybridizationsIndex;


    function UnicornControl(address _unicornManagementAddress) UnicornAccessControl(_unicornManagementAddress) public {

    }

    function() public payable {

    }

    function makeHybridization(uint _unicornId, uint _price) onlyOwnerOf(_unicornId) public returns (uint)    {
        require(isReadyForHybridization(_unicornId));

        uint256 _hybridizationId = ++lastHybridizationId;
        Hybridization storage h = hybridizations[_hybridizationId];

        h.unicorn_id = _unicornId;
        h.price = _price;
        h.exists = true;

        // save hybridization in mapping for unicorn
        uint256 newHIndex = unicornHybridizations[h.unicorn_id].length;
        unicornHybridizations[h.unicorn_id].push(_hybridizationId); //save hybridization ID in array
        unicornHybridizationsIndex[_hybridizationId] = newHIndex; //save index for hybridization

        HybridizationAdded(_hybridizationId, h.unicorn_id, h.price);

        return _hybridizationId;
    }


    function acceptHybridization(uint _hybridizationId, uint _unicornId) onlyOwnerOf(_unicornId) whenNotPaused public payable    {
        Hybridization storage h = hybridizations[_hybridizationId];
        require(h.exists && !h.accepted);
        require(_unicornId != h.unicorn_id);
        require(isReadyForHybridization(_unicornId) && isReadyForHybridization(h.unicorn_id));

        require(msg.value == unicornManagement.oraclizeFee());
        require(candyToken.transferFrom(msg.sender, this, getHybridizationPrice(_hybridizationId)));

        //require(msg.value == getHybridizationPrice(_hybridizationId));


        h.second_unicorn_id = _unicornId;
        // !!!
        h.accepted = true;
        setFreezing(_unicornId);

        uint256 childUnicornId  = _createUnicorn(msg.sender);

        CreateUnicorn(msg.sender, childUnicornId, h.unicorn_id, h.second_unicorn_id);

        blackBoxContract.genCore.value(unicornManagement.oraclizeFee())(childUnicornId, h.unicorn_id, h.second_unicorn_id);

        ownerOf(h.unicorn_id).transfer(h.price);
        HybridizationAccepted(_hybridizationId, _unicornId, childUnicornId);
    }


    function cancelHybridization (uint _hybridizationId) public     {
        Hybridization storage h = hybridizations[_hybridizationId];
        require(h.exists && !h.accepted);
        require(owns(msg.sender, h.unicorn_id));

        // remove hybridization in mapping for unicorn
        uint256 hIndex = unicornHybridizationsIndex[_hybridizationId];
        uint256 lastHIndex = unicornHybridizations[h.unicorn_id].length.sub(1);
        uint256 lastHId = unicornHybridizations[h.unicorn_id][lastHIndex];

        unicornHybridizations[h.unicorn_id][hIndex] = lastHId; //replace hybridization ID with last
        unicornHybridizationsIndex[lastHId] = hIndex; //update index for last hybridization ID
        unicornHybridizations[h.unicorn_id][lastHIndex] = 0; //reset hybridization ID at last postion
        unicornHybridizations[h.unicorn_id].length--; //reduce array size
        unicornHybridizationsIndex[_hybridizationId] = 0; // reset hybridization ID index

        delete hybridizations[_hybridizationId];

        HybridizationCancelled(_hybridizationId);
    }


    // Gets the list of hybridizations of unicorn
    function hybridizationsOf(uint _unicornId) public view returns (uint256[]) {
        return unicornHybridizations[_unicornId];
    }


    //Create new 0 gen
    function createUnicorn() public payable whenNotPaused returns(uint256)   {
        require(gen0Count < gen0Limit);
        require(msg.value == getCreateUnicornPrice());

        uint256 newUnicornId = _createUnicorn(msg.sender);

        gen0Count = gen0Count.add(1);

        blackBoxContract.createGen0.value(unicornManagement.oraclizeFee())(newUnicornId,0);

        CreateUnicorn(msg.sender,newUnicornId,0,0);
        return newUnicornId;
    }


    function createUnicornForCandy() public payable whenNotPaused returns(uint256)   {
        require(gen0Count < gen0Limit);

        candyToken = ERC20(unicornManagement.candyToken());

        require(msg.value == unicornManagement.oraclizeFee());
        require(candyToken.transferFrom(msg.sender, this, getCreateUnicornPriceInCandy()));


        uint256 newUnicornId = _createUnicorn(msg.sender);

        gen0Count = gen0Count.add(1);

        //blackBoxContract.createGen0(newUnicornId,0);
        blackBoxContract.createGen0.value(unicornManagement.oraclizeFee())(newUnicornId,0);

        CreateUnicorn(msg.sender,newUnicornId,0,0);
        return newUnicornId;
    }


    //Create new 0 gen
    function createPresaleUnicorn(address _owner, uint _type) public payable onlyManager whenNotPaused returns(uint256)   {
        _type %= maxType;
        require(typeCounter[_type] <= typeLimits[_type]);
        //TODO ?? oraclizeFee
        require(msg.value == unicornManagement.oraclizeFee());

        uint256 newUnicornId = _createUnicorn(_owner);

        typeCounter[_type] = typeCounter[_type].add(1);

        //gen0Count.add(1);

        blackBoxContract.createGen0.value(unicornManagement.oraclizeFee())(newUnicornId,_type);

        CreateUnicorn(msg.sender,newUnicornId,0,0);
        return newUnicornId;
    }


    function isReadyForHybridization(uint _unicornId) public view returns (bool)    {
        return (unicorns[_unicornId].birthTime > 0 && unicorns[_unicornId].freezingEndTime <= uint64(now));
    }


    //change freezing time for candy
    function minusFreezingTime(uint _unicornId) public {
        //не минусуем на уже размороженных конях
        require(unicorns[_unicornId].freezingEndTime > now);
        require(candyPowerToken.transferFrom(msg.sender, this, unicornManagement.subFreezingPrice()));
        //не используем safeMath, т.к. subFreezingTime в теории не должен быть больше now %)
        unicorns[_unicornId].freezingEndTime -= unicornManagement.subFreezingTime();
    }

    //change tour freezing time for candy
    function minusTourFreezingTime(uint _unicornId) public {
        //не минусуем на уже размороженных конях
        candyPowerToken = ERC20(unicornManagement.candyPowerToken());
        require(unicorns[_unicornId].freezingTourEndTime > now);
        require(candyPowerToken.transferFrom(msg.sender, this, unicornManagement.subTourFreezingPrice()));
        //не используем safeMath, т.к. subTourFreezingTime в теории не должен быть больше now %)
        unicorns[_unicornId].freezingTourEndTime -= unicornManagement.subTourFreezingTime();
    }


    function getHybridizationPrice(uint _hybridizationId) public view returns (uint) {
        Hybridization storage h = hybridizations[_hybridizationId];
        return unicornManagement.getHybridizationFullPrice(h.price);
    }

    function getEtherFeeForPriceInCandy() public view returns (uint) {
        return unicornManagement.oraclizeFee();
    }

    function getCreateUnicornPriceInCandy() public view returns (uint) {
        return unicornManagement.getCreateUnicornFullPriceInCandy();
    }


    function getCreateUnicornPrice() public view returns (uint) {
        return unicornManagement.getCreateUnicornFullPrice();
    }


    function withdrawTokens() onlyManager public {
        candyPowerToken = ERC20(unicornManagement.candyPowerToken());
        candyToken = ERC20(unicornManagement.candyToken());
        uint balanceCandy = candyToken.balanceOf(this);
        uint balancePowerCandy = candyPowerToken.balanceOf(this);
        require(balanceCandy > 0 || balancePowerCandy > 0);
        if (balanceCandy > 0) {
            candyToken.transfer(unicornManagement.walletAddress(), balanceCandy);
        }
        if (balancePowerCandy > 0) {
            candyPowerToken.transfer(unicornManagement.walletAddress(), balancePowerCandy);
        }
    }


    function transferEthersToDividendManager(uint _value) onlyManager public {
        require(this.balance >= _value);
        DividendManagerInterface dividendManager = DividendManagerInterface(unicornManagement.dividendManagerAddress());
        dividendManager.payDividend.value(_value)();
        FundsTransferred(unicornManagement.dividendManagerAddress(), _value);
    }


    function setGen0Limit() external onlyCommunity {
        require(gen0Count == gen0Limit);
        gen0Limit = gen0Limit.add(gen0Step);
        NewGen0Limit(gen0Limit);
    }

    function setGen0Step(uint _step) external onlyCommunity {
        gen0Step = _step;
        NewGen0Step(gen0Limit);
    }

    function sellUnicorn(uint _unicornId, uint _price) onlyOwnerOf(_unicornId) public {
        require(!offers[unicornOffer[_unicornId]].exists);
        _addToMarket(_unicornId, _price);
    }


    function buyUnicorn(uint _unicornId) public payable {
        Offer storage o = offers[unicornOffer[_unicornId]];
        require(msg.value == unicornManagement.getSellUnicornFullPrice(o.price));
        require(o.exists);

        address owner = ownerOf(_unicornId);

        uint _offerId = unicornOffer[_unicornId];
        //_removeFromMarket(_unicornId); //должна сработать в clearApprovalAndTransfer
        clearApprovalAndTransfer(owner, msg.sender, _unicornId);
        owner.transfer(o.price);

        UnicornSold(msg.sender, _offerId, _unicornId);
    }


    function revokeUnicorn(uint _unicornId) onlyOwnerOf(_unicornId) public {
        require(offers[unicornOffer[_unicornId]].exists);
        _removeFromMarket(_unicornId);
    }


    function getSellUnicornPrice(uint _unicornId) public view returns (uint) {
        return unicornManagement.getSellUnicornFullPrice(offers[unicornOffer[_unicornId]].price);
    }


}
