// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

struct BudgetAllocationView {uint256 id; uint256 state; string receiverUsername; address receiverAddress;
    uint256 amount; string volunteerUsername; address volunteerAddress; }

contract BudgetAllocation {
  /* stores state of allocation (in process, allocated) */
  uint256 public state = 0;
  /* stores allocation name */
  string public receiverUsername;
  /* stores allocation name */
  address public receiverAddress;
  /* stores allocation amount */
  uint256 public amount;
  /* stores volunteer address */
  address public volunteerAddress;
  /* stores volunteer username */
  string public volunteerUsername;

  constructor(string memory receiverUsername_, address receiverAddress_, uint256 amount_,
      address volunteerAddress_, string memory volunteerUsername_) {
    receiverUsername = receiverUsername_;
    receiverAddress = receiverAddress_;
    amount = amount_;
    volunteerAddress = volunteerAddress_;
    volunteerUsername = volunteerUsername_;
  }

  function confirmAllocation() public {
    require(state == 0, "Allocation is already confirmed");
    require(msg.sender != receiverAddress, "Allocation is not for you");

    state = 1;
  }
}

contract Budget {
  /* stores name of budget (human readable?) */
  string public name;
  /* stores amount of budget */
  uint256 public amount;
  /* stores remaining amount of budget */
  uint256 public remainingAmount;
  /* stores unit name */
  string public unit;
  /* stores allocations */
  mapping(uint256 => BudgetAllocation) public allocations;
  /* stores allocation ids */
  uint256[] public allocationIds;
  /* stores free allocation id */
  uint256 public allocationCounter = 0;

  constructor(string memory name_, uint256 amount_, string memory unit_) {
    name = name_;
    remainingAmount = amount_;
    amount = amount_;
    unit = unit_;
  }

  function createAllocation(string memory receiverUsername_, address receiverAddress_, uint256 amount_,
      address volunteerAddress_, string memory volunteerUsername_) public {

    BudgetAllocation allocation = new BudgetAllocation(receiverUsername_, receiverAddress_,
        amount_, volunteerAddress_, volunteerUsername_);

    uint256 allocationId = allocationCounter;

    allocations[allocationId] = allocation;

    remainingAmount -= amount_;

    allocationCounter++;
  }

  function confirmAllocation(uint256 allocationId_) public {
    require(address(allocations[allocationId_]) != address(0), "Allocation does not exist");
    allocations[allocationId_].confirmAllocation();
  }

  function getAllocations() public view returns (BudgetAllocationView[] memory) {
    BudgetAllocationView[] memory views = new BudgetAllocationView[](allocationCounter);

    for (uint256 i = 0; i < allocationCounter; i++)
      views[i] = BudgetAllocationView(i, allocations[i].state(), allocations[i].receiverUsername(),
          allocations[i].receiverAddress(), allocations[i].amount(), allocations[i].volunteerUsername(),
          allocations[i].volunteerAddress());

    return views;
  }
}

contract BudgetProof {
  uint256 public budgetCounter = 0;
  mapping(uint256 => Budget) public budgets;
  uint256[] public budgetIds;

  /* budget created event */
  event BudgetCreated(uint256 indexed budgetId, string name, uint256 amount, string unit);

  /* budget allocation event */
  event BudgetAllocated(uint256 indexed budgetId, string name, uint256 amount,
      address receiverAddress, uint256 timestamp);

  constructor() payable {
    /* void */
  }

  receive() payable external {}

  function createCampaign(string memory name_, uint256 amount_, string memory unit_) public {
    uint256 budgetId = budgetCounter;

    /* deploy a new budget contract and store it with id */
    budgets[budgetId] = new Budget(name_, amount_, unit_);

    /* store budget's id */
    budgetIds.push(budgetId);

    /* emit BudgetCreated event to store the action in logs */
    emit BudgetCreated(budgetId, name_, amount_, unit_);

    budgetCounter++;
  }

  function createAllocation(uint256 budgetId_, string memory receiverUsername_, address receiverAddress_, uint256 amount_,
      address volunteerAddress_, string memory volunteerUsername_) public {
    /* check if budget exists, revert otherwise */
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    budgets[budgetId_].createAllocation(receiverUsername_, receiverAddress_, amount_, volunteerAddress_, volunteerUsername_);
  }

  function confirmAllocation(uint256 budgetId_, uint256 allocationId_) public {
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    budgets[budgetId_].confirmAllocation(allocationId_);
  }

  struct BudgetView {uint256 id; string name; uint256 amount; string unit; uint256 remainingAmount; address contractAddress;}

  function getBudgets() public view returns(BudgetView[] memory) {
    BudgetView[] memory views = new BudgetView[](budgetCounter);

    for (uint256 i = 0; i < budgetCounter; i++)
      views[i] = BudgetView(i, budgets[i].name(), budgets[i].amount(), budgets[i].unit(),
          budgets[i].remainingAmount(), address(budgets[i]));

    return views;
  }

  function getBudget(uint256 budgetId_) public view returns(BudgetView memory) {
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    Budget budget = budgets[budgetId_];
    BudgetView memory budgetView = BudgetView(budgetId_, budget.name(), budget.amount(),
        budget.unit(), budget.remainingAmount(), address(budget));

    return budgetView;
  }

  function getAllocations(uint256 budgetId_) public view returns(BudgetAllocationView[] memory) {
    if (address(budgets[budgetId_]) == address(0))
      revert("Budget does not exist");

    return budgets[budgetId_].getAllocations();
  }
}
