defmodule Transaction do
  defstruct date: Date.utc_today, type: nil, value: 0, from: nil, to: nil

  @transactions "transactions.txt"

  def record_transfer(date, type, value, from, to \\ nil) do
    transactions = get_transactions()

    binary_transactions = transactions ++
    [%__MODULE__{date: date, type: type, value: value, from: from, to: to}]
    |> :erlang.term_to_binary

    File.write(@transactions, binary_transactions)
    {:ok, "Transação registrada com sucesso!"}
  end

  def list_transactions(year \\ nil, month \\ nil, day \\ nil) do
    cond do
      year && month && day ->
        Enum.filter(get_transactions(), &(&1.date.year === year &&
          &1.date.month === month && &1.date.day === day))
      
      year && month ->
        Enum.filter(get_transactions(), &(&1.date.year === year &&
          &1.date.month === month))
      
      year -> Enum.filter(get_transactions(), &(&1.date.year === year))
      
      true -> get_transactions()
    end
  end

  def calc_transactions(year \\ nil, month \\ nil, day \\ nil) do
    cond do
      year && month && day ->
        "Valor total de transferências no dia #{day} do mês #{month} de #{year}"
        <> " corresponde a: R$#{
          Enum.reduce(list_transactions(year, month, day), 0, &(&1.value + &2))
        },00"
      
      year && month ->
        "Valor total de transferências do mês #{month} de #{year}" <>
        " corresponde a: R$#{
          Enum.reduce(list_transactions(year, month), 0, &(&1.value + &2))},00"
      
      year ->
        "Valor total de transferências no ano de #{year}" <>
        " corresponde a: R$#{
          Enum.reduce(list_transactions(year), 0, &(&1.value + &2))},00"
      
      true ->
        "Valor total de transferências corresponde a: R$#{
          Enum.reduce(get_transactions(), 0, &(&1.value + &2))},00"
    end
  end

  defp get_transactions do
    {:ok, binary_transactions} = File.read(@transactions)

    :erlang.binary_to_term(binary_transactions)
  end
end