defmodule DigitalSignature do
	
	def gen_private_key do
		
		{:ok, priv} = RsaEx.generate_private_key
		priv
	end

	def gen_public_key(priv) do
		
		{:ok, pub} = RsaEx.generate_public_key(priv)
		pub
	end

	def gen_key_pair do
		{:ok, {priv, pub}} = RsaEx.generate_keypair
		{priv, pub}
	end

	def sign(msg, priv) do
		{:ok, signature} = RsaEx.sign(msg, priv, :sha256)
		signature
	end

	def verify(msg, signature, pub) do
		{:ok, valid} = RsaEx.verify(msg, signature, pub, :sha256)
		valid
	end

	def test do
		{priv, pub} = gen_key_pair()
		priv_2 = gen_private_key()
		pub_2 = gen_public_key(priv_2)
		IO.puts pub_2
		msg = "test"
		signature = sign(msg, priv)
		valid =	verify(msg,signature, pub)
		IO.puts valid
		IO.puts "signature == #{inspect signature}"
		IO.puts "verify_true === #{verify(msg, signature, pub)}"
		IO.puts "verify_false === #{verify(msg, signature, pub_2)}"
	end

end
# DigitalSignature.test