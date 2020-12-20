defmodule TrelloTasker.Shared.Services.CreateCard do
  alias TrelloTasker.Cards
  alias TrelloTasker.Shared.Services.Trello
  alias TrelloTasker.Shared.Providers.CacheProvider.CardCacheClient

  @table "card-list"

  def execute(card) do
    card["path"]
    |> Trello.get_card()
    |> case do
      {:error, msg} ->
        {:trello_error, msg}

      card_info ->
        card
        |> Cards.create_card()
        |> return_call()
    end
  end

  defp return_call({:error, changeset}), do: {:error, changeset}

  defp return_call({:ok, card}) do
    {:ok, cards} = CardCacheClient.recover(@table)

    card_trello =
      card.path
      |> Trello.get_card()

    CardCacheClient.save(@table, [card_trello | cards])
    {:ok, card}
  end

  # defp return_call({}), do:
  # defp return_call({}), do:
end
