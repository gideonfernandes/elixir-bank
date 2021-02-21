defmodule User do
  defstruct name: nil, email: nil

  def create(name, email), do: %__MODULE__{name: name, email: email}
end