defmodule TrelloTasker.Shared.Services.Trello do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.trello.com/1/cards"
  plug Tesla.Middleware.Headers, [{"User-Agent", "request"}]
  plug Tesla.Middleware.JSON

  @token Application.get_env(:trello_tasker, :trello)[:token]
  @key Application.get_env(:trello_tasker, :trello)[:key]

  def get_comments(card_id) do
    {:ok, response} =
      "#{card_id}/actions?commentCard&key=#{@key}&token=#{@token}"
      |> get()

    body = response.body

    body
    |> Enum.map(&%{text: &1["data"]["text"], author: &1["memberCreator"]["fullName"]})
  end

  def get_card(card_id) do
    default_image =
      "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1348&q=80"

    {:ok, response} =
      "#{card_id}?key=#{@key}&token=#{@token}"
      |> get()

    status = response.status

    if status !== 200 do
      {:error, "Erro ao buscar o card."}
    else
      body = response.body

      image = body["cover"]["sharedSourceUrl"] || default_image
      {:ok, delivery_date, _} = body["due"] |> DateTime.from_iso8601()

      %{
        name: body["name"],
        description: body["desc"],
        image: image,
        card_id: body["shortLink"],
        completed: body["dueComplete"],
        deliver_date: delivery_date |> DateTime.to_date()
      }
    end
  end
end
