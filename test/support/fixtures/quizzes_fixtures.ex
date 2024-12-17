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
end
