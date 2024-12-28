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
  def handle_event("start-quiz", %{"quiz-id" => id}, socket) do
    quiz_id = String.to_integer(id)
    Quizzes.start_quiz(%{quiz_id: quiz_id, user_id: socket.assigns.current_user.id})

    {topic, updated_socket} =
      Map.get(socket.assigns, :topic)
      |> parse_markdown(socket)

    {:noreply,
     updated_socket
     |> assign(:topic, topic)}
  end

  @impl true
  def handle_event(action, %{"quiz-id" => id} = _params, socket)
      when action in ["next-question", "prev-question"] do
    quiz_id = String.to_integer(id)

    # result =
    #   params
    #   |> Enum.filter(fn {key, value} ->
    #     String.starts_with?(key, "answer-") and value == "true"
    #   end)
    #   |> Enum.map(fn {key, _value} ->
    #     Regex.run(~r/answer-(\d+)/, key)
    #     |> List.last()
    #     |> String.to_integer()
    #   end)

    question_indexes = Map.get(socket.assigns, :question_indexes, %{})
    quiz = Quizzes.get_started_quiz(%{quiz_id: quiz_id, user_id: socket.assigns.current_user.id})

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
      <%= if length(@quiz.questions) == 0 do %>
        <div class="card-body">
          <h2 class="card-title my-0">{@quiz.title}</h2>
          <p class="text-sm">{@quiz.description}</p>
          <div class="card-actions justify-end">
            <button phx-click="start-quiz" phx-value-quiz-id={@quiz.id} class="btn btn-primary">
              Begin
            </button>
          </div>
        </div>
      <% else %>
        <form class="card-body" phx-submit="next-question">
          <.input name="quiz-id" type="hidden" value={@quiz.id} />
          <h3 class="card-title my-0">{@question.title}</h3>
          <p class="text-sm">{@question.subtitle}</p>
          <%= for answer <- @question.answers do %>
            <%= if @question.type == :multiple do %>
              <.input name={"answer-#{answer.id}"} type="checkbox" label={answer.title} />
            <% end %>
            <%= if @question.type == :sequence do %>
              <button class="btn btn-ghost">{answer.title}</button>
            <% end %>
          <% end %>
          <div class="card-actions justify-end">
            <button phx-click="prev-question" phx-value-quiz-id={@quiz.id} class="btn btn-ghost">
              Prev
            </button>
            <button type="submit" class="btn btn-primary">
              Next
            </button>
          </div>
        </form>
      <% end %>
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

        quiz =
          Quizzes.get_started_quiz(%{quiz_id: quiz_id, user_id: socket.assigns.current_user.id})

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
