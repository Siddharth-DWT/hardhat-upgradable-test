// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CommonConst is OwnableUpgradeable {
    uint nonce = 1;
    uint typeCount;
    struct IngredientType {
        uint from;
        uint to;
        uint[] tokenIds;
    }
    mapping(uint => IngredientType) ingredientTypes;

    uint[] common = [1,2,3,4,5];
    uint[] uncommon = [6,7,8];
    uint[] rare = [9,10,11,12,13,14,15,16,17,18,19];
    uint[] epic = [20,21,22,23,24];
    uint[] legendary = [25];

    function __Common_init() internal initializer {
        typeCount = 5;
        ingredientTypes[1] = IngredientType({from:1,to:46,tokenIds:common});
        ingredientTypes[2] = IngredientType({from:47,to:76,tokenIds:uncommon});
        ingredientTypes[3] = IngredientType({from:77,to:91,tokenIds:rare});
        ingredientTypes[4] = IngredientType({from:92,to:99,tokenIds:epic});
        ingredientTypes[5] = IngredientType({from:100,to:100,tokenIds:legendary});
    }

    function __Common_initGen1() internal initializer {
        typeCount = 4;
        ingredientTypes[1] = IngredientType({from:1,to:60,tokenIds:common});
        ingredientTypes[2] = IngredientType({from:61,to:90,tokenIds:uncommon});
        ingredientTypes[3] = IngredientType({from:91,to:98,tokenIds:rare});
        ingredientTypes[4] = IngredientType({from:99,to:100,tokenIds:epic});
    }


    function random(uint from, uint to) internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % to;
        randomnumber = from + randomnumber ;
        nonce++;
        return randomnumber;
    }


    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }


    function setCategory(uint category,uint from, uint to, uint[] memory tokenIds) public onlyOwner{
        ingredientTypes[category] = IngredientType({from:from,to:to,tokenIds:tokenIds});
    }


    function getIngredientNftId(uint category) public returns(uint){
        IngredientType memory ingredient = ingredientTypes[category];
        uint to = ingredient.tokenIds.length;
        uint num = random(1, to);
        return ingredient.tokenIds[num-1];
    }

    function getCategory(uint number) public view returns(uint){
        uint index = 0;
        for(uint i=1;i<=typeCount;i++){
            if(number >= ingredientTypes[i].from &&  number <= ingredientTypes[i].to){
                index = i;
            }
        }
        return index;
    }

    function getRandomIngredientId() public returns(uint){
        uint number = random(1,100);
        uint category = getCategory(number);
        return getIngredientNftId(category);
    }

    function printCategory(uint category) public view returns(IngredientType memory){
        return ingredientTypes[category];
    }

    function isCommon(uint tokenId) public view  returns (bool){
        bool found= false;
        for (uint i=0; i<common.length; i++) {
            if(common[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isUncommon(uint tokenId) public view returns (bool){
        bool found= false;
        for (uint i=0; i<uncommon.length; i++) {
            if(uncommon[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isRare(uint tokenId) public view  returns (bool){
        bool found= false;
        for (uint i=0; i<rare.length; i++) {
            if(rare[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isEpic(uint tokenId) public view returns (bool){
        bool found= false;
        for (uint i=0; i<epic.length; i++) {
            if(epic[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }
    function isLegendary(uint tokenId) public view returns (bool){
        if(legendary[0] == tokenId){
            return true;
        }
        return false;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}