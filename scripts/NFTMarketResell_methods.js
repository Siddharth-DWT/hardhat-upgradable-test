const {CONTRACT_NAME_MAP, approveContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const {parse} = require("dotenv");

const BigNumber = require('bignumber.js');

// let num=new BigNumber(1252500000000000000)
// let denom = new BigNumber(10).pow(16)
// let ans = num.dividedBy(denom).toNumber()
// console.log(ans)

const listSale = true, mintnft = false, buyNft = false, cancelSale = false;

async function main(){

    const { BUYER } = process.env;

    const CollectionContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Collection);
    const DeployedCollectionContract = CollectionContract.attach(address.Collection);

    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.NFTMarketResell);
    const DeployedContract = Contract.attach(address.NFTMarketResell);

   // await approveContract(CONTRACT_NAME_MAP.Collection,address.Collection,address.NFTMarketResell)

    if(mintnft){
        var input1 = "0x404F0fA265E92198B7E3D332163AeECeE0CFfA95";
        var input2 = 1;
        await DeployedCollectionContract.mint(input1,input2)
        var owner = await DeployedCollectionContract.ownerOf(1)
        var balance = await DeployedCollectionContract.balanceOf(input1)
        console.log("Nft mint at address: ", owner);
        console.log("Amount of minted nft: ", balance);
        console.log("minting done!");
    }

    //listSale(uint256 tokenId, uint256 price)
    //BigNumber.from(600000000)
    if(listSale){
        const input1 = 16;
        //const EtherToWei = ethers.utils.parseUnits("0.0025","ether")
        //const EtherToWeiPrice = ethers.utils.parseUnits("0.1","ether")
        //const val = 1;

        var exp = ethers.BigNumber.from("10").pow(18);
        const supply = ethers.BigNumber.from("50").mul(exp);
        //5
        // const input3 = "0x404F0fA265E92198B7E3D332163AeECeE0CFfA95";
        // const seller = await DeployedCollectionContract.ownerOf(input1);
        // console.log("Seller: ", seller);
        await DeployedContract.listSale(input1, supply, { value: ethers.utils.parseEther("0.0025") });
        const holder = await DeployedCollectionContract.ownerOf(input1);
        console.log("Holder: ", holder);
        console.log("listing done!");  
    }


    if(buyNft){
        const input = 3;
        await DeployedContract.connect(BUYER).buyNft(input, { value: ethers.utils.parseEther("1") });
        const owner = await DeployedCollectionContract.ownerOf(input);
        console.log("Owner of nft: ", owner);

        // const seller = await DeployedCollectionContract.balanceOf(input);
        // console.log("Owner of nft: ", seller);
        console.log("buy nft done!");
    }

    if(cancelSale){
        var input = 9
        await DeployedContract.cancelSale(input)
        var owner = await DeployedCollectionContract.ownerOf(3);
        console.log("Owner of nft: ", owner);
        console.log("Sale cancalled!");
    }

    // var nftId = 1;
    // var response = await DeployedContract.getPrice(nftId)
    // console.log("response:",response);
    // //console.log("times",parse(response[4][0]));

    // var nftListingsResponse = await DeployedContract.nftListings()
    // console.log("nftListingsResponse:",nftListingsResponse);
}
main()
