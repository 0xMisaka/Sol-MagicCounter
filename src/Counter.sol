pragma solidity ^0.8.10;

interface ICounter {
    function increment(uint256 key) external;

    function decrement(uint256 key) external;

    function getMaxKeys() external returns (uint256[] memory maxKey);

    function getMinKeys() external returns (uint256[] memory minKey);
}

abstract contract Counter is ICounter {
    function increment(uint256 key) external virtual;

    function decrement(uint256 key) external virtual;

    function getMaxKeys() public view virtual returns (uint256[] memory maxKey);

    function getMinKeys() public view virtual returns (uint256[] memory minKey);
}
