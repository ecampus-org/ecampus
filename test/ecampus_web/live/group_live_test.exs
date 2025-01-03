defmodule EcampusWeb.GroupLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.GroupsFixtures
  import Ecampus.AccountsFixtures
  import Ecampus.SpecialitiesFixtures

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  defp create_group(_) do
    %{id: speciality_id} = speciality_fixture()
    group = group_fixture(%{speciality_id: speciality_id})
    %{group: group}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_group]

    test "lists all groups", %{conn: conn, group: group} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/groups")

      assert html =~ "Listing Groups"
      assert html =~ group.description
    end

    test "saves new group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/groups")

      assert index_live |> element("a", "New Group") |> render_click() =~
               "New Group"

      assert_patch(index_live, ~p"/admin/groups/new")

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#group-form", group: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/groups")

      html = render(index_live)
      assert html =~ "Group created successfully"
      assert html =~ "some description"
    end

    test "updates group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/groups")

      assert index_live |> element("#groups-#{group.id} a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(index_live, ~p"/admin/groups/#{group}/edit")

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#group-form", group: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/groups")

      html = render(index_live)
      assert html =~ "Group updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/groups")

      assert index_live |> element("#groups-#{group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#groups-#{group.id}")
    end
  end

  describe "Show" do
    setup [:create_group]

    test "displays group", %{conn: conn, group: group} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/groups/#{group}")

      assert html =~ "Show Group"
      assert html =~ group.description
    end

    test "updates group within modal", %{conn: conn, group: group} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/groups/#{group}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(show_live, ~p"/admin/groups/#{group}/show/edit")

      assert show_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#group-form", group: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/groups/#{group}")

      html = render(show_live)
      assert html =~ "Group updated successfully"
      assert html =~ "some updated description"
    end
  end
end
