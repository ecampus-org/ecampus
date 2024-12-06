defmodule Ecampus.GroupsTest do
  use Ecampus.DataCase

  alias Ecampus.Groups

  describe "groups" do
    alias Ecampus.Groups.Group

    import Ecampus.GroupsFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Groups.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{description: "some description", title: "some title"}

      assert {:ok, %Group{} = group} = Groups.create_group(valid_attrs)
      assert group.description == "some description"
      assert group.title == "some title"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Group{} = group} = Groups.update_group(group, update_attrs)
      assert group.description == "some updated description"
      assert group.title == "some updated title"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end
end
