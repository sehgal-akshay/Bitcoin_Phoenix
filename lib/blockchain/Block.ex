defmodule Block do
  
    defstruct [:index, :timestamp, :hash_value, :prev_block_hash, :transactions, :nonce]

    @doc "Build a new block for given dinput"
    def new(index, hash_value \\ nil, prev_block_hash, transactions, nonce) do
      %Block{
        index: index,
        timestamp: NaiveDateTime.utc_now,
        hash_value: hash_value,
        prev_block_hash: prev_block_hash,
        transactions: transactions,
        nonce: nonce
      }
    end

    def hash_block(block) do

       s_index = if block.index==nil do "" else Integer.to_string(block.index) end
       s_prev_block_hash = if block.prev_block_hash == nil do "" else block.prev_block_hash end
       #s_transactions_merkel_root stores the merkel root of the transactions
       s_transactions_merkel_root = if block.transactions == nil do "" else Transaction.getMerkelRoot(block.transactions) end
       s_nonce = if block.nonce == nil do "" else Integer.to_string(block.nonce) end
       HashGenerator.hash(s_index <> s_prev_block_hash <> s_transactions_merkel_root <> s_nonce) |> Base.encode16

    end

    #Calculates the hash and adds it to the block
    def put_hash(%{} = block) do
       %{ block | hash_value: hash_block(block) }
    end

    def test do
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
        IO.puts hash_block(block)
    end
  
end
# Block.test
