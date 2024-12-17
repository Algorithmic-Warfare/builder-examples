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
import { GateAccess } from "../src/codegen/tables/GateAccess.sol";

import { AddAllowedCorp } from "./AddAllowedCorp.s.sol";

contract ConfigureSmartGate is Script {
  using SmartGateUtils for bytes14;
  using SmartGateLib for SmartGateLib.World;

  SmartGateLib.World smartGate;

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 smartGateId = vm.envUint("SOURCE_GATE_ID");

    ResourceId systemId = Utils.smartGateSystemId();

    //This function can only be called by the owner of the smart turret
    smartGate.configureSmartGate(smartGateId, systemId);

    vm.stopBroadcast();

    // // Get the allowed corp
    // uint256 corpID = vm.envUint("ALLOWED_CORP_ID");
    // AddAllowedCorp allowCrop = new AddAllowedCorp();
    // allowCrop.run(worldAddress, corpID);
  }
}
