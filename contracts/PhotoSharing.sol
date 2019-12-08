pragma solidity 0.5.12;

contract PhotoSharing {

    address public admin;
    uint public rewardPrice;
    mapping(uint256 => Post) posts;
    uint256 postCnt;
    address public addressDefault = 0x0000000000000000000000000000000000000000;

    constructor(uint _price) public {
      admin = msg.sender;
      rewardPrice = _price;
    }

    struct Post {
        address payable owner;
        string imgHash;
        string textHash;
        uint256 reviewCnt;
        mapping (address => uint256) reviewerList;
        bool isRewarded;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin,
            "the caller of this function must be the administrator");
        _;
    }

    event NewPost();

    /**
     * @dev Function to register image & text hashes.
     * @param _imgHash hash from IPFS.
     * @param _textHash hash from IPFS.
     */
    function sendPost(string memory _imgHash, string memory _textHash) public {
        Post storage posting = posts[postCnt];
        posting.owner = msg.sender;
        posting.imgHash = _imgHash;
        posting.textHash = _textHash;

        emit NewPost();
    }
    /**
     * @dev Function to get image & text hashes.
     * @param _idx The number of photo location.
     * @return Registered image & text hashes.
     */
    function getHash(uint256 _idx) public view
        returns (
            string memory imgHash,
            string memory textHash,
            address owner,
            uint256 reviewCnt
        )
    {
        owner = posts[_idx].owner;
        imgHash = posts[_idx].imgHash;
        textHash = posts[_idx].textHash;
        reviewCnt = posts[_idx].reviewCnt;
    }

    /**
     * @dev Function to get length of total posts.
     * @return The total count of posts.
     */
    function getCounter() public view returns(uint256) { return postCnt; }

    /**
     * @dev Function to review a image by one account.
     * @param _idx The number of photo location.
     * @return result true or false.
     */
    function review(uint256 _index) public returns (bool)  {
        // same address user don't review twice.
        if (msg.sender != addressDefault && posts[_index].reviewerList[msg.sender] == 0) {
            posts[_index].reviewerList[msg.sender] = 1;
            posts[_index].reviewCnt += 1;
            return true;
        }
        return false;
    }

    function reward() public onlyAdmin returns (bool status) {
        uint256 winnerIdx;
        address payable winnerAddress;
        for (uint256 i = 0; postCnt > i; i++) {
            if (posts[i].isRewarded) continue;
            if (winnerAddress == addressDefault) {
                winnerAddress = posts[i].owner;
                winnerIdx = i;
                continue;
            }
            if (posts[winnerIdx].reviewCnt < posts[i].reviewCnt) {
                winnerAddress = posts[i].owner;
                winnerIdx = i;
            }
        }
        if (winnerAddress != addressDefault) {
            winnerAddress.transfer(rewardPrice);
            return true;
        }
        return false;
    }
}
