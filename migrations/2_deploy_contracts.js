const PhotoSharing = artifacts.require("PhotoSharing");

module.exports = function(deployer) {
  const reward = '1';
  deployer.deploy(PhotoSharing, reward);
};