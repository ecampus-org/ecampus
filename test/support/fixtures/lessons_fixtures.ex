defmodule Ecampus.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Lessons` context.
  """

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        hours_count: 42,
        is_draft: true,
        objectives: "some objectives",
        sort_order: 42,
        title: "some title",
        topic: "some topic"
      })
      |> Ecampus.Lessons.create_lesson()

    lesson
  end

  @doc """
  Generate a lesson_topic.
  """
  def lesson_topic_fixture(attrs \\ %{}) do
    {:ok, lesson_topic} =
      attrs
      |> Enum.into(%{
        content: "some content",
        sort_order: 42,
        title: "some title"
      })
      |> Ecampus.Lessons.create_lesson_topic()

    lesson_topic
  end
end
