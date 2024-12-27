defmodule EcampusWeb.Dashboard.ClassLive.Topic do
  use EcampusWeb, :live_view
  alias Ecampus.Classes
  alias Ecampus.Lessons
  alias Ecampus.Quizzes

  @stop_rendering_flag "<!-- Rendering stopped -->"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "class_id" => class_id}, _, socket) do
    {topic, socket} =
      Lessons.get_lesson_topic(id)
      |> parse_markdown(socket)

    class = Classes.get_class(class_id)
    %{lesson_id: lesson_id} = class

    %{group_id: group_id} = socket.assigns[:current_user]

    case {class, topic} do
      {%{group: %{id: ^group_id}}, %{lesson_id: ^lesson_id}} ->
        {:noreply,
         socket
         |> assign(:topic, topic)}

      {_, _} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  @impl true
  def handle_event("start-quiz", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(action, %{"id" => id}, socket)
      when action in ["next-question", "prev-question"] do
    quiz_id = String.to_integer(id)
    question_indexes = Map.get(socket.assigns, :question_indexes, %{})
    quiz = Quizzes.get_quiz(quiz_id)

    current_question_index =
      case Map.get(question_indexes, quiz_id) do
        nil -> 0
        index when index == length(quiz.questions) - 1 and action == "next-question" -> 0
        index when action == "next-question" -> index + 1
        index when index == 0 and action == "prev-question" -> length(quiz.questions) - 1
        index when action == "prev-question" -> index - 1
      end

    updated_socket =
      socket
      |> assign(:question_indexes, Map.put(question_indexes, quiz_id, current_question_index))

    {topic, updated_socket} =
      Map.get(updated_socket.assigns, :topic)
      |> parse_markdown(updated_socket)

    {:noreply,
     updated_socket
     |> assign(:topic, topic)}
  end

  defp render_quiz(assigns) do
    ~H"""
    <div class="not-prose card shadow-md">
      <div class="card-body">
        <h2 class="card-title my-0">{@quiz.title}</h2>
        <p class="text-sm">{@quiz.description}</p>
        <div class="card-actions justify-end">
          <button phx-click="start-quiz" phx-value-id={@quiz.id} class="btn btn-primary">
            Begin
          </button>
        </div>
      </div>
      <div class="card-body">
        <h3 class="card-title my-0">{@question.title}</h3>
        <p class="text-sm">{@question.subtitle}</p>
        <%= for answer <- @question.answers do %>
          <%= if @question.type == :multiple do %>
            <.input name="answer" type="checkbox" label={answer.title} />
          <% end %>
          <%= if @question.type == :sequence do %>
            <button class="btn btn-ghost">{answer.title}</button>
          <% end %>
        <% end %>
        <div class="card-actions justify-end">
          <button phx-click="prev-question" phx-value-id={@quiz.id} class="btn btn-ghost">
            Prev
          </button>
          <button phx-click="next-question" phx-value-id={@quiz.id} class="btn btn-primary">
            Next
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp parse_markdown(lesson_topic, socket) do
    {replaced_content, socket} =
      replace_custom_tags(Earmark.as_html!(lesson_topic.content), socket)

    html_content =
      replaced_content
      |> String.split(@stop_rendering_flag)
      |> List.first()

    {Map.put(lesson_topic, :html_content, html_content), socket}
  end

  defp replace_custom_tags(content, socket),
    do:
      content
      |> replace_quiz(socket)

  defp replace_quiz(content, socket) do
    {updated_content, updated_socket} =
      Regex.scan(~r/\[quiz (\d+)\]/, content)
      |> Enum.reduce({content, socket}, fn [_, id], {content_acc, socket_acc} ->
        quiz_id = String.to_integer(id)

        question_indexes = Map.get(socket.assigns, :question_indexes, %{})

        question_indexes =
          case Map.get(question_indexes, quiz_id, -1) do
            -1 -> Map.put(question_indexes, quiz_id, 0)
            index -> Map.put(question_indexes, quiz_id, index)
          end

        updated_socket_acc =
          socket_acc
          |> assign(:question_indexes, question_indexes)

        quiz = Quizzes.get_quiz(quiz_id)
        question = Enum.at(quiz.questions, Map.get(question_indexes, quiz_id))

        quiz_html =
          render_quiz(%{
            quiz: quiz,
            question: question
          })
          |> Phoenix.HTML.Safe.to_iodata()
          |> to_string()

        updated_content_acc =
          String.replace(content_acc, "[quiz #{quiz_id}]", quiz_html)

        {updated_content_acc, updated_socket_acc}
      end)

    {
      updated_content,
      updated_socket
    }
  end
end
