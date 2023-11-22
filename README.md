## Manifesto

### Ponzi-Land 

- A total of 64x64 ponzi tiles. Each observes the Harberger tax

### Onchain Physics

- Birds fly, cats go meow, and you pay taxes to neighbors. This is the law of physics in Ponziland and the backbone of an AW that promises permanency.

### Autonomous World

- With taxes established as the diegesis/rules/restrictions/whatever, an autonomous world emerges. The only equivalent comparison is America, the greatest autonomous world ever created on certainties such as constitutions, taxes, and death.

### Decentralized

- In real life, you pay taxman the currency required by your local jurisdiction. Now, in Ponziland, you pay whatever shitcoins you’d like to pay. In return, you receive whatever shitcoins your neighbors want to pay you. This is pretty decentralized if you ask me.

### Ponzi-nomics 

- Ponzinomics is what keeps ponziland afloat…
- still need to figure out the exact mechanisms, friendo~

### How To Participate

- This is a fair-launch, free-to-enter, latecomers-got-ponzi-the-whack-off kind-of-project
- Early participants are expected to contribute ideas and code (in smart contract & client-side)
- To join, solemnly swear: IN PONZI WE TRUST


## Mechanism
#### Spawn a tile
- costs player some $ETH to spawn on an empty tile, on which player sets {price, amount, erc20}
- the main reason is NOT to get rich but to prevent players from generating large amounts of tiles without any cost.
- need to figure out some mechanisms to inject these proceeds back into ponziland.

#### Harberger Tax
- player can set a price on any tile he owns, which means 1) he needs to pay taxes (based on the price) to all 8 neighbours, and 2) anyone can come in to purchase the tile from him with the price he asked for.
- therefore, the higher the price being set, the more valuable the tile is, and the higher the cost to keep it.

#### Liquidation 
- Liquidation is in the sense that all obligations/arrears are being cleared on tile's tile.
- There are 20% incentives for anyone to liquidate a tile when the staked amount might not be able to cover the taxes.
- Other activities, such as setPrice and purchase would auto-conduct liquidation/paying off taxes

#### Whitelist
- a multi-sig is probably required to maintain whitelist, and allow public to remove any non-whitlisted tiles 

#### Vulnerability
- there are a ton, probably. Feel free to read and change whatever you think is right
- Besides, `IERC20.transfer()`

