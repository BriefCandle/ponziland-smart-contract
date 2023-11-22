// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

uint32 constant WIDTH = 64;
uint32 constant HEIGHT = 64;

library TileLibrary {
  function tileOnLand(uint64 xy) internal pure returns (bool) {
    (uint32 x, uint32 y) = split(xy);
    return x > 0 && x <= WIDTH && y > 0 && y <= HEIGHT;
  }

  function getNearTiles(uint64 xy) internal pure returns (uint64[8] memory) {
    (uint32 x, uint32 y) = split(xy);
    uint64[8] memory nearTiles;
    nearTiles[0] = getUpLeft(x, y);
    nearTiles[1] = getUp(x, y);
    nearTiles[2] = getUpRight(x, y);
    nearTiles[3] = getRight(x, y);
    nearTiles[4] = getDownRight(x, y);
    nearTiles[5] = getDown(x, y);
    nearTiles[6] = getDownLeft(x, y);
    nearTiles[7] = getLeft(x, y);
    return nearTiles;
  }

  // index == 0
  function getUpLeft(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == 1 || y == 1 ? 0 : combine(x - 1, y - 1);
  }

  // index == 1
  function getUp(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = y == 1 ? 0 : combine(x, y - 1);
  }

  // index == 2
  function getUpRight(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == WIDTH || y == 1 ? 0 : combine(x + 1, y - 1);
  }

  // index == 3
  function getRight(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == WIDTH ? 0 : combine(x + 1, y);
  }

  // index == 4
  function getDownRight(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == WIDTH || y == HEIGHT ? 0 : combine(x + 1, y + 1);
  }

  // index == 5
  function getDown(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = y == HEIGHT ? 0 : combine(x, y + 1);
  }

  // index == 6
  function getDownLeft(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == 1 || y == HEIGHT ? 0 : combine(x - 1, y + 1);
  }

  // index == 7
  function getLeft(uint32 x, uint32 y) internal pure returns (uint64 xy) {
    xy = x == 1 ? 0 : combine(x - 1, y);
  }

  // combine two uint32 into one uint64
  function combine(uint32 x, uint32 y) internal pure returns (uint64) {
    return (uint64(x) << 32) | y;
  }

  // split one uint64 into two uint32
  function split(uint64 xy) internal pure returns (uint32, uint32) {
    uint32 x = uint32(xy >> 32);
    uint32 y = uint32(xy);
    return (x, y);
  }
}