// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartGateUtils } from "@eveworld/world/src/modules/smart-gate/Utils.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { TribeGateSystem } from "../src/systems/TribeGateSystem.sol";

contract AddAllowedCorp is Script {
  using SmartGateUtils for bytes14;
  using SmartGateLib for SmartGateLib.World;

  SmartGateLib.World smartGate;

  function run(address worldAddress, uint256 corpId) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 sourceGateId = vm.envUint("SOURCE_GATE_ID");

    ResourceId systemId = Utils.smartGateSystemId();

    world.call(systemId, abi.encodeCall(TribeGateSystem.addAllowedCorp, (sourceGateId, corpId)));

    vm.stopBroadcast();
  }
}
