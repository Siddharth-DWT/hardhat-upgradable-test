// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

contract ErrandBossCardStake is  ReentrancyGuard, Ownable{
    uint256 public timeForReward;
    address bossCardERC1155;
    struct BossStake {
        uint tokenId;
        uint256  time;
    }
    uint[] legendaryBoost;
    uint[] shinyBoost;

    mapping(address => BossStake)  public bossStakes;
    constructor(address _bossCardERC1155) {
        bossCardERC1155 = _bossCardERC1155;
        legendaryBoost =[27,49,79];
        shinyBoost = [28,50,80];
        timeForReward = 24 hours;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory)  virtual public returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function indexOf(uint[] memory self, uint value) internal pure returns (int) {
        for (uint i = 0; i < self.length; i++)if (self[i] == value) return int(i);
        return -1;
    }

    function bossCardStake(uint _tokenId) external{
        require(
            indexOf(legendaryBoost,_tokenId) >= 0 || indexOf(shinyBoost,_tokenId) >=0,
            "Not valid boost token for stake"
        );
        require(
            bossStakes[msg.sender].tokenId ==0,
            "Boost token already stake"
        );
        bossStakes[msg.sender].tokenId =_tokenId;
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function bossCardWithdraw(uint _tokenId) external nonReentrant{
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossStakes[msg.sender];
    }

    function getBossCountClaim(uint256 stakedTime) public view returns(uint){
        uint bossCount = 0;
        if(bossStakes[msg.sender].tokenId !=0){
            uint bossNumber = 1;
            if(indexOf(shinyBoost,bossStakes[msg.sender].tokenId) > 0){
                bossNumber = 2;
            }
            bossCount = (((block.timestamp - stakedTime ) / timeForReward )) * bossNumber;
        }
        return bossCount;
    }
    function printBossCardStake() external view returns (uint) {
        return(bossStakes[msg.sender].tokenId);
    }

    function getUserStakeBossCardId(address _account) external  view returns (uint) {
        return(bossStakes[_account].tokenId);
    }

}