defmodule Bank do
  @accounts "accounts.txt"
  @transactions "transactions.txt"

  def init do
    File.write(@accounts, :erlang.term_to_binary([]))
    File.write(@transactions, :erlang.term_to_binary([]))
  end
end
