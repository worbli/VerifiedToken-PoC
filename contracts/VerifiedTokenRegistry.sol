pragma solidity ^0.4.23;

/// @title: VerifiedTokenRegistry
/// @summary: Registries management contract
/// Created on 2018-04-10 12:00
/// @author: Blockchain Labs, NZ

import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract VerifiedTokenRegistry is Ownable {
    /*
     * @dev: [receiver address => [key => value]]
     * @dev: Example:
     * @dev: 0x12.. => ["type" => "exchange"]
     * @dev: 0x12.. => ["age group" => "20-30"]
     */
    mapping(address => mapping(bytes32 => bytes32)) private record;

    struct pairs {
        bytes32 key;
        bytes32 value;
    }

    /*
     *  @dev: keys used by registry (in records).
     *  @dev: Array of keys is needed to iterate through them, and mapping is used to
     *  @dev: decrease the gas of checking whether the new key is need to be added to array or not.
     */
    bytes32[] public keys;
    mapping(bytes32 => bool) private key;

    event RecordUpdated(
        address indexed registry,
        address indexed receiver,
        bytes32 key,
        bytes32 value,
        uint updatedAt);

    event AddressDeleted(
        address indexed registry,
        address indexed receiver,
        uint updatedAt);

    /*
     * @notice: Registry can add new addresses to the list or update existed
     */
    function updateRecord(address _receiver, bytes32 _key, bytes32 _value) public onlyOwner {
        record[_receiver][_key] = _value;
        if(!isExist(_key))
            addNewKey(_key);
        emit RecordUpdated(this, _receiver, _key, _value, now);
    }

    /*
     * @notice: Registry can remove the given address completely
     */
    function deleteAddress(address _receiver) public onlyOwner {
        for(uint256 i = 0; i < keys.length; i++ )
            delete record[_receiver][keys[i]];
        emit AddressDeleted(this, _receiver, now);
    }

    /*
     * @dev: Check if registry contains the record with verifying address and pair key => value
     */
    function findAddress(address _receiver, bytes32 _key, bytes32 _value) public view returns(bool) {
        return(record[_receiver][_key] == _value);
    }

    /*
     * @dev: check if key is already exist
     */
    function isExist(bytes32 _key) public view returns(bool) {
        return(key[_key]);
    }

    /*
     * @dev: add new key to mapping and array
     */
    function addNewKey(bytes32 _key) internal returns(bool) {
        keys.push(_key);
        key[_key] = true;
    }

    /*
     * @dev: returns key=>value pairs of given receiver
     */
    function getAddressPairs(address _receiver) public view returns(bytes32[], bytes32[]) {
        uint256 maxNumberOfPairs = keys.length;
        bytes32 currentValue;

        bytes32[] memory receiverKeys = new bytes32[](maxNumberOfPairs);
        bytes32[] memory receiverValues = new bytes32[](maxNumberOfPairs);
        uint256 iteratorOfPairsOfReceiver;

        for(uint256 i = 0; i < keys.length; i++ ) {
            currentValue= record[_receiver][keys[i]];
            if(currentValue != 0) {
                receiverKeys[iteratorOfPairsOfReceiver] = keys[i];
                receiverValues[iteratorOfPairsOfReceiver] = currentValue;
                iteratorOfPairsOfReceiver++;
            }
        }

        bytes32[] memory returnKeys = new bytes32[](iteratorOfPairsOfReceiver);
        bytes32[] memory returnValues = new bytes32[](iteratorOfPairsOfReceiver);

        for(i = 0; i < iteratorOfPairsOfReceiver; i++ ) {
            returnKeys[i] = receiverKeys[i];
            returnValues[i] = receiverValues[i];
        }

        return(returnKeys, returnValues);
    }

}
