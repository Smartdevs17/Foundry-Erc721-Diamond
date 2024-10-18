const fs = require('fs');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const csv = require('csv-parser');
const { ethers } = require("hardhat");



async function generateMerkleRoot() {
  return new Promise((resolve, reject) => {
    let results = [];
  
    fs.createReadStream('airdrop.csv')
      .pipe(csv())
      .on('data', (row) => {  
        const address = row.address;
        const amount = row.amount;
        const leaf = keccak256(
          ethers.utils.solidityPack(["address", "uint256"], [address, amount])
        );
        results.push(leaf);
      })
      .on('end', () => {
        const tree = new MerkleTree(results, keccak256, {
          sortPairs: true,
        });
  
        const roothash = tree.getHexRoot();
        console.log('Merkle Root:', roothash);
  
        resolve(roothash);  
      })
      .on('error', reject); 
  });
}

// The function then generates a proof for the target address and amount, and returns the proof.
async function generateMerkleProof(targetAddress, targetAmount) {
  const userData = await getUserDataFromCSV();
  
  return new Promise((resolve, reject) => {
    console.log(`Starting to generate proof for address: ${targetAddress}, amount: ${targetAmount}`);
  
    let results = userData.map((user) => 
      keccak256(
        ethers.utils.solidityPack(["address", "uint256"], [user.address, user.amount])
      )
    );
  
    const tree = new MerkleTree(results, keccak256, {
      sortPairs: true,
    });
  
    const targetLeaf = keccak256(
      ethers.utils.solidityPack(["address", "uint256"], [targetAddress, targetAmount])
    );
    const isLeafPresent = results.includes(targetLeaf);
    // console.log('Is Target Leaf Present:', isLeafPresent); // Check if the target leaf is in the results
    const proof = tree.getHexProof(targetLeaf);
    console.log(proof);
    
    resolve(proof);
  });
}

// It first fetches the user data from the CSV file, then constructs a Merkle tree using the user data.
async function getUserDataFromCSV() {
  return new Promise((resolve, reject) => {
    let userData = [];
  
    fs.createReadStream('airdrop.csv')
      .pipe(csv())
      .on('data', (row) => { 
        userData.push({ address: row.address, amount: row.amount });
      })
      .on('end', () => {
        resolve(userData);
      })
      .on('error', reject);
  });
}

async function main() {
  const merkleRoot = await generateMerkleRoot();
  console.log('Merkle Root:', merkleRoot);

  const proof = await generateMerkleProof('0xaAa2DA255DF9Ee74C7075bCB6D81f97940908A5D', ethers.utils.parseEther('100'));
  console.log('Merkle Proof:', proof);
}

main();
module.exports = { generateMerkleRoot, generateMerkleProof };
