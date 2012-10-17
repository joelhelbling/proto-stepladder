require './lib/stepladder'

statement = "The quick brown fox jumped over the lazy dog."

wordsmith = Stepladder::Faucet.new(-1) do |injected|
  injected += 1
  statement.split(/\s/)[injected]
end

