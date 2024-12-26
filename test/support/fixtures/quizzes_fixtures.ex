defmodule Ecampus.QuizzesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Quizzes` context.
  """

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        description: "some description",
        questions_per_attempt: 42,
        title: "some title"
      })
      |> Ecampus.Quizzes.create_quiz()

    quiz
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        grade: 42,
        show_correct_answer: true,
        subtitle: "some subtitle",
        title: "some title",
        type: :single
      })
      |> Ecampus.Quizzes.create_question()

    question
  end

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        is_correct: true,
        sequence_order_number: 42,
        subtitle: "some subtitle",
        title: "some title"
      })
      |> Ecampus.Quizzes.create_answer()

    answer
  end
end
