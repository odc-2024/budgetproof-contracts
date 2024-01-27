// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract BudgetAllocation {
  /* stores state of allocation (in process, allocated) */
  uint256 public state = 0;
  /* stores allocation name */
  string public name;
  /* stores allocation amount */
  uint256 public amount;
  /* stores receiver hash */
  address public receiverAddress;

  constructor(string memory name_, uint256 amount_, address receiverAddress_) {
    name = name_;
    amount = amount_;
    receiverAddress = receiverAddress_;
  }
}

contract BudgetVolunteer {
  string public name;
  uint256 public lockAmount = 0;
  address public volunteerAddress;

  mapping(uint256 => BudgetAllocation) public allocations;
  uint256[] public allocationIds;
  uint256 public allocationCounter = 0;

  constructor(string memory name_, uint256 lockAmount_, address volunteerAddress_) {
    name = name_;
    lockAmount = lockAmount_;
    volunteerAddress = volunteerAddress_;
  }

  function createAllocation(string memory name_, uint256 amount_, address receiverAddress_) public returns(uint256) {
    if (amount_ > lockAmount)
      revert("amount exceeds the remaining amount");
    /* deploy budget allocation contract */
    BudgetAllocation allocation = new BudgetAllocation(name_, amount_, receiverAddress_);

    uint256 allocationId = allocationCounter;

    allocations[allocationId] = allocation;

    lockAmount -= amount_;

    return 0;
  }

  function confirmAllocation(uint256 allocationId_, uint8 v, bytes32 r, bytes32 s) public {
    if (address(allocations[allocationId_]) != address(0))
      revert("Allocation does not exist");

    if (allocations[allocationId_].receiverAddress() != msg.sender)
      revert("Allocation is not for this address");
  }
}

contract Budget {
  /* stores name of budget (human readable?) */
  string public name;
  /* stores remaining amount of budget */
  uint256 public remainingAmount;
  /* stores volunteers */
  mapping(uint256 => BudgetVolunteer) public volunteers;
  /* stores volunteer ids */
  uint256[] public volunteerIds;
  /* stores free volunteer id */
  uint256 public volunteerCounter = 0;

  constructor(string memory name_, uint256 amount_) {
    name = name_;
    remainingAmount = amount_;
  }

  function createVolunteer(string memory name_, uint256 lockAmount_, address volunteerAddress_) public returns(uint256) {
    /* deploy budget volunteer contract */
    BudgetVolunteer volunteer = new BudgetVolunteer(name_, lockAmount_, volunteerAddress_);
    /* get free volunteer id */
    uint256 volunteerId = volunteerCounter;
    /* store volunteer with volunteer id */
    volunteers[volunteerId] = volunteer;
    /* store volunteer id */
    volunteerIds.push(volunteerId);
    /* increment free volunteer id */
    volunteerCounter++;

    return volunteerId;
  }

  function createAllocation(uint256 volunteerId_, string memory name_, uint256 amount_, address receiverAddress_) public {
    if (address(volunteers[volunteerId_]) == address(0))
      revert("Volunteer does not exist");
  }

  function confirmAllocation(uint256 volunteerId_, uint256 allocationId_, uint8 v, bytes32 r, bytes32 s) public {
    if (address(volunteers[volunteerId_]) == address(0))
      revert("Volunteer does not exist");

    volunteers[volunteerId_].confirmAllocation(allocationId_, v, r, s);
  }
}

// (Ck + Vk) + Bk = proof?
contract BudgetProof {
  uint256 private budgetId = 0;
  mapping(uint256 => Budget) public budgets;
  uint256[] public budgetIds;

  /* budget created event */
  event BudgetCreated(uint256 indexed budgetId, string name, uint256 amount);

  /* budget allocation event */
  event BudgetAllocated(uint256 indexed budgetId, string name, uint256 amount,
      address receiverAddress, uint256 timestamp);

  constructor() payable {
    /* void */
  }

  function createBudget(string memory name_, uint256 amount_) public returns (uint256) {
    /* deploy a new budget contract and store it with id */
    budgets[budgetId] = new Budget(name_, amount_);

    /* store budget's id */
    budgetIds.push(budgetId);

    /* emit BudgetCreated event to store the action in logs */
    emit BudgetCreated(budgetId, name_, amount_);

    return budgetId;
  }

  function createVolunteer(uint256 budgetId_, string memory name_, uint256 lockAmount_, address address_) public returns(uint256) {
    /* check if budget exists, revert otherwise */
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    /* create a new volunter for given budget */
    uint256 volunteerId = budgets[budgetId_].createVolunteer(name_, lockAmount_, address_);

    return volunteerId;
  }

  function createAllocation(uint256 budgetId_, uint256 volunteerId_, string memory name_, uint256 amount_, address receiverAddress_) public {
    /* check if budget exists, revert otherwise */
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    budgets[budgetId_].createAllocation(volunteerId_, name_, amount_, receiverAddress_);

    emit BudgetAllocated(budgetId_, name_, amount_, receiverAddress_, block.timestamp);
  }

  function confirmAllocation(uint256 budgetId_, uint256 volunteerId_, uint256 allocationId_, uint8 v, bytes32 r, bytes32 s) public {
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    budgets[budgetId_].confirmAllocation(volunteerId_, allocationId_, v, r, s);
  }
}
