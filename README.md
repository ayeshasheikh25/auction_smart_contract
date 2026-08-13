# Auction Smart Contract

A decentralized **Auction Smart Contract** built with **Solidity**. The contract allows users to participate in an auction by placing bids using Ether. It automatically tracks the highest bidder, manages bid amounts, supports auction cancellation, and allows participants to withdraw their refundable amounts after the auction ends.

## Features

**Auctioneer Management**

  * The contract creator becomes the auctioneer.
  * Only the auctioneer can cancel the auction.
  * The auctioneer can withdraw the final payable bid after the auction ends.

**Bidding System**

  * Users can place bids using Ether.
  * Each bidder's total bid is tracked.
  * Users cannot bid on their own auction.
  * A new bid must be higher than the current payable highest bid.

**Highest Bid Tracking**

  * Automatically tracks the highest bidder.
  * Calculates the highest payable bid based on the bid increment.
  * Supports multiple bids from the same bidder.

**Auction Timing**

  * The auction starts when the contract is deployed.
  * The auction runs for a predefined number of blocks.
  * Bids cannot be placed after the auction ends.

**Auction Cancellation**

  * The auctioneer can cancel the auction.
  * Participants can withdraw their deposited bid after cancellation.

**Refund System**

  * Losing bidders can withdraw their remaining bid amount.
  * The auctioneer receives the final payable bid.
  * Withdrawn amounts are reset to prevent repeated withdrawals.

**Access Control**

  * Owner-only functions are protected using modifiers.
  * The auctioneer cannot participate as a bidder.

## Technologies Used

* **Solidity ^0.8.34**
* **Ethereum / EVM**
* **Remix IDE**
* **Ether**
* **Smart Contract Modifiers**
* **Mappings**
* **Enums**
* **Payable Functions**

## Contract Structure

### Auction State

The contract uses an enum to represent the auction status:

```solidity
enum Auction_State {
    Started,
    Running,
    Ended,
    Cancelled
}
```

The available states are:

| State       | Description                  |
| ----------- | ---------------------------- |
| `Started`   | Auction has been initialized |
| `Running`   | Users can place bids         |
| `Ended`     | Auction has finished         |
| `Cancelled` | Auction has been cancelled   |

## Auctioneer

When the contract is deployed, the address that deploys the contract becomes the auctioneer:

```solidity
constructor() {
    auctioneer = payable(msg.sender);
}
```

The auctioneer is responsible for managing the auction and can cancel it if required.

## Bidding

Users place bids through the `bid()` function:

```solidity
function bid() public payable
    notOwner
    startBid
    beforeEnd
    checkState
```

The function:

1. Checks that the sender is not the auctioneer.
2. Checks that the auction has started.
3. Checks that the auction has not ended.
4. Checks that the auction is currently running.
5. Requires Ether to be sent with the transaction.
6. Updates the bidder's total bid.
7. Determines the highest bidder and payable amount.

## Bid Increment

The contract uses a predefined bid increment:

```solidity
bidInc = 1 ether;
```

This means the auction uses **1 Ether as the bid increment** when calculating the highest payable bid.

## Highest Bidder

The contract stores:

```solidity
uint public highestPayableBid;
address public highestBidder;
```

`highestPayableBid` represents the amount currently payable by the highest bidder, while `highestBidder` stores the address of that bidder.

## Cancel Auction

The auctioneer can cancel the auction using:

```solidity
function cancelAuction() public onlyOwner {
    auctionState = Auction_State.Cancelled;
}
```

Only the auctioneer can call this function because of the `onlyOwner` modifier.

## Final Auction

After the auction ends, participants can call:

```solidity
function finalAuc() public
```

This function handles the final payments and refunds.

### Auctioneer

The auctioneer receives the highest payable bid.

### Winning Bidder

The winning bidder does not receive the payable portion back.

### Losing Bidders

Losing bidders receive:

```text
Their Total Bid - Highest Payable Bid
```

This allows bidders to recover the amount they bid beyond the amount required to win.

## Security Features

The contract uses several modifiers:

### `onlyOwner`

Ensures that only the auctioneer can perform restricted operations.

```solidity
modifier onlyOwner() {
    require(msg.sender == auctioneer, "Only owner can do");
    _;
}
```

### `notOwner`

Prevents the auctioneer from participating in the auction.

### `startBid`

Ensures that bidding starts only after the configured start block.

### `beforeEnd`

Prevents users from bidding after the auction deadline.

### `checkState`

Ensures that bidding is possible only while the auction is in the `Running` state.

## Testing with Remix IDE

### Step 1: Open Remix

Open Remix IDE and create a new Solidity file.

### Step 2: Add the Contract

Copy the `Auction.sol` smart contract into the file.

### Step 3: Compile

Select Solidity compiler version:

```text
0.8.34
```

Then click **Compile Auction.sol**.

### Step 4: Deploy

Go to **Deploy & Run Transactions** and deploy the contract.

The account that deploys the contract becomes the auctioneer.

### Step 5: Place Bids

Use different Remix accounts to call:

```text
bid()
```

and send Ether with the transaction.

### Step 6: Check Auction Information

You can inspect:

```text
auctioneer
auctionState
highestBidder
highestPayableBid
startTime
endTime
bidInc
```

### Step 7: Finish the Auction

After the auction period ends, users can call:

```text
finalAuc()
```

to receive their remaining refundable amount.

## Project Structure

```text
Auction-Smart-Contract/
│
├── Auction.sol
└── README.md
```

## Learning Objectives

This project was created to practice:

* Solidity smart contract development
* Ethereum transactions
* `payable` functions
* Ether transfers
* Solidity mappings
* Enums and contract states
* Function modifiers
* Access control
* Auction/bidding logic
* Smart contract withdrawal patterns

## Note

This project is intended for **learning and educational purposes**. It should be thoroughly audited and tested before being used with real funds or deployed to a production blockchain.

## License

This project is licensed under the **MIT License**.
