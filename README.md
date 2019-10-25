# OpenZeppelin SDK example: Upgrading structs

This sample project showcases how structs can be upgraded in a contract using the OpenZeppelin SDK. The SDK `upgrade` command will change a contract's code, **while preserving the address, balance, and state**. Read [here](https://docs.openzeppelin.com/sdk/2.5/first) to learn how to set up your first OpenZeppelin SDK project.

Note that the CLI currently does not verify that the integrity of the data is preserved across upgrades when using structs, so you need to take extra care when performing this operation. Read [here](https://docs.openzeppelin.com/sdk/2.5/writing-contracts) for more information.

## Running this example

This sample works by upgrading a contract named `Registry` from V1 to V2. This contract keeps a mapping from `uint256` ids to a struct. The fields in this struct are changed across the upgrade: a numerical field is labeled as removed, and a text field is added at the end of the struct.

Start by cloning this repository into a new folder and installing dependencies.
```
$ npm install
```

In a separate terminal, start a ganache instance to use as development network.
```
$ ganache-cli -d
```

Now go back to the first terminal to begin!

## Creating an instance

As a first step, we'll register the `RegistryV1` contract as our current `Registry` contract version. Adding a contract tells the OpenZeppelin SDK to start tracking it.
```
$ npx oz add RegistryV1:Registry
✓ Added contract Registry
```

After adding it, we'll create a new upgradeable instance of the Registry in the development network.
```
$ npx oz create Registry
? Pick a network development
✓ Contract RegistryV1 deployed
? Do you want to call a function on the instance after creating it? No
✓ Setting everything up to create contract instances
✓ Instance created at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
```

Now we can interact with it via the `send-tx` command, using it to add two new items to the registry.
```
$ npx oz send-tx
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function addItem(id: uint256, value: uint256)
? id (uint256): 1
? value (uint256): 42
✓ Transaction successful.

$ npx oz send-tx
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function addItem(id: uint256, value: uint256)
? id (uint256): 2
? value (uint256): 84
✓ Transaction successful.
```

And use `call` to query one of the items we have just added:
```
$ npx oz call
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function getItem(id: uint256)
? id (uint256): 1
✓ Method 'getItem(uint256)' returned: (42, 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1)
```

## Upgrading

Now, let's register the V2 of the contract as the new `Registry` contract in our OpenZeppelin project.

```
$ npx oz add RegistryV2:Registry
✓ Added contract Registry
```

Time to upgrade it! This will upgrade all versions of the `Registry` we had deployed in the development network to the latest version, **while preserving their address, balance, and state**. Note that the CLI will warn you that the structs will be unchecked during the upgrade, until the SDK adds support for validating them.

```
$ npx oz upgrade Registry
? Pick a network development
- Variable items (RegistryV2) contains a struct or enum. These are not automatically checked for storage compatibility in the current version.
- Variable 'items' in contract RegistryV1 was changed from mapping(key => RegistryV1.Item) to mapping(key => RegistryV2.Item) in contracts/RegistryV2.sol:1. Avoid changing types of existing variables.
✓ Contract RegistryV2 deployed
? Do you want to call a function on the instance after upgrading it? No
✓ Instance at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601 upgraded
```

We can now call the contract (note that the address is the same!) to check that the storage was preserved. The new implementation returns the new `string` data (empty for old items) and the existing owner `address`.
```
$ npx oz call 
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function getItem(id: uint256)
? id (uint256): 1
✓ Method 'getItem(uint256)' returned: (, 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1)
```

Great! We can now interact with the new version, and see that we can add strings to the registry items.
```
$ npx oz send-tx
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function addItem(id: uint256, data: string)
? id (uint256): 3
? data (string): foo
✓ Transaction successful.

$ npx oz call 
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function getItem(id: uint256)
? id (uint256): 3
✓ Method 'getItem(uint256)' returned: (foo, 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1)
```

We can also modify existing items, and the data is properly set.
```
$ npx oz send-tx
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function addItem(id: uint256, data: string)
? id (uint256): 2
? data (string): bar
✓ Transaction successful.

$ npx oz call
? Pick a network development
? Pick an instance Registry at 0xCfEB869F69431e42cdB54A4F4f105C19C080A601
? Select which function getItem(id: uint256)
? id (uint256): 2
✓ Method 'getItem(uint256)' returned: (bar, 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1)
```