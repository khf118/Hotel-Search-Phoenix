defmodule Kaligo.PageController do
  use Kaligo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
