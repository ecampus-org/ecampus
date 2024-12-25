defmodule Ecampus.QuizzesTest do
  use Ecampus.DataCase

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Quiz
  alias Ecampus.Quizzes.Question

  import Ecampus.QuizzesFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.QuizzesFixtures

  describe "quizzes" do
    @invalid_attrs %{description: nil, title: nil, questions_per_attempt: nil, lesson_id: nil}

    test "list_quizzes/0 returns all quizzes" do
      quiz = create_quiz()
      {:ok, %{list: list}} = Quizzes.list_quizzes()
      assert list == [quiz]
    end

    test "get_quiz/1 returns the quiz with given id" do
      quiz = create_quiz()
      assert Quizzes.get_quiz(quiz.id) == quiz
    end

    test "create_quiz/1 with valid data creates a quiz" do
      %{id: lesson_id} = create_lesson()

      valid_attrs = %{
        description: "some description",
        title: "some title",
        questions_per_attempt: 42,
        lesson_id: lesson_id
      }

      assert {:ok, %Quiz{} = quiz} = Quizzes.create_quiz(valid_attrs)
      assert quiz.description == valid_attrs.description
      assert quiz.title == valid_attrs.title
      assert quiz.questions_per_attempt == valid_attrs.questions_per_attempt
      assert quiz.lesson_id == valid_attrs.lesson_id
    end

    test "create_quiz/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_quiz(@invalid_attrs)
    end

    test "update_quiz/2 with valid data updates the quiz" do
      quiz = create_quiz()
      %{id: lesson_id} = create_lesson()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        questions_per_attempt: 43,
        lesson_id: lesson_id
      }

      assert {:ok, %Quiz{} = quiz} = Quizzes.update_quiz(quiz, update_attrs)
      assert quiz.description == update_attrs.description
      assert quiz.title == update_attrs.title
      assert quiz.questions_per_attempt == update_attrs.questions_per_attempt
      assert quiz.lesson_id == update_attrs.lesson_id
    end

    test "update_quiz/2 with invalid data returns error changeset" do
      quiz = create_quiz()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_quiz(quiz, @invalid_attrs)
      assert quiz == Quizzes.get_quiz(quiz.id)
    end

    test "delete_quiz/1 deletes the quiz" do
      quiz = create_quiz()
      assert {:ok, %Quiz{}} = Quizzes.delete_quiz(quiz)
      assert nil == Quizzes.get_quiz(quiz.id)
    end

    test "change_quiz/1 returns a quiz changeset" do
      quiz = create_quiz()
      assert %Ecto.Changeset{} = Quizzes.change_quiz(quiz)
    end
  end

  describe "questions" do
    @invalid_attrs %{type: nil, title: nil, subtitle: nil, grade: nil, show_correct_answer: nil}

    test "list_questions/0 returns all questions" do
      question = create_question()
      {:ok, %{list: list}} = Quizzes.list_questions()
      assert list == [question]
    end

    test "get_question/1 returns the question with given id" do
      question = create_question()
      assert Quizzes.get_question(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      %{id: quiz_id} = create_quiz()

      valid_attrs = %{
        type: :single,
        title: "some title",
        subtitle: "some subtitle",
        grade: 42,
        show_correct_answer: true,
        quiz_id: quiz_id
      }

      assert {:ok, %Question{} = question} = Quizzes.create_question(valid_attrs)
      assert question.type == valid_attrs.type
      assert question.title == valid_attrs.title
      assert question.subtitle == valid_attrs.subtitle
      assert question.grade == valid_attrs.grade
      assert question.show_correct_answer == valid_attrs.show_correct_answer
      assert question.quiz_id == valid_attrs.quiz_id
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      %{id: quiz_id} = create_quiz()
      question = create_question()

      update_attrs = %{
        type: :multiple,
        title: "some updated title",
        subtitle: "some updated subtitle",
        grade: 43,
        show_correct_answer: false,
        quiz_id: quiz_id
      }

      assert {:ok, %Question{} = question} = Quizzes.update_question(question, update_attrs)
      assert question.type == update_attrs.type
      assert question.title == update_attrs.title
      assert question.subtitle == update_attrs.subtitle
      assert question.grade == update_attrs.grade
      assert question.show_correct_answer == update_attrs.show_correct_answer
      assert question.quiz_id == update_attrs.quiz_id
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = create_question()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_question(question, @invalid_attrs)
      assert question == Quizzes.get_question(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = create_question()
      assert {:ok, %Question{}} = Quizzes.delete_question(question)
      assert nil == Quizzes.get_question(question.id)
    end

    test "change_question/1 returns a question changeset" do
      question = create_question()
      assert %Ecto.Changeset{} = Quizzes.change_question(question)
    end
  end

  defp create_lesson() do
    %{id: subject_id} = subject_fixture()
    lesson_fixture(%{subject_id: subject_id})
  end

  defp create_quiz() do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    quiz_fixture(%{lesson_id: lesson_id})
  end

  defp create_question() do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    %{id: quiz_id} = quiz_fixture(%{lesson_id: lesson_id})
    question_fixture(%{quiz_id: quiz_id})
  end
end
