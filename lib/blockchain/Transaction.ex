defmodule Transaction do

  defstruct [:from, :to, :input_value, :output_value, :timestamp, :amount, :digital_signature, :public_key, :reward]

  @doc "Builds a Transaction using from, to, input_value, output_value, timestamp and amount"
  def new(from, to, input_value \\nil, output_value \\nil, amount, digital_signature \\nil, public_key \\nil, reward \\0) do
    %Transaction{
      from: from,
      to: to,
      input_value: input_value,
      output_value: output_value,
      timestamp: NaiveDateTime.utc_now,
      amount: amount,
      digital_signature: digital_signature,
      public_key: public_key,
      reward: reward
    }
  end

  @doc "Gives the Merkel Root hash of the list of transactions"
  def getMerkelRoot(transactions) do
  		if (transactions == nil || Enum.empty?transactions) do
  			""	
  		else
	  		if (length(transactions) == 1) do
	  			hash_transaction(Enum.at(transactions, 0))
	  		else

			  	list =
			  		transactions |> Enum.with_index |> Enum.reduce([], fn {current, i}, acc ->

			  			acc =
			  				if (rem(i,2) ==1 || i == length(transactions)-1) do
			  					acc
			  				else
			  					cur = hash_transaction(current)
			  					next = hash_transaction(Enum.at(transactions, i+1))
			  					Enum.concat [acc, [hash_transaction(cur<>next)]]
			  				end
			  			acc
			  		end)
			  	list = 
				  	if rem(length(transactions),2) == 1 do
				  		last = hash_transaction(Enum.at(transactions, length(transactions)-1))
				  		Enum.concat(list, [hash_transaction(last<>last)])
				  	else
				  		list
				  	end
				getMerkelRoot(list)
			end
		end
  end

  @doc "Hashes the given transaction suppied as struct map. Digital_signature and public_key should not be included in the hash."
  def hash_transaction(transaction) do

  		if transaction == nil do
  			""
  		else
	  		if (is_map(transaction)) do
	  	
		  	    s_from = if transaction.from == nil do "" else Atom.to_string(transaction.from) end
		  	    s_to = if transaction.to == nil do "" else Atom.to_string(transaction.to) end
		  	    s_input_value = if (transaction.input_value == nil || length(transaction.input_value) == 0) do "" 
		  						else Enum.reduce(transaction.input_value, "", fn(input, acc) -> acc <> hash_transaction(input) end) end
		  	    s_output_value = if (transaction.input_value == nil || length(transaction.output_value) == 0) do "" 
		  						else Enum.reduce(transaction.output_value, "", fn(output, acc) -> acc <> hash_transaction(output) end) end
		  	    s_amount = if transaction.amount == nil do "" else Integer.to_string(transaction.amount) end

		  	    HashGenerator.hash(s_from <> s_to <> s_input_value <> s_output_value <> s_amount) |> Base.encode16
			else
	  	   	    HashGenerator.hash(transaction) |> Base.encode16
			end
		end
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
	tx4 = Transaction.new(:c, :c, [tx3, tx2], [tx3, tx2], 3, nil, nil)
	# IO.inspect Transaction.hash_transaction(tx3)
	IO.inspect Transaction.getMerkelRoot([tx1, tx2, tx3, tx4, tx2])
  end


  def validate(transaction) do

  	msg = hash_transaction(transaction)
  	valid = DigitalSignature.verify(msg, transaction.digital_signature, transaction.public_key)
  	# IO.puts "Transaction is #{valid}"
  	valid
  end
end

# Transaction.test

  
