defmodule Kaligo.SearchController do
  use Kaligo.Web, :controller

  alias Kaligo.Search

  def index(conn, _params) do
    #validation
    if _params["destination"] == nil || _params["checkin"] == nil || _params["checkout"] == nil || _params["guests"] == nil do
      conn
      |> put_status(500)
      |> render("error.json", errors: "Missing required fields.")
    end

    #Set the suppliers
    suppliers= %{
     "supplier1" => 'https://api.myjson.com/bins/2tlb8',
     "supplier2" => 'https://api.myjson.com/bins/42lok',
     "supplier3" => 'https://api.myjson.com/bins/15ktg'
    }
    
    #Set the cache key
    _cache_key= Enum.join([_params["destination"],_params["checkin"],_params["checkout"],_params["guests"]],"")
    #Check if we already have the search query result in the cache
    if Cachex.get!(:searchcache, _cache_key)!=nil do
      map= Cachex.get!(:searchcache, _cache_key)
      IO.inspect "retrieving from cache"
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
        #check first that the requested supplier exist
        if suppliers[x] == nil do
          conn
            |> put_status(500)
            |> render("error.json", errors: "One of the submitted suppliers wasn't found.")
        end
        # we call the supplier api to retrieve the results
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
      #we save the query result in a cache
      Cachex.set!(:searchcache,  _cache_key , map, [ ttl: 5*60000 ])
    end
    conn
      |> render("index.json", results: map)
  end


end
