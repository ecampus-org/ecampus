defmodule EcampusWeb.QuestionLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Quizzes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "quiz_id" => quiz_id, "lesson_id" => lesson_id}, _, socket) do
    question = Quizzes.get_question(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:quiz_id, quiz_id)
     |> assign(:lesson_id, lesson_id)
     |> assign(:question, question)}
  end

  defp page_title(:show), do: "Show Question"
  defp page_title(:edit), do: "Edit Question"
end
