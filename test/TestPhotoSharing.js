const PhotoSharing = artifacts.require("PhotoSharing");

var accounts; // List of development accounts provided by Truffle
var owner; // Global variable use it in the tests cases
var instance;

// This called the StartNotary Smart contract and initialize it
contract('PhotoSharing', (accs) => {
    accounts = accs; // Assigning test accounts
    owner = accounts[0]; // Assigning the owner test account
});

it('has correct price', async () => {
    instance = await PhotoSharing.deployed(); // Making sure the Smart Contract is deployed and getting the instance.
    const rewardPrice = await instance.rewardPrice.call();
    assert.equal(rewardPrice, 1);
});

it('is possible for account to send post', async () => {
    const imgHash = "QmPEKipMh6LsXzvtLxunSPP7ZsBM8y9xQ2SQQwBXy5UY6e";
    const textHash = "QmT8onRUfPgvkoPMdMvCHPYxh98iKCfFkBYM1ufYpnkHJn";
    const secondUser = accounts[1];
    await instance.sendPost(imgHash, textHash, {from: secondUser});
    const results = await instance.getHash(0);
    assert.equal(results[0], imgHash);
    assert.equal(results[1], textHash);
});

it('is possible for account to review post', async () => {
    const res = await instance.review(0);
    assert.equal(res.receipt.status, true);

    const res2 = await instance.getHash(0);
    assert.equal(res2.reviewCnt, 1);

    const secondUser = accounts[1];
    await instance.review(0, {from: secondUser});
    const res3 = await instance.getHash(0);
    assert.equal(res3.reviewCnt, 2);
});

it('is possible for admin to reward', async () => {
    const res = await instance.reward();
    assert.equal(res.receipt.status, true);
    //console.log(await web3.eth.getBalance(accounts[1]));
    //console.log(await web3.eth.getBalance(accounts[0]));
});

it('is not possible for account to reward', async () => {
    const secondUser = accounts[1];
    const res = await instance.reward({from: secondUser})
                  .catch(error => {
                    assert.equal(error.reason, "the caller of this function must be the administrator");
                  });
});

