defmodule BlockchainTest do
  use ExUnit.Case

  @users [:a, :b, :c]

  setup_all do
	{:ok, supervisor_pid} = NodeSupervisor.start_link
	{:ok, registry_pid} = ProcessRegistry.start_link
	nodeMap = Initializer.startusers(@users) #Starting with 3 users
	minersMap = Initializer.startminers([:m1]) #Starting with 1 miner
	ProcessRegistry.merge nodeMap
	ProcessRegistry.merge minersMap
	:timer.sleep 3000
	Initializer.listen_at_user_nodes(@users)
	on_exit fn ->
	  IO.puts "Test Complete. Stopping supervisor." 
	  assert_down(registry_pid)    
	  assert_down(supervisor_pid)
      :ok
    end
    IO.puts "Starting Assertion_Blockchain_Test"
    :ok
  end

  defp assert_down(pid) do
	 ref = Process.monitor(pid)
	 assert_receive {:DOWN, ^ref, _, _, _}
  end 

  test "target hash value test" do

  	target_hash = "000" <> String.slice(Base.encode16(HashGenerator.hash(:crypto.strong_rand_bytes(20))), 3..63)
    assert String.length(target_hash) == 64
  end

  test "transaction hash test" do

  	{priv1, pub1} = DigitalSignature.gen_key_pair()
  	ds1 = DigitalSignature.sign("tx1", priv1)
  	tx = Transaction.new(:a, :b, nil, nil, 50, ds1, pub1)
  	tx_hash = Transaction.hash_transaction(tx)
    assert String.length(tx_hash) == 64
  end

   test "block hash test" do

   	IO.puts "Test : block hash test"
  	{priv1, pub1} = DigitalSignature.gen_key_pair()
    ds1 = DigitalSignature.sign("tx1", priv1)

    {priv2, pub2} = DigitalSignature.gen_key_pair()
    ds2 = DigitalSignature.sign("tx2", priv2)

    {priv3, pub3} = DigitalSignature.gen_key_pair()
    ds3 = DigitalSignature.sign("tx3", priv3)

    tx1 = Transaction.new(:a, :b, nil, nil, 50, ds1, pub1)
    tx2 = Transaction.new(:b, :a, nil, nil, 20, ds2, pub2)
    tx3 = Transaction.new(:a, :a, [tx1, tx2], [tx2], 10, ds3, pub3)

    block = Block.new(1, nil, "00000000", [tx1, tx2, tx3], 123412)
    block_hash = Block.hash_block(block)
    assert String.length(block_hash) == 64
  end


  @wallet_amount 10000
  test "generate initial wallet ballance test" do
  	
  	IO.puts "Test : generate initial wallet ballance test"
  	SysConfigs.generateInitialWalletBalance([:a, :b, :c])
  	a_balance = NodeCoordinator.get_wallet_balance(:a)
  	b_balance = NodeCoordinator.get_wallet_balance(:b)
  	c_balance = NodeCoordinator.get_wallet_balance(:c)
  	assert a_balance == @wallet_amount
  	assert b_balance == @wallet_amount
  	assert c_balance == @wallet_amount
  end

  test "test digital signature - sign and verify" do

  	IO.puts "Test : test digital signature - sign and verify"
  	#Original private and public pair used to encrypt and decrypt
  	{priv, pub} = DigitalSignature.gen_key_pair()
  	#Another private, public pair 
	priv_2 = DigitalSignature.gen_private_key()
	pub_2 = DigitalSignature.gen_public_key(priv_2)
	#message which should be encrypted
	msg = "test"
	#The digital signature of the message
	signature = DigitalSignature.sign(msg, priv)
	#Verification using the original public_key should yield true 
	valid =	DigitalSignature.verify(msg, signature, pub)
	#Verification using wrong public_key should yield false
	valid2 = DigitalSignature.verify(msg, signature, pub_2)
	assert valid == true
	refute valid2 == true
  end

  test "test validation of transaction" do

  	IO.puts "Test : test validation of transaction"
  	unconfirmed_transactions = NodeCoordinator.get_unconfirmed_transactions(:m1)
  	#3 because we have generatedInitialWalletBallace tx for 3 nodes => 3 tx in the unconfirmed_pool
  	assert length(unconfirmed_transactions) == 3
  	first_transaction = Enum.at(unconfirmed_transactions, 0)
  	valid = Transaction.validate(first_transaction)
  	assert valid == true
  end

  test "merkle tree test" do
  	
  	IO.puts "Test : merkle tree test"
  	{priv1, pub1} = DigitalSignature.gen_key_pair()
  	ds1 = DigitalSignature.sign("tx1", priv1)

  	{priv2, pub2} = DigitalSignature.gen_key_pair()
  	ds2 = DigitalSignature.sign("tx2", priv2)

  	{priv3, pub3} = DigitalSignature.gen_key_pair()
  	ds3 = DigitalSignature.sign("tx3", priv3)

  	tx1 = Transaction.new(:a, :b, nil, nil, 50, ds1, pub1)
	tx2 = Transaction.new(:b, :a, nil, nil, 20, ds2, pub2)
	tx3 = Transaction.new(:a, :a, [tx1, tx2], [tx2], 10, ds3, pub3)
	tx4 = Transaction.new(:c, :c, [tx3, tx2], [tx3, tx2], 3, nil, nil)

	merkleroot = Transaction.getMerkelRoot([tx1, tx2, tx3, tx4, tx2])
	assert String.length(merkleroot) == 64

  end

  @mining_reward 100
  test "test mining => mine first block == dummy_block (initial/genesis) + mined_block" do
  	
  	IO.puts "Test : test mining => mine first block == dummy_block (initial/genesis) + mined_block"
  	mining_process = NodeCoordinator.mine(:m1)
  	:timer.sleep 5000
  	IO.puts("mining process = #{inspect mining_process}")
    Process.exit(mining_process, :ok)
    blockchain = NodeCoordinator.get_blockchain(:m1)
    #Length of blockchain is 2, first block is the empty_block(initial) 
    #and the second one is the mined one
    assert length(blockchain) == 2
    mined_block = Enum.at blockchain, 1
    assert mined_block.prev_block_hash == "00000000000000000"
    assert mined_block.hash_value == Block.hash_block(mined_block)
    #All the 3 tx from the inconfirmed_pool should go into the block
    assert length(mined_block.transactions) == 3
    tx = Enum.at(mined_block.transactions, 0)
    assert tx.amount == 10000
    a_balance = NodeCoordinator.get_wallet_balance(:a)
    b_balance = NodeCoordinator.get_wallet_balance(:b)
    c_balance = NodeCoordinator.get_wallet_balance(:c)
    assert a_balance == 20000
    assert b_balance == 20000
    assert c_balance == 20000
    m1_balance = NodeCoordinator.get_wallet_balance(:m1)
    tx_reward = Node.get_transaction_reward(mined_block.transactions)
    assert m1_balance == 10000 + @mining_reward + tx_reward
  end

  test "verify blockchain at all users after mining => test the mined_block broadcast functionality" do
  	
  		IO.puts "Test : verify blockchain at all users after mining => test the mined_block broadcast functionality"
  	 	a_blockchain = NodeCoordinator.get_blockchain(:a)
	  	assert length(a_blockchain) == 2

	  	b_blockchain = NodeCoordinator.get_blockchain(:b)
	  	assert length(b_blockchain) == 2

	  	c_blockchain = NodeCoordinator.get_blockchain(:c)
	  	assert length(c_blockchain) == 2

	  	a_transactions = (Enum.at(a_blockchain, -1)).transactions
	  	b_transactions = (Enum.at(b_blockchain, -1)).transactions
	  	c_transactions = (Enum.at(c_blockchain, -1)).transactions

	  	assert length(a_transactions) == 3
	  	assert length(b_transactions) == 3
	  	assert length(c_transactions) == 3

  end

  test "test authenticity of a given tx from the mined block" do
  	
  		IO.puts "Test : test authenticity of a given tx from the mined block"
  	 	a_blockchain = NodeCoordinator.get_blockchain(:a)
  	 	mined_block = Enum.at(a_blockchain, -1)
  	 	tx = Enum.at mined_block.transactions, 0
  	 	valid = Transaction.validate(tx)
  	 	assert valid == true
  end

  @mining_reward 100
  test "test mining => mine second block" do
  	
  	IO.puts "Test : test mining => mine second block"
  	#Wallet balance of :m1 before mining
  	m1_initial_balance = NodeCoordinator.get_wallet_balance(:m1)
  	#Create 3 more dummy transactions before mining second block
  	SysConfigs.generateInitialWalletBalance([:a, :b, :c])
  	unconfirmed_transactions = NodeCoordinator.get_unconfirmed_transactions(:m1)
  	assert length(unconfirmed_transactions) == 3
  	mining_process = NodeCoordinator.mine(:m1)
  	:timer.sleep 5000
    Process.exit(mining_process, :normal)
    blockchain = NodeCoordinator.get_blockchain(:m1)
    #Length of blockchain is 2, first block is the empty_block(initial) 
    #and the second one is the mined one
    assert length(blockchain) == 3
    mined_block = Enum.at blockchain, -1
    assert mined_block.hash_value == Block.hash_block(mined_block)
    #All the 3 tx from the inconfirmed_pool should go into the block
    assert length(mined_block.transactions) == 3
    tx = Enum.at(mined_block.transactions, 0)
    assert tx.amount == 10000
    a_balance = NodeCoordinator.get_wallet_balance(:a)
    b_balance = NodeCoordinator.get_wallet_balance(:b)
    c_balance = NodeCoordinator.get_wallet_balance(:c)
    assert a_balance == 30000
    assert b_balance == 30000
    assert c_balance == 30000
    m1_balance = NodeCoordinator.get_wallet_balance(:m1)
    tx_reward = Node.get_transaction_reward(mined_block.transactions)
    assert m1_balance ==  m1_initial_balance + @mining_reward + tx_reward
  end


end