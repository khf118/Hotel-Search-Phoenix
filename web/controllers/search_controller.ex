defmodule Kaligo.SearchController do
  use Kaligo.Web, :controller

  alias Kaligo.Search

  def index(conn, _params) do
    #Set the suppliers
    suppliers= %{
     "supplier1" => 'https://api.myjson.com/bins/2tlb8',
     "supplier2" => 'https://api.myjson.com/bins/42lok',
     "supplier3" => 'https://api.myjson.com/bins/15ktg'
    }
    
    #Set the cookie key
    _cookie_key= Enum.join([_params["destination"],_params["checkin"],_params["checkout"],_params["guests"]],"")
    conn= Plug.Conn.fetch_cookies(conn)
    
    #Check if we already have the search query result in the cookies
    if conn.cookies[_cookie_key]!=nil do
      map= Poison.decode!(elem(Base.decode64(conn.cookies[_cookie_key]),1))
      IO.inspect "retrieving from cookies"
    else
      #otherwise
      #in case we recieve the requested suppliers in the request, we fetch them into an array
      #otherwise we set _suppliers to all: all the keys from the dataset suppliers
      if _params["suppliers"]!=nil do
        _suppliers= String.split(_params["suppliers"],",")
      else
        _suppliers= Enum.map(suppliers, fn({key,value}) -> key end)
      end

      HTTPoison.start
      map = %{}
      #we map through the suppliers and call the endpoints one by one
      map = Enum.reduce _suppliers, %{}, fn x, map ->
        searchQuery= HTTPoison.get! suppliers[x]
        #foreach supplier we map through the results
        map= Enum.reduce elem(Poison.decode(searchQuery.body),1), map, fn y, acc2 ->
          #we check whether the processed item was already processed or not 
          # and if it's the case, we check if it has a better price
          if acc2[elem(y,0)]==nil or acc2[elem(y,0)]["price"]>elem(y,1) do
            Map.put(acc2, elem(y,0), %{"id" => elem(y,0), "price" => elem(y,1), "supplier" => x})
          else 
            acc2
          end
        end
      end
      #we format the results by removing the keys
      map= Enum.map(map, fn({key,value}) -> value end)
      #we save the query result in a cookie
      conn= put_resp_cookie(conn, _cookie_key, Base.encode64(Poison.encode!(map)),max_age: 5*60 )
    end
    render(conn, "index.json", results: map)
  end


end
