pragma solidity ^0.5.0;

contract RegistryV1 {
  struct Item {
    uint256 id;
    uint256 value;
    address owner;
  }

  mapping (uint256 => Item) items;

  function addItem(uint256 id, uint256 value) public {
    require(id > 0, "ID cannot be zero");
    require(items[id].id == 0, "Item already set");

    items[id] = Item(id, value, msg.sender);
  }

  function getItem(uint256 id) public view returns (uint256, address) {
    Item storage item = items[id];
    return (item.value, item.owner);
  }
}