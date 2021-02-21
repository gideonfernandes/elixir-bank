defmodule Account do
  defstruct user: User, balance: 0

  @accounts "accounts.txt"

  def get_accounts do
    {:ok, binary_accounts} = File.read(@accounts)
    :erlang.binary_to_term(binary_accounts)
  end

  def register(user, balance) do
    accounts = get_accounts()

    case find_by_email(user.email) do
      nil ->
        binary_accounts = [%__MODULE__{user: user, balance: balance}] ++
        accounts |> :erlang.term_to_binary()
        
        File.write(@accounts, binary_accounts)
        {:ok, "Conta registrada com sucesso!"}
      _ -> {:error, "Usuário já existe!"}
    end
  end
  
  def transfer(from_email, to_email, value) do
    from = find_by_email(from_email)
    to = find_by_email(to_email)

    cond do
      from === nil || to === nil -> {:error, "Dupla de contas inválidas..."}
      
      value === 0 -> {:error, "Valor da transferência deve ser maior que 0."}
      
      invalid_balance(from.balance, value) -> {:error, "Saldo insuficiente..."}
      
      true ->
        accounts = get_accounts()
        accounts = accounts -- [from, to]

        from = %__MODULE__{from | balance: from.balance - value}
        to = %__MODULE__{to | balance: to.balance + value}

        binary_accounts = :erlang.term_to_binary(accounts ++ [from, to])
        File.write(@accounts, binary_accounts)

        Transaction.record_transfer(
          Date.utc_today, "transfer", value, from_email, to_email
        )

        {:ok, "Transferência realizada com sucesso!"}
    end
  end

  def withdraw(account_email, value) do
    account = find_by_email(account_email)

    cond do
      account === nil -> {:error, "Conta inválida..."}
      
      value === 0 -> {:error, "Valor do saque deve ser maior que 0."}
      
      invalid_balance(account.balance, value) ->
        {:error, "Saldo insuficiente..."}
      
      true ->
        accounts = get_accounts()
        accounts = List.delete(accounts, account)
        account = %__MODULE__{account | balance: account.balance - value}

        binary_accounts = :erlang.term_to_binary(accounts ++ [account])
        File.write(@accounts, binary_accounts)
        IO.puts "Enviando email de sucesso..."

        Transaction.record_transfer(
          Date.utc_today, "withdraw", value, account_email
        )

        {:ok, "Saque realizado com sucesso!"}
    end
  end

  def destroy_account(email) do
    accounts = get_accounts()
    binary_accounts = Enum.filter(accounts, &(&1.user.email !== email))
    |> :erlang.term_to_binary()
        
    File.write(@accounts, binary_accounts)
  end

  defp find_by_email(email) do
    Enum.find(get_accounts(), &(&1.user.email === email))
  end

  defp invalid_balance(balance, value), do: balance < value
end