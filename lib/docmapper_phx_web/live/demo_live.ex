defmodule DocmapperPhxWeb.DemoLive do
  use Phoenix.LiveView
  use DocmapperPhxWeb, :verified_routes
  alias DocmapperPhxWeb.HardcodedValues

  def mount(_params, _session, socket) do
    # doctors =
    #   DocmapperPhx.Doctors.search_doctors(%{
    #     gender: "any",
    #     language: "English",
    #     doctype: "a Family Physician"
    #   })

    socket =
      socket
      |> assign(:count, 0)

    # |> assign(:docs, doctors)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    IO.inspect(params, label: "params")

    full_params =
      Map.merge(
        %{
          "mapCenterLat" => 45.40977921176112,
          "mapCenterLon" => -75.6670323159904,
          "mapZoom" => 13,
          "neLat" => 45.455916332781364,
          "neLon" => -75.54455192353434,
          "swLat" => 45.36360437300808,
          "swLon" => -75.78951270844645,
          "gender" => "any",
          "lang" => "en",
          "doctype" => "a Family Physician",
          "language" => "English"
        },
        params
      )

    # NOTE: DOC SEARCH HAPPENS HERE
    doctors = DocmapperPhx.Doctors.search_doctors(full_params)
    {:ok, doctors_json} = Jason.encode(doctors)
    IO.inspect(doctors_json, label: "doctors_json")
    # UPDATE SOCKET
    socket =
      socket
      |> assign(full_params: full_params)
      |> assign(docs: doctors)
      |> push_event("new-docs", %{data: doctors_json})

    # TODO: PUSH NEW DATA TO CLIENT
    # |> push_event("update-map-boundaries", full_params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="docmapper-container">
      <.menu_bar />
      <.search_bar genders={HardcodedValues.genders()} full_params={@full_params} />

      <div id="docmap-container" class="docmap-container" phx-update="ignore">
        <div id="map" class="docmap" phx-hook="LeafletHook" />
      </div>

      <div class="footer">
        <div>
          <p>
            Hand-crafted with ❤️ in Canada 🍁 by
            <a href="https://www.belangeranalytics.com" target="_blank" style="text-decoration: underline;"> Belanger Analytics</a>
          </p>
        </div>
        <!--        <button phx-click="test">click me</button> -->
      </div>
    </div>
    """
  end

  def menu_bar(assigns) do
    ~H"""
    <div class="menubar">
      <div class="header-title">🩺DocMapper</div>
    </div>
    """
  end

  def search_bar(assigns) do
    ~H"""
    <div class="searchbar">
      <form phx-change="search-update">
        <table>
          <tr>
            <th>I'm looking for</th>
            <td>
              <select name="doctype">
                <%= for doc_type <- HardcodedValues.doc_types do %>
                  <option value={doc_type} selected={@full_params["doctype"] == doc_type}>
                    {doc_type}
                  </option>
                <% end %>
              </select>
            </td>
          </tr>
          <tr>
            <th>Who speaks</th>
            <td>
              <select name="language">
                <%= for language <- HardcodedValues.languages do %>
                  <option value={language} selected={@full_params["language"] == language}>
                    {language}
                  </option>
                <% end %>
              </select>
            </td>
          </tr>
          <tr>
            <th>And who identifies as</th>
            <td>
              <select name="gender">
                <%= for gender <- @genders do %>
                  <option value={gender.value} selected={@full_params["gender"] == gender.value}>
                    {gender.label}
                  </option>
                <% end %>
              </select>
            </td>
          </tr>
        </table>
      </form>
    </div>
    """
  end

  def handle_event("search-update", params, socket) do
    IO.inspect(params)

    full_params =
      Map.merge(
        socket.assigns.full_params,
        params
      )
      |> Map.delete("_target")
      |> Map.delete("_unused_doctype")
      |> Map.delete("_unused_gender")
      |> Map.delete("_unused_language")

    # search happens in handle_params
    socket =
      socket
      |> push_patch(to: ~p"/test?#{full_params}")

    {:noreply, socket}
  end

  def handle_event("test", _unsigned_params, socket) do
    IO.puts("hello")

    {:noreply, socket |> assign(:count, socket.assigns.count + 1)}
  end

  # handle event sent from Leaflet hook whenever map boundaries change (pan/zoom)
  # update query paramters in url
  def handle_event("map-boundaries-change", map_boundaries_params, socket) do
    # IO.inspect(map_boundaries_params, label: "Map boundaries changed:")

    full_params =
      Map.merge(
        socket.assigns.full_params,
        map_boundaries_params
      )

    IO.inspect(full_params, label: "new full parmas")
    # IO.inspect(map_boundaries_params, label: "new map boundaries")
    # IO.inspect(docs_json, label: "docs_json")

    socket =
      socket
      |> push_patch(to: ~p"/test?#{full_params}")

    {:noreply, socket}
  end
end
