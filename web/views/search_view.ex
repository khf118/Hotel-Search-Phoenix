defmodule Kaligo.SearchView do
  use Kaligo.Web, :view

  def render("index.json", %{results: results}) do
  	results
  end

end
