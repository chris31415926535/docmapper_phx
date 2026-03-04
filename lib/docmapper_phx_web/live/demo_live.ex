defmodule DocmapperPhxWeb.DemoLive do
  use Phoenix.LiveView
  use DocmapperPhxWeb, :verified_routes
  alias DocmapperPhxWeb.HardcodedValues
  use Gettext, backend: DocmapperPhxWeb.Gettext

  # to extract and get translation files:
  # mix gettext.extract
  # mix gettext.merge priv/gettext
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
          "locale" => "en",
          "doctype" => "a Family Physician",
          "language" => "English"
        },
        params
      )

    Gettext.put_locale(full_params["locale"])

    # NOTE: DOC SEARCH HAPPENS HERE
    doctors = DocmapperPhx.Doctors.search_doctors(full_params)
    {:ok, doctors_json} = Jason.encode(doctors)

    # UPDATE SOCKET
    socket =
      socket
      |> assign(full_params: full_params)
      |> assign(docs: doctors)
      |> push_event("new-docs", %{data: doctors_json})

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <%= Gettext.with_locale(@full_params["locale"], fn -> %>
      <div class="docmapper-container" role="main">
        <.menu_bar />
        <.search_bar genders={HardcodedValues.genders()} full_params={@full_params} />

        <div id="docmap-container" class="docmap-container" phx-update="ignore">
          <div id="map" class="docmap" phx-hook="LeafletHook" />
          <div id="toast" class="hidden">More than 100 results found. Zoom in to see more!</div>
        </div>

        <div class="footer">
          <div>
            <p phx-click="change_locale">
              {gettext("Hand-crafted with ❤️ in Canada 🍁 by")}
              <a
                href="https://www.belangeranalytics.com"
                target="_blank"
                style="text-decoration: underline;"
              >
                Belanger Analytics {Gettext.get_locale()}
              </a>
            </p>
          </div>
        </div>
      </div>
    <% end) %>
    """
  end

  def menu_bar(assigns) do
    ~H"""
    <div class="menubar">
      <div class="header-title">🩺{gettext("DocMapper")}</div>
    </div>
    """
  end

  def search_bar(assigns) do
    ~H"""
    <div class="searchbar">
      <form phx-change="search-update">
        <div class="search-grid">
          <div class="doctype-left grid-left">
            <label for="doctype-select">{gettext("I'm looking for")}</label>
          </div>
          <div class="doctype-right">
            <select name="doctype" id="doctype-select" class="select">
              <%= for doc_type <- HardcodedValues.doc_types do %>
                <option value={doc_type} selected={@full_params["doctype"] == doc_type}>
                  {doc_type}
                </option>
              <% end %>
            </select>
          </div>
          <div class="language-left grid-left">
            <label for="language-select">{gettext("Who speaks")}</label>
          </div>
          <div class="language-right">
            <select name="language" id="language-select" class="select">
              <%= for language <- HardcodedValues.languages do %>
                <option value={language} selected={@full_params["language"] == language}>
                  {language}
                </option>
              <% end %>
            </select>
          </div>
          <div class="gender-left grid-left">
            <label for="gender-select">{gettext("And who identifies as")}</label>
          </div>
          <div class="gender-right">
            <select name="gender" id="gender-select" class="select">
              <option value="any" selected={@full_params["gender"] == "any"}>
                {gettext("Any Gender")}
              </option>
              <option value="Female" selected={@full_params["gender"] == "Female"}>
                {gettext("a Woman")}
              </option>
              <option value="Male" selected={@full_params["gender"] == "Male"}>
                {gettext("a Man")}
              </option>
              <option value="Non-Binary" selected={@full_params["gender"] == "Non-Binary"}>
                {gettext("Non-Binary")}
              </option>
              <!--
              <%= for gender <- @genders do %>
                <option value={gender.value} selected={@full_params["gender"] == gender.value}>
                  {gender.label}
                </option>
              <% end %>
              -->
            </select>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("change_locale", _unsigned_params, socket) do
    IO.puts("******************************")
    locale = socket.assigns.full_params["locale"]
    new_locale = if locale == "en", do: "fr", else: "en"

    IO.inspect(new_locale, label: "new_locale")

    new_params =
      socket.assigns.full_params
      |> Map.merge(%{"locale" => new_locale})
      |> IO.inspect(label: "new_params")

    socket =
      socket
      |> assign(full_params: new_params)
      |> push_patch(to: ~p"/test?#{new_params}")

    {
      :noreply,
      socket
    }
  end

  def handle_event("search-update", params, socket) do
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
    full_params =
      Map.merge(
        socket.assigns.full_params,
        map_boundaries_params
      )

    socket =
      socket
      |> push_patch(to: ~p"/test?#{full_params}")

    {:noreply, socket}
  end
end
