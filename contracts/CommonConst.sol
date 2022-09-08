// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CommonConst is OwnableUpgradeable {
    uint nonce;
    uint typeCount;

    struct IngredientType {
        uint from;
        uint to;
        uint[] tokenIds;
    }
    mapping(uint => IngredientType) ingredientTypes;

    uint[]  tokenIds1;
    uint[]  tokenIds2;
    uint[]  tokenIds3;
    uint[]  tokenIds4;
    uint[]  tokenIds5;

    function __Common_init() internal onlyInitializing {
        ingredientTypes[1] = IngredientType({from:1,to:46,tokenIds:tokenIds1});
        ingredientTypes[2] = IngredientType({from:47,to:76,tokenIds:tokenIds2});
        ingredientTypes[3] = IngredientType({from:77,to:91,tokenIds:tokenIds3});
        ingredientTypes[4] = IngredientType({from:92,to:99,tokenIds:tokenIds4});
        ingredientTypes[5] = IngredientType({from:100,to:100,tokenIds:tokenIds5});
        nonce = 1;
        typeCount=5;
        tokenIds1 = [1,2,3,4,5];
        tokenIds2 = [6,7,8];
        tokenIds3 = [9,10,11,12,13,14,15,16,17,18,19];
        tokenIds4 = [20,21,22,23,24];
        tokenIds5 = [25];
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
}