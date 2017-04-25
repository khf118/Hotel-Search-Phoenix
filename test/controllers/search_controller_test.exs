defmodule Kaligo.SearchControllerTest do
  use Kaligo.ConnCase

  alias Kaligo.Search

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "Test search with all suppliers", %{conn: conn} do
    conn = get conn, search_path(conn, :index, %{destination: "aaaaa country",checkin: "12-12-2017", checkout: "12-01-2018", guests: "3"})
    assert json_response(conn, 200) == [%{"id" => "abcd", "price" => 299.9, "supplier" => "supplier2"}, %{"id" => "defg", "price" => 320.49, "supplier" => "supplier3"}, %{"id" => "mnop", "price" => 288.3, "supplier" => "supplier1"}]
  end

  test "Test search with limited suppliers", %{conn: conn} do
    conn = get conn, search_path(conn, :index, %{destination: "a country",checkin: "12-12-2017", checkout: "12-01-2018", guests: "3", suppliers: "supplier1,supplier2"})
    assert json_response(conn, 200) == [%{"id" => "abcd", "price" => 299.9, "supplier" => "supplier2"}, %{"id" => "defg", "price" => 403.22, "supplier" => "supplier1"}, %{"id" => "mnop", "price" => 288.3, "supplier" => "supplier1"}]
  end

end
