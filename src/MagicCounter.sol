pragma solidity ^0.8.10;

import "./Counter.sol";

//  MagicCounter supports the following operation all in O(1).
//  increment the count of a *key*
//  decrement the count of a *key*
//  get max keys
//  get min keys
//
// How is this useful:
// This is very useful for something like the Least Frequently Used cache (LFU)
// For the LFU cache, you need to know the keys with min or max count at a certain point in the data stream in the most efficient way possible.

// How does this work🚂?
// It works by creating a doubly LinkedList⛓️ of *Bucket* which tracks: its count, next & previous bucket,
// and the keys where all the keys in that bucket have the same count.
// You can query the max or min Keys by looking at the  head or tail bucket

// For example: for the stream of numbers and operation:
// [3,inc], [3,inc], [3,inc], [3,inc], [2, inc], [2, inc], [2, inc], [1, inc], [3, dec]
// The representation would look like below when the stream is processed.
// ----------------------------------------------------------------
// | Bucket {         |             | Bucket {         |
// |  bucketCount: 1  |             |  bucketCount: 3  |
// |  next: 3         | < ----- >   |  next: 0         |
// |  previous: 0     |             |  previous: 1     |
// |  keys: { 1 }     |             |  keys: { 2, 3 }  |
// | }                |             | }                |
// -----------------------------------------------------------------

// This is more efficient than the alternative which is to use Self-Balancing Binary Search Tree like RedBlack or AVL tree which
// get max or min keys are O(1) but the insertion and deletion is O(log(n))

contract MagicCounter is Counter {
    struct Bucket {
        uint256 bucketCount;
        uint256 next;
        uint256 previous;
    }

    event LogInner(string log);
    event LogInner(string log, uint256 num);

    // track the bucketCount to Bucket Struct pointer
    mapping(uint256 => Bucket) countToBucket;
    // track the count of each key so we can query which bucket it's in
    mapping(uint256 => uint256) keyToCount;
    // track all the keys in the bucket
    mapping(uint256 => uint256[]) bucketTokeys;
    // track the indexes of keys in each bucket
    mapping(uint256 => mapping(uint256 => uint256)) bucketToIndexes;

    uint256 headBucketCount;
    uint256 tailBucketCount;

    constructor() {
        headBucketCount = type(uint256).max;
        tailBucketCount = 0;
        countToBucket[headBucketCount] = Bucket(headBucketCount, 0, 0);
        countToBucket[tailBucketCount] = Bucket(tailBucketCount, 0, 0);
        // create a cycle, head prev bucket is tail and tail next node is head
        countToBucket[headBucketCount].previous = tailBucketCount;
        countToBucket[tailBucketCount].next = headBucketCount;
    }

    function increment(uint256 key) external override {
        if (keyToCount[key] > 0) {
            // if key already exist
            _changeKey(key, 1);
        } else {
            keyToCount[key] = 1;

            if (countToBucket[1].bucketCount == 0) {
                // if bucket 1 not in the linkedlist
                Bucket memory newBucket = Bucket(0, 0, 0);
                newBucket.bucketCount = 1;
                countToBucket[1] = newBucket;
                _addBucketAfter(
                    countToBucket[tailBucketCount],
                    countToBucket[1]
                );
                _add(countToBucket[1], key);
            } else {
                Bucket storage curBucket = countToBucket[1];
                _add(curBucket, key);
            }
        }
    }

    function decrement(uint256 key) external override {
        if (keyToCount[key] == 0) {
            // key doesn't exist
            return;
        }
        if (keyToCount[key] > 1) {
            // key exist
            _changeKey(key, -1);
        } else {
            // _remove key from Bucket if count is 1
            _removeKeyFromBucket(
                countToBucket[countToBucket[tailBucketCount].next],
                key
            );
            keyToCount[key] = 0;
        }
    }

    function getMaxKeys()
        public
        view
        override
        returns (uint256[] memory maxKey)
    {
        if (
            countToBucket[headBucketCount].previous ==
            countToBucket[tailBucketCount].bucketCount
        ) {
            uint256[] memory empty;
            return empty;
        } else {
            return
                _keys(countToBucket[countToBucket[headBucketCount].previous]);
        }
    }

    function getMinKeys()
        public
        view
        override
        returns (uint256[] memory maxKey)
    {
        if (
            countToBucket[headBucketCount].previous ==
            countToBucket[tailBucketCount].bucketCount
        ) {
            // no key exists
            uint256[] memory empty;
            return empty;
        } else {
            return _keys(countToBucket[countToBucket[tailBucketCount].next]);
        }
    }

    function debug() public {
        uint256 cur = headBucketCount;
        while (cur != tailBucketCount) {
            Bucket storage bucket = countToBucket[cur];
            emit LogInner("bucketCount", bucket.bucketCount);
            emit LogInner("next", bucket.next);
            emit LogInner("previous", bucket.previous);
            emit LogInner(" /\\ \n | \n | \n \\/ ");
            cur = bucket.next;
        }
    }

    // helper function to change the key to different bucket
    // for example: if current count of key 3 is 10 and we increment the count. The key 3 should now be in bucket 11 and be removed from 10
    function _changeKey(uint256 key, int256 offset) internal {
        uint256 curCount = keyToCount[key];
        // get the bucket the current key is in
        Bucket storage curBucket = countToBucket[curCount];

        uint256 newCount = uint256(int256(curCount) + offset);
        if (countToBucket[newCount].bucketCount != 0) {
            // if the bucket that we are moving to already exist just add key to that bucket
            Bucket storage newBucket = countToBucket[newCount];
            _add(newBucket, key);
        } else {
            // bucket does not exist we need to create a new one;
            Bucket memory newBucket = Bucket(0, 0, 0);
            newBucket.bucketCount = newCount;
            countToBucket[newCount] = newBucket;
            _add(countToBucket[newCount], key);
            if (offset == 1) {
                // if we increment, the new bucket should be after current bucket in the doubly linkedlist
                _addBucketAfter(curBucket, countToBucket[newCount]);
            } else if (offset == -1) {
                // if we decrement, the new bucket should be after the previos bucket
                _addBucketAfter(
                    countToBucket[curBucket.previous],
                    countToBucket[newCount]
                );
            }
        }

        _removeKeyFromBucket(curBucket, key);

        keyToCount[key] = newCount;
    }

    function _removeKeyFromBucket(Bucket storage bucket, uint256 key) internal {
        _remove(bucket, key);
        //if there is no key in this bucket then _remove the bucket, and delete reference to that bucket
        if (bucketTokeys[bucket.bucketCount].length == 0) {
            _removeBucket(bucket);
            delete countToBucket[keyToCount[key]];
        }
    }

    // add a new bucket after previous node
    function _addBucketAfter(
        Bucket storage previousBucket,
        Bucket storage newBucket
    ) internal {
        // need to link next node.previos to the newBucket

        countToBucket[previousBucket.next].previous = newBucket.bucketCount;
        newBucket.previous = previousBucket.bucketCount;
        newBucket.next = previousBucket.next;
        previousBucket.next = newBucket.bucketCount;
    }

    // remove bucket from the doubly linkedlist
    function _removeBucket(Bucket storage bucket) internal {
        Bucket storage a = countToBucket[bucket.previous];
        Bucket storage b = countToBucket[bucket.next];
        a.next = b.bucketCount;
        b.previous = a.bucketCount;
        bucket.next = 0;
        bucket.previous = 0;
    }

    //  Below functions are operation done within the bucket

    // See if key in in the bucket
    function _contains(Bucket storage bucket, uint256 key)
        internal
        view
        returns (bool)
    {
        return bucketToIndexes[bucket.bucketCount][key] != 0;
    }

    function _keys(Bucket storage bucket)
        internal
        view
        returns (uint256[] memory)
    {
        return bucketTokeys[bucket.bucketCount];
    }

    // helper function to add key to bucket set
    function _add(Bucket storage bucket, uint256 key) internal returns (bool) {
        if (!_contains(bucket, key)) {
            bucketTokeys[bucket.bucketCount].push(key);
            // The key is stored at length-1, but we _add 1 to all indexes
            // and use 0 as a sentinel key
            bucketToIndexes[bucket.bucketCount][key] = bucketTokeys[
                bucket.bucketCount
            ].length;
            return true;
        } else {
            return false;
        }
    }

    // helper function to remove key from bucket set
    // this basically swap the position of the key we want to remove in the array to the last index
    // so we can keep the operation in O(1)
    function _remove(Bucket storage bucket, uint256 key)
        internal
        returns (bool)
    {
        uint256 keyIndex = bucketToIndexes[bucket.bucketCount][key];

        if (keyIndex != 0) {
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = bucketTokeys[bucket.bucketCount].length - 1;

            if (lastIndex != toDeleteIndex) {
                uint256 lastkey = bucketTokeys[bucket.bucketCount][lastIndex];

                // Move the last key to the index where the key to delete is
                bucketTokeys[bucket.bucketCount][toDeleteIndex] = lastkey;
                // Update the index for the moved key
                bucketToIndexes[bucket.bucketCount][lastkey] = keyIndex; // Replace lastkey's index to keyIndex
            }
            // Delete the slot where the moved bucketCount was stored
            bucketTokeys[bucket.bucketCount].pop();

            // Delete the index for the deleted slot
            delete bucketToIndexes[bucket.bucketCount][key];

            return true;
        } else {
            return false;
        }
    }
}
