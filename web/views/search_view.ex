defmodule Kaligo.SearchView do
  use Kaligo.Web, :view

  def render("index.json", %{results: results}) do
  	results
  end

  def render("error.json", %{errors: message}) do
  	%{errors: message}
  end

end
