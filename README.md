# Blockchain

Members - Aswin Suresh Krishnan (UFID : 1890-1173)
	  	  Akshay Sehgal (UFID : 1416-7988)

How to run
----------

> Run Program :

mix phx.server

Dependency resolution (optional) : mix deps clean; mix deps.get

> Run Application Tests (not UI)

mix test --no-start


Program overview [for brief understanding]
------------------------------------------

We start the web application with a default of 7 miners and 7 users. 

> 100 user simulation

There is an option to 'Run Simulation' which will add extra 100 users and perform transaction between the randomly selected users in interval of 30 seconds

When refreshing the home screen, we can see the amount of transactions that are mined and what are opending.


Project Descripation and further explanation :
--------------------------------------------- 

The project aims to provide a User Interface for the users to perform transactions and for miners to participate in mining and earn reward as bitcoin. 

The following options are provided in the User Interface -

1> Enter as User
	> View Wallet Balance
	> Perform Transaction
	  > Enter target user and amount -> start transaction

2> Enter as Miner
	> View Wallet Balance
	> Start Mine
	> Stop Mine
	> View BlockChain

3> View the proportion of the mined transactions on the home screen pie chart

4> View the current status of the BlockChain on the 'View Blockchain' Screen

5> View the mining rate chart on the 'Statistics' screen

6> Unconfirmed and mined transactions are visible on the home screen on separate tables.

7> 'Run Simulation' will add 100 new users and start a simulation in which transactions occur between two randomly selected users at an interval of 30 seconds.


The users need to log in by selecting their name and perform a transaction to another user by selecting therecipient's name and amount.

The miners need to start mining in order for the unconfirmed transactions (which are stored in each miner's state) are mined to form a block and the mining algorithm comes into action (competition among miners begin) when multiple miners click on the 'Start mine' button.

Any miner can at any point stop their mining activity by clicking on the 'Stop mine' option on the miner's screen.

The above activities can be simulated by using 'Run Simulation' option on the home screen.
Note : a 5 sec wait time is expected for 100 new users to be spawned by the Supervisor. However the initiation begins as a background process and no halt is seen on the UI.

Implementation
--------------

Application outline:

The mining process can be initiated when a miner logs in and clicks on 'Start Mine' option. 

When multiple miners do this, there is a race to mine faster and the miner who actually mines wins the reward. The new balace in credited to the miner's account and can be seen on the 'View Balance' option on the miner screen.

Also a user can log in and go the User screen and select 'Do Transaction' to send an amount to another user. This transaction will be in pending state until it gets mined by some miner. It will get added to the wallet balance of the receiver once mining is complete and the receiving user accepts it. It can be viewed by clicking on the 'View Balance' on the User's screen. Also the same amount is debited from the sender's account and can be seen on UI by clicking on 'View Balance' on the Sending User's account.


Design/Architecture
--------------------

The design is in such a way that the person logging is can either be a user or a miner. The user should be able to access functionalities only on the Users Screen and also on the Home Screen. The user can either perform a transaction or view his balance. We have split up these activities on separate pages so that there is no intersection of each other's activities.

The miner has an exclusive access to mine as well as view blockchain on his screen. However the miner can also view the blockchain status from the Home Screen. 

We have designed two charts :
 
1> Pie chart which shows the proportion of unconfirmed and mined transactions. Location : Home screen.
2> Line chart which shows the rate of mining performed by the bitcoin application. Location : Statistics screen.

We have used the 'kickchart' library for plotting charts.

These two charts along with the two tables provide clear interpretation of how the application is performing under low and heavy load.

Extra implementation
--------------------



Unit Test Specification (application tests)
------------------------------------------------

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

