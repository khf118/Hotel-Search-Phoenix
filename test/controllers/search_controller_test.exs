defmodule Kaligo.SearchControllerTest do
  use Kaligo.ConnCase

  alias Kaligo.Search
  @valid_attrs %{description: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, search_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

end
