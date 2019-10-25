pragma solidity ^0.5.0;

contract RegistryV2 {
  struct Item {
    uint256 id;
    uint256 REMOVED_value; // Since we cannot remove an entry from storage, we label it as removed to prevent clashes
    address owner;
    string data; // New field added to the struct, note that we add it at the end
  }

  mapping (uint256 => Item) items;

  function addItem(uint256 id, string memory data) public {
    require(id > 0, "ID cannot be zero");
    require(items[id].id == 0 || items[id].owner == msg.sender, "Item already set by another user");

    items[id] = Item(id, 0, msg.sender, data);
  }

  function getItem(uint256 id) public view returns (string memory, address) {
    Item storage item = items[id];
    return (item.data, item.owner);
  }
}