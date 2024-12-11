defmodule EcampusWeb.LessonTopicLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "lesson_id" => lesson_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson_id, lesson_id)
     |> assign(:lesson_topic, Lessons.get_lesson_topic!(id))}
  end

  defp page_title(:show), do: "Show Lesson topic"
  defp page_title(:edit), do: "Edit Lesson topic"
end
