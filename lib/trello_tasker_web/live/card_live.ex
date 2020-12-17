defmodule TrelloTaskerWeb.CardLive do
  use TrelloTaskerWeb, :live_view

  alias Phoenix.View
  alias TrelloTasker.Cards.Card
  alias TrelloTaskerWeb.CardView
  alias TrelloTasker.Shared.Services.Trello

  @impl true
  def mount(_params, _session, socket) do
    changeset = Card.changeset(%Card{})
    card = Trello.get_card("YJTz9VoY")

    socket =
      socket
      |> assign(cards: [card, card], changeset: changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("create", %{"card" => card}, socket) do
    changeset = %Ecto.Changeset{Card.changeset(%Card{}, card) | action: :insert}

    changeset.valid?
    |> case do
      false ->
        {:noreply, assign(socket, :changeset, changeset)}

      true ->
        card["path"]
        |> case do
          {:error, msg} ->
            {:noreply, socket |> put_flash(:error, msg) |> push_redirect(to: "/")}

          card_info ->
            {:noreply, socket}
        end
    end
  end

  @impl true
  def render(assigns) do
    View.render(CardView, "index.html", assigns)
  end
end
