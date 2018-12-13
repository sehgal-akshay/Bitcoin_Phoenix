# Blockchain

Members - Aswin Suresh Krishnan (UFID : 1890-1173)
	  Akshay Sehgal (UFID : 1416-7988)

How to run
----------

> Run Program :

mix run

> Run extra Implementation :

mix run mix.exs create true  (or)
mix run mix.exs create false

> Run Tests :

mix test --no-start

Dependency resolution (optional) : mix deps clean; mix deps.get

Program overview [for brief understanding]
------------------------------------------

7 users that do a transaction from one random user to another at an interval of 30 seconds.
7 miners that mine continuously.
Program runs indefinitely.

Test Description [Also explained in report]
-------------------------------------------

0> Pre Test SetUp : 

Three users are spawned, one miner is spawned from a TestSupervisor. 

Three transactions are done from :unknown to each user. Now, we have 3 unverified tx in the pool which the single miner has to mine. 

The below Tests are run in sequential order using seed:0 as argument for the test initiation. 

1> target hash value test : 

The difficult target and hash set by bitcoin system is tested to be generated correctly. 

2> transaction hash test :

A sample transaction is hashed (by hashing individual fields) and checked if generated correctly. 

3> block hash test :

A sample block is hashed (by hashing all individual fields) and checked if generated correctly. 

4> generate initial wallet ballance test : 

The very first transaction is simulated by using an unknown sender called :dealer and verified that all nodes are credited with the initial wallet balance. 

5> test digital signature - sign and verify : 

We use the :rsa_ex api to get the (private_key, public_key) pair. The public_key is stored in sender and the private_key is used to hash the transaction message to get digital signature which is also store in the tx. Verification is done by validating valid(digital_signature, public_key, tx_hash) to true. We test this here by using a sample. 

6> test validation of transaction : 

Transaction authenticity is checked by the verify() as above and along verifying the sender has had enough balance at the point of tx by iterating over the blockchain. This functionality is verified here. 

7> merkle tree test : 

Merkle hash is formed from a list of transactions in a block. Say a,b,c => hash(hash(a,b), hash(c,c)). Test of this hash generation is verified here. 

8> test mining => mine first block == dummy_block (initial/genesis) + mined_block : 

Simulates the mining of the very first block. 

The Genesis block is created by default. Later, three unconfirmed tx from the pool are mined to form the very first valid block. The test validates that all the transactions are used and also verifies the mining code. 

9> verify blockchain at all users after mining => test the mined_block broadcast functionality : 

After the block is mined, we use the special function in NodeSupervisor.broadcast/2 to send the block to all the nodes. We verify that this works fine. 

10> test authenticity of a given transaction from the mined block : 

Mined block has a list of transactions. The Merkel Hash of the transactions is validated to be true. This tests that we have used valid transactions for mining. 

11> test mining => mine second block :

A second mining is done to mine the third block in the chain. Here we test the wallet balance of all nodes after mining and makes sure that block is broadcasted and verified and added at all the nodes. 

END> Here we exit all the mining processes, ProcessRegistry, Node process and the Supervisor gracefully. 

Project Description and further explanation :
--------------------------------------------- 

The project aims to implement the concept of BitCoin in Elixir. The implementation covers enough of the bitcoin protocol to be able to mine bitcoins, implement wallets (enough to get the other goals), transact bitcoins. The application supports users and miners. Users can perform transaction using bitcoins to others. Miners are special users who mine to earn a reward, which is a sum total of the fixed mining reward plus the transaction reward which is variable depending on the transaction which was mined. 

Distributed Ledger
------------------

The ledger is distributed and lies at the hands of all the participants. There is no central authority or bank to verify the authenticity of the transactions. 

Transaction
-----------

Transaction can be performed from one user to another in order to transfer some bitcoins. Transactions are hashed and encrpted using the private key of the sender to get a digital signature. The digital signature of the transaction can be verified in order to check its authenticity. This is done by validating using a function V(Tx_Hash, Digital_Signature, Public_Key) to return true. Each transaction when created goes to the pool of unconfirmed transactions.

Wallet 
------

A wallet is used to store the bitcoins associated with a user. Miner Rewards and transaction amounts are credited to the wallet after they are mined and added to the blockchain.

Block
-----

Block is a unit in the blockchain. It consists of the previous_block_hash, list_of_transactions, timestamp and an incremental randomly generated value by the miner called nonce.


Proof of Work
-------------

Every new block added to the blockchain is a proof that a miner was able to win the competition of solving the puzzle (mining). It is a proof that the entire computational power of the network was brought into effect or challenged. A greedy attacker will not be able to outgrow the honest chain without acquiring more than 50% of the computational power.


Bitcoin Mining
--------------

Bitcoin mining is a process where in each miner tries to create a block out of the few unconfirmed transactions.  The miner combines the block fields, hashes it and compares it with the difficulty. If it is found to be lesser, the miner has successfully mined a block. Else the miner will increment the nonce and try to mine again. After mining is successful, the miner will broadcast the mined block to all the nodes in the blockchain. The other miners will verify the validity of the block. If the block is found to be valid, they will add to their respective chains and will continue the mining work by working on the new block received.


Implementation
--------------

The miners are implemented as special users who are capable of mining. For simulation purposes, transactions occur between the participant every x seconds. The transactions go into the unconfirmed pool of transactions that lie at each of the nodes. The miners recursively mine continuously trying to solve the computational puzzle and genrating the block. The nodes are managed by a Supervisor with startegy : simple-one-for-one. The mined block is broadcasted to all the participants in the network. We have used the rsa_ex library to DigitalSignature sign and verify functionality. 

The transaction is signed and its digital signature is carried along which will be used by the miner to verify if the transaction is authentic. The miner does the following activities in order to verify that it received a valid block from the winner -

1. The received block has a previous_hash_value equal to the hash_value of the last block currently in the blockchain.
2. The receieved block is rehashed using its fields and the computed hash value is verified to be the same as that which is embedded in the block.
3. The transactions in the block are authentic. This is checked by validating the below two :

    a. The digital signature authenticity is validated by calling DigitalSignature.verify(tx_hash, digital_signature, public_key).
    
    b. The transaction validity is checked by iterating through all the blocks in the blockchain to verify if the sender had enough wallet balance at the point when the transaction is made. This is done by subtracting all the "from" transactions of the sender from the "to" transactions to the the sender at any point before the given transaction.
    
    
Design/Architecture
-------------------

Each node (user/miner) is represented as a Genserver process which is managed by a NodeSupervisor using the simple-one-for-one strategy. The miner is the only node which allowed to do a :mine operation. The :mine is triggered as an independent process which is attached to the node process. This is done because :mine is a recursive operation and self-call should be avoided.

The broadcast is done with the help of Nodesupervisor.broadcast/2 which does a broadcast to all the nodes it supervises. It is used at the time of block broadcast and transaction deltes.

Extra implementation
--------------------

In the extra implementation, we attempt to link a newly registred node (miner/user) to the Bitcoin network. The new user has to acquire the blockchain from one of the participants in the network. However, if there are many attackers (other than the honest nodes) then there may be variable blockchains in the network. Hence we need to arrive at a consensus where is more than 50% of the users have a unique chain on which they are working on at any moment. The newly registered node retrieves the last block hash from the other nodes and uses an alogorithm to compute if the blockchain it is retrieving is from the honest nodes. We evaluate the blockchain at each other participant node and then deduce the percentage and retrieve it from any of the honest node.

What we acquire from this is that all the newly registered users are honest and are not aware of the attackers in the network. Even though the attacker may be holding a longer chain, if it is not justified, the newly registered user will not acquire it.

Here we assume a new node :h to get registered as a miner/not depending on the argument given at input. The node will correctly acquire the honest chain and start working on it.


Unit Test Specification
------------------------

The unit tests included in the project attempt to test the functionalities of 

1. created the "first block"
2. hash_value generation
3. block and transaction hashing process
4. merkel root generation process
5. wallet balance updation process
6. mining process (tested by mining a valid block using 3 dummy transactions)
7. transaction validity verification process
8. block broadcast process
9. chaining and synchronization process


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blockchain` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blockchain, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/blockchain](https://hexdocs.pm/blockchain).

