const {CONTRACT_NAME_MAP, approveContract, generateSignature,sumOf} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const {parse} = require("dotenv");
const executeBase = false;
const stakePancake = false, stakeBossCard=false,revealReward=false, getUserFeeds=true; //upgradeContract=true
const accountArr = ["0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276", 
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x80f20b8de26ce786e2639c44fa68f685c58aa97d",
"0x80f20b8de26ce786e2639c44fa68f685c58aa97d",
"0x80f20b8de26ce786e2639c44fa68f685c58aa97d",
"0x01fb8f7d19a1d6ab892ee6593cd5b15f69f2e199",
"0x80f20b8de26ce786e2639c44fa68f685c58aa97d",
"0xc47ac3dd8b3fcd13c21d567d641a74b7272d5f78",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x80f20b8de26ce786e2639c44fa68f685c58aa97d",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0x404f0fa265e92198b7e3d332163aeecee0cffa95",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276",
"0xe01a963bdd48959e467a04dd2314431f27f60276"
];

async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.FeedV1);
    const DeployedContract = Contract.attach(address.FeedV1);

    const BossCardERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
    const DeployedBossContract = BossCardERC1155.attach(address.BossCardERC1155);

    const PancakeNftERC11155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PancakeNftERC11155);
    const DeployedPancakeContract = PancakeNftERC11155.attach(address.PancakeNftERC11155);

    const IngredientERC11155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
    const DeployedIngredientContract = IngredientERC11155.attach(address.IngredientsERC11155);

    if(executeBase){
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.FeedV1)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,address.IngredientsERC11155,address.FeedV1, true)
        await approveContract(CONTRACT_NAME_MAP.BossCardERC1155,address.BossCardERC1155,address.FeedV1, true)
    }

    // if(!upgradeContract){
    //     const {PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker} = address;
    //     await DeployedContract.updateContractAddress(PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker)
    //     console.log("contract address updated");
    // }

    if(stakePancake){
        const input1 = [4],input2 = [1], input3= 1140;
        const {signature,message} = generateSignature(process.env.OWNER,input3);
        console.log({signature})
        console.log({message})
        await DeployedContract.stake(input1,input2,input3,signature)
        console.log("pancake stake done1");
    }

    if(getUserFeeds){
        for(i=0;i<=1;i++){
            var getUserFeed = await DeployedContract.getUserFeeds(accountArr[i])
            console.log("getUserFeeds at account address index : ", i);
            console.log("getUserFeeds: ", getUserFeed);
        }
    }

    if(revealReward){
        var ingredientTokens = await DeployedIngredientContract.getWalletToken()
        var count = 0;
        ingredientTokens.forEach((item)=>{
            count = count + parseInt(item)
        })
        console.log("count before",count)
        let input1 = [1,0,0,0,0],input2 = [1,1],input3 = [0,0];
        //console.log("sumOf(input1),sumOf(input2),sumOf(input3)",sumOf(input1),sumOf(input2),sumOf(input3))
        const {signature,message} = generateSignature(process.env.OWNER,sumOf(input1),sumOf(input2),sumOf(input3));
        //console.log({signature})
        //input1 = [10,12,13,14,15]
        const response = await DeployedContract.reveal(input1,input2,input3,signature)
        //console.log("reveal done",response);
        var ingredientTokens = await DeployedIngredientContract.getWalletToken()
        //console.log("ingredientTokens",ingredientTokens)
        var count = 0;
        ingredientTokens.forEach((item)=>{
            count = count + parseInt(item)
        })
        console.log("count after",count)

    }
    if(stakeBossCard){
        const boostType =
            [{id:58, key:'legendary',value:20},
                {id:38, key:'cooldown',value:4},
                { id:59, key:'common',value:2},
                {id:17, key:'uncommon',value:2},
                {id:11, key:'rare',value:3},
                {id:5, key:'epic',value:5},
                {id:57, key:'legendary',value:10}]
        const {id,key,value} = boostType[0]
        const bossTokens = await DeployedBossContract.getWalletToken();
        console.log("bossTokens---",bossTokens);

        const {message,signature} = generateSignature(process.env.OWNER)
        console.log("signature--->",signature)
        try {
            const unstake = await DeployedContract.bossCardStake(id,key,value,signature)
            console.log("unstake------",unstake)
        }catch (e){
            console.log("error in unstake",e)
        }

        var response = await DeployedContract.printUserBossCardStake()
        console.log("bosscard stake",response);

    }


}
main()
