pragma solidity ^0.8.0;
import "ds-test/test.sol";
import "../MagicCounter.sol";

contract MagicCounterTest is DSTest {
    MagicCounter magicCounter;
    mapping(uint256 => uint256) counter;
    mapping(uint256 => uint256) counter2;
    mapping(uint256 => bool) expectedMax;
    mapping(uint256 => bool) expectedMin;

    uint256[] test = [
        3,
        5,
        5,
        2,
        5,
        1,
        9,
        2,
        2,
        10,
        5,
        1,
        8,
        3,
        10,
        10,
        5,
        1,
        8,
        8,
        8,
        9,
        1,
        6,
        3,
        7,
        5,
        8,
        9,
        2,
        6,
        2,
        5,
        2,
        5,
        5,
        8,
        1,
        9,
        3,
        10,
        5,
        10,
        8,
        5,
        4,
        4,
        1,
        6,
        9,
        3,
        6,
        10,
        7,
        2,
        5,
        6,
        6,
        10,
        10,
        10,
        5,
        10,
        2,
        9,
        4,
        8,
        6,
        5,
        9,
        10,
        10,
        2,
        7,
        4,
        6,
        2,
        9,
        3,
        7,
        7,
        10,
        6,
        5,
        5,
        9,
        5,
        3,
        3,
        3,
        3,
        1,
        10,
        6,
        2,
        9,
        10,
        3,
        9,
        8
    ];
    string[] incrementOrDecrement = [
        "decrement",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "increment",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "increment",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "increment",
        "increment",
        "increment",
        "increment",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "increment",
        "increment",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "increment",
        "decrement",
        "increment",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "decrement",
        "increment",
        "increment",
        "decrement",
        "increment",
        "decrement",
        "decrement",
        "increment"
    ];

    function setUp() public {
        magicCounter = new MagicCounter();
    }

    function testMagicCounterGetMax() public {
        for (uint256 i = 0; i < test.length; i++) {
            // find all the max keys
            bool isIncrement = keccak256(bytes(incrementOrDecrement[i])) ==
                keccak256(bytes("increment"));
            if (isIncrement) {
                counter[test[i]]++;
                magicCounter.increment(test[i]);
            } else {
                magicCounter.decrement(test[i]);
                if (counter[test[i]] > 0) {
                    counter[test[i]]--;
                }
            }

            // counter[test[i]]++;
            uint256 expectedMaxCount = 0;

            // find max count
            for (uint256 j = 0; j < i + 1; j++) {
                if (counter[test[j]] > expectedMaxCount) {
                    expectedMaxCount = counter[test[j]];
                }
            }
            if (expectedMaxCount == 0) continue;
            uint256 totalCount = 0;

            // get all expected max keys and put in the the set
            for (uint256 j = 0; j < i + 1; j++) {
                if (counter[test[j]] == expectedMaxCount) {
                    if (!expectedMax[test[j]]) {
                        totalCount++;
                    }
                    expectedMax[test[j]] = true;
                }
            }

            // check that maxKeys are accurate;
            uint256[] memory maxKeys = magicCounter.getMaxKeys();
            for (uint256 j = 0; j < maxKeys.length; j++) {
                assertTrue(expectedMax[maxKeys[j]]);

                delete expectedMax[maxKeys[j]];
                totalCount--;
            }
            assertTrue(totalCount == 0);
        }
    }

    function testMagicCounterGetMin() public {
        for (uint256 i = 0; i < test.length; i++) {
            // find all the max keys
            bool isIncrement = keccak256(bytes(incrementOrDecrement[i])) ==
                keccak256(bytes("increment"));
            if (isIncrement) {
                counter2[test[i]]++;
                magicCounter.increment(test[i]);
            } else {
                magicCounter.decrement(test[i]);
                if (counter2[test[i]] > 0) {
                    counter2[test[i]]--;
                }
            }

            // counter[test[i]]++;
            uint256 expectedMinCount = type(uint256).max;

            // find min count
            for (uint256 j = 0; j < i + 1; j++) {
                if (
                    counter2[test[j]] != 0 &&
                    counter2[test[j]] < expectedMinCount
                ) {
                    expectedMinCount = counter2[test[j]];
                }
            }
            if (expectedMinCount == 0) continue;
            uint256 totalCount = 0;

            // get all expected mix keys and put in the the set
            for (uint256 j = 0; j < i + 1; j++) {
                if (counter2[test[j]] == expectedMinCount) {
                    if (!expectedMin[test[j]]) {
                        totalCount++;
                    }
                    expectedMin[test[j]] = true;
                }
            }

            // check that minKeys are accurate;
            uint256[] memory minKeys = magicCounter.getMinKeys();
            for (uint256 j = 0; j < minKeys.length; j++) {
                assertTrue(expectedMin[minKeys[j]]);

                delete expectedMin[minKeys[j]];
                totalCount--;
            }
            assertTrue(totalCount == 0);
        }
    }
}
