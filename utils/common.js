const MerkleTree = require('merkletreejs');
const keccak256 = require('keccak256');

export const getMerkleRoot = (addresses)=>{
    const leaves = addresses.map(x => keccak256(x))
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })
    const buf2hex = x => '0x' + x.toString('hex')
    const root = buf2hex(tree.getRoot());
    console.log(buf2hex(tree.getRoot()))
    return root;
}


