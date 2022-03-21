pragma solidity ^0.8.10;
import "./Counter.sol";

// Standard Counter Implementation

contract NaiveCounter is Counter {
    mapping(uint256 => bool) seen;
    mapping(uint256 => uint256) keyToCount;
    uint256[] keys;

    constructor() {}

    // note we are not caching the curMax and curMin count here because there are both increment and decrement operation,
    // so we have to recompute everytime.
    function increment(uint256 key) external override {
        if (!seen[key]) {
            keys.push(key);
            seen[key] = true;
        }
        keyToCount[key]++;
    }

    function decrement(uint256 key) external override {
        if (keyToCount[key] > 0) keyToCount[key]--;
    }

    function getMaxKeys()
        public
        view
        override
        returns (uint256[] memory maxKey)
    {
        uint256[] memory maxKey = new uint256[](keys.length);
        uint256 maxCount = 0;
        uint256 index = 0;
        // find min count
        for (uint256 i = 0; i < keys.length; i++) {
            if (keyToCount[keys[i]] == 0) continue;
            if (keyToCount[keys[i]] > maxCount) {
                maxCount = keyToCount[keys[i]];
                index = 0;
                maxKey[index] = keys[i];
                index++;
            } else if (keyToCount[keys[i]] == maxCount) {
                maxKey[index] = keys[i];
                index++;
            } else {
                //no op
            }
        }
        return maxKey;
    }

    function getMinKeys()
        public
        view
        override
        returns (uint256[] memory minKey)
    {
        uint256[] memory minKey = new uint256[](keys.length);
        uint256 minCount = 0;
        uint256 index = 0;
        // find min count
        for (uint256 i = 0; i < keys.length; i++) {
            if (keyToCount[keys[i]] == 0) continue;
            if (keyToCount[keys[i]] > minCount) {
                minCount = keyToCount[keys[i]];
                index = 0;
                minKey[index] = keys[i];
                index++;
            } else if (keyToCount[keys[i]] == minCount) {
                minKey[index] = keys[i];
                index++;
            } else {
                //no op
            }
        }
        return minKey;
    }
}
