defmodule EcampusWeb.Dashboard.ClassLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Classes
  alias Ecampus.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, %{list: classes, pagination: pagination}} = Classes.list_classes()

    today = Date.utc_today()
    calendar_days = calculate_calendar_days(today)

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:calendar_days, calendar_days)
     |> stream(:classes, classes)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Classes.get_class!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_info({EcampusWeb.ClassLive.FormComponent, {:saved, class}}, socket) do
    {:noreply, stream_insert(socket, :classes, class)}
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    {:noreply, socket}
    # current_date = socket.assigns[:calendar_days] |> hd() |> Map.get(:date)
    # new_date = shift_month(current_date.year, current_date.month, -1)

    # {:noreply, socket |> assign(:calendar_days, calculate_calendar_days(new_date))}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    {:noreply, socket}
    # current_date = socket.assigns[:calendar_days] |> hd() |> Map.get(:date)
    # new_date = shift_month(current_date.year, current_date.month, 1)

    # {:noreply, socket |> assign(:calendar_days, calculate_calendar_days(new_date))}
  end

  defp shift_month(year, month, shift) do
    new_month = month + shift

    cond do
      new_month < 1 -> %{year: year - 1, month: 12}
      new_month > 12 -> %{year: year + 1, month: 1}
      true -> %{year: year, month: new_month}
    end
  end

  def calendar(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <header class="bg-gray-800 text-white py-4 px-6 flex justify-between items-center">
        <button phx-click="prev_month" class="btn btn-sm btn-outline">Предыдущий</button>
        <h1 class="text-lg font-bold">Календарь на текущий месяц</h1>
        <button phx-click="next_month" class="btn btn-sm btn-outline">Следующий</button>
      </header>
      <div class="flex-1 grid grid-cols-7 grid-rows-[auto,repeat(5,minmax(0,1fr))] bg-base-100">
        <div class="font-bold text-center p-2">Пн</div>
        <div class="font-bold text-center p-2">Вт</div>
        <div class="font-bold text-center p-2">Ср</div>
        <div class="font-bold text-center p-2">Чт</div>
        <div class="font-bold text-center p-2">Пт</div>
        <div class="font-bold text-center p-2">Сб</div>
        <div class="font-bold text-center p-2">Вс</div>

        <%= for day <- assigns[:calendar_days] do %>
          <div class={"p-4 text-center border #{if day[:current_month], do: "bg-base-200", else: "bg-base-100"}"}>
            {day[:date].day}
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp calculate_calendar_days(%Date{year: year, month: month}) do
    first_day = Date.new!(year, month, 1)
    last_day = Date.end_of_month(first_day)

    start_date = shift_to_week_start(first_day)
    end_date = shift_to_week_end(last_day)

    Enum.map(Date.range(start_date, end_date), fn date ->
      %{
        date: date,
        current_month: date.month == month
      }
    end)
  end

  defp shift_to_week_start(date) do
    days_to_shift = Date.day_of_week(date) - 1
    Date.add(date, -days_to_shift)
  end

  defp shift_to_week_end(date) do
    days_to_shift = 7 - Date.day_of_week(date)
    Date.add(date, days_to_shift)
  end
end
