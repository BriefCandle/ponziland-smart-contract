// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/interfaces/IERC20.sol";
import { TileLibrary } from "./TileLibrary.sol";

contract TileContract {

  uint256 public constant SPAWN_PRICE = 0.01 ether;
  uint256 public constant TAX_DURATION = 3600 * 24;
  // address public fee_recipient;
  // uint16 public fee_percent; // two points decimal, max 10000, ex., 250 -> 2.5%
  
  struct Tile {
    address owner;
    uint256 price;
    uint256 balance;
    address erc20;
    uint40 lastUpdated;
  }

  mapping(address => bool) public whitelist;
  mapping(uint64 => Tile) public tiles;

  constructor(address firstWhitelist) {
    whitelist[firstWhitelist] = true;
  }

  // basically, a bribary to allow your shitcoins to be used in the game
  function addToWhitelist(address _erc20) external payable {
  }

  // TODO: figure out how to inject proceeds back into the ponzi scheme
  // so that earlier purchaser can have exit
  function purchase(uint64 _tileId, uint256 _price, uint256 amount) external onlyOwned(_tileId) {
    _purchase(_tileId, _price, amount);
  }

  function spawn(uint64 _tileId, uint256 _price, uint256 _amount, address _erc20) external payable onlySpawnable(_tileId) {
    require(whitelist[_erc20], "Tile: erc20 not whitelisted");
    require(SPAWN_PRICE <= msg.value, "Tile: insufficient spawn price");
    _spawn(_tileId, _price, _amount, _erc20);
  }

  function setPrice(uint64 _tileId, uint256 _price) external onlyOwner(_tileId) {
    _setPrice(_tileId, _price);
  }

  function stake(uint64 _tileId, uint256 _amount) external onlyOwner(_tileId) {
    _stake(_tileId, _amount);
  }

  function collectTaxes(uint64 _tileId) external onlyOwner(_tileId) {
    _collectTaxes(_tileId);
  }

  function liquidateTile(uint64 _tileId) external onlyOwned(_tileId) {
    require(canLiquidate(_tileId), "Tile: cannot liquidate");

    _liquidateTile(msg.sender, _tileId);
  }

  modifier onlyOwner(uint64 _tileId) {
    require(tiles[_tileId].owner == msg.sender, "Tile: caller is not owner");
    _;
  }

  modifier onlyOwned(uint64 _tileId) {
    require(tiles[_tileId].owner != address(0), "Tile: tile has no owner");
    _;
  }

  modifier onlySpawnable(uint64 _tileId) {
    require(TileLibrary.tileOnLand(_tileId), "Tile: tile is not on land");
    require(tiles[_tileId].owner == address(0), "Tile: tile is already owned");
    _;
  }

  function _purchase(uint64 _tileId, uint256 _price, uint256 _amount) internal {
    Tile memory tile = tiles[_tileId];
    require(_price >= tile.price , "Tile: insufficient purchase price");
    
    _liquidateTile(tile.owner, _tileId);
    _spawn(_tileId, _price, _amount, tile.erc20);
  }

  // spawn by setting new tile info & transferring staked amount from caller to contract
  function _spawn(uint64 _tileId, uint256 _price, uint256 _amount, address _erc20) internal {
    tiles[_tileId] = Tile(msg.sender, _price, _amount, _erc20, uint40(block.timestamp));
    IERC20(_erc20).transferFrom(msg.sender, address(this), _amount);
  }

  function _stake(uint64 _tileId, uint256 _amount) public {
    tiles[_tileId].balance += _amount;
    IERC20(tiles[_tileId].erc20).transferFrom(msg.sender, address(this), _amount);
  }

  // collect taxes from all your neighbors' tiles based on their tile's price;
  // liquidate neighbor's tile if they don't have enough balance to pay taxes
  function _collectTaxes(uint64 _tileId) internal {
    uint64[8] memory nearTiles = TileLibrary.getNearTiles(_tileId);    
    uint40 lastUpdated = tiles[_tileId].lastUpdated;
    tiles[_tileId].lastUpdated = uint40(block.timestamp);
    
    for (uint256 i = 0; i < nearTiles.length; i++) {
      uint64 nearTileID = nearTiles[i]; 
      Tile memory nearTile = tiles[nearTileID];
      if (nearTileID == 0 || nearTile.owner == address(0)) continue;
      
      uint256 amountToCollect = getTaxAmount(nearTile.price, lastUpdated);
      if(amountToCollect >= nearTile.balance) {
        _liquidateTile(msg.sender, nearTileID);
      } else {
        tiles[nearTileID].balance -= amountToCollect;
        IERC20(nearTile.erc20).transfer(tiles[_tileId].owner, amountToCollect);
      }
    }
  }

  // liquidate tile by 1) remove tile, 2) pay taxes owed to all neighbours, and 3) 
  // send remained to the liquidator, if there is any left
  function _liquidateTile(address _liquidator, uint64 _tileId) internal {
    Tile memory tile = tiles[_tileId];
    delete tiles[_tileId];
    uint256 remained = _payTaxes(_tileId, tile);

    if (remained != 0) {
      IERC20(tile.erc20).transfer(_liquidator, remained);
    }
  }

  // set new price, and then pay tax arrears to all neighbours
  function _setPrice(uint64 _tileId, uint256 _price) internal {
    Tile memory tile = tiles[_tileId];
    tiles[_tileId].price = _price;
    
    if (_price < tile.price) {
      tile.price = tile.price - _price;
      uint256 remained = _payTaxes(_tileId, tile);
      require(remained != 0, "Tile: not enough balance to pay taxes");
    }
  }

  function _payTaxes(uint64 _tileId, Tile memory tile) private returns (uint256 remained) {
    uint64[8] memory nearTiles = TileLibrary.getNearTiles(_tileId);

    remained = tile.balance;

    for (uint256 i = 0; i < nearTiles.length; i++) {
      uint64 nearTileID = nearTiles[i]; 
      if (nearTileID == 0 || tiles[nearTileID].owner == address(0)) continue;
      
      uint256 amountToPay = getTaxAmount(tile.price, tiles[nearTileID].lastUpdated);
      if(amountToPay >= remained) {
        remained = 0;
        IERC20(tile.erc20).transfer(tiles[nearTileID].owner, remained);
        return remained;
      }
      IERC20(tile.erc20).transfer(tiles[nearTileID].owner, amountToPay);

      remained -= amountToPay;
    } 
  }

  function getTaxAmount(uint256 price, uint256 lastUpdated) public view returns (uint256) {
    return price * (block.timestamp - lastUpdated) / TAX_DURATION;
  }

  // liquidate at 80% of the tile's balance
  function canLiquidate(uint64 _tileId) public view returns (bool) {
    return getTotalTaxAmount(_tileId) > tiles[_tileId].balance / 100 * 80;
  }

  // get total amount of taxes owed to all neighbours
  function getTotalTaxAmount(uint64 _tileId) public view returns (uint256 amount) {
    uint64[8] memory nearTiles = TileLibrary.getNearTiles(_tileId);
    for (uint256 i = 0; i < nearTiles.length; i++) {
      uint64 nearTile = nearTiles[i]; 
      if (nearTile == 0 || tiles[nearTile].owner == address(0)) continue;
      
      amount += getTaxAmount(tiles[_tileId].price, tiles[nearTile].lastUpdated);}
  }
}