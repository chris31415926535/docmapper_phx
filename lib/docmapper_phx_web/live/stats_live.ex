defmodule DocmapperPhxWeb.StatsLive do
  use Phoenix.LiveView
  use DocmapperPhxWeb, :verified_routes
  alias DocmapperPhxWeb.HardcodedValues
  alias DocmapperPhx.Doctors
  use Gettext, backend: DocmapperPhxWeb.Gettext

  def mount(_params, _session, socket) do
    peer_data = get_connect_info(socket, :peer_data)
    x_headers = get_connect_info(socket, :x_headers)
    IO.inspect(peer_data, label: "peer_data")
    IO.inspect(x_headers, label: "x_headers")
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    full_params =
      Map.merge(
        %{
          "locale" => "en",
          "language" => "English"
        },
        params
      )

    Gettext.put_locale(full_params["locale"])

    # NOTE: DOC SEARCH HAPPENS HERE
    doc_stats = Doctors.language_stats(full_params)

    socket =
      socket
      |> assign(full_params: full_params)
      |> assign(doc_stats: doc_stats)
      |> push_event("new-stats", doc_stats)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <head>
      <script src="https://cdn.plot.ly/plotly-3.4.0.min.js" charset="utf-8">
      </script>
    </head>
    <%= Gettext.with_locale(@full_params["locale"], fn -> %>
      <div class="stats-grid">
        <DocmapperPhxWeb.MapLive.menu_bar />
        <div class="stats-search-bar">
        <form phx-change="search-update">
        <label for="language"><h1>Tell me about physicians who speak:</h1> </label>
            <select name="language" id="language-select" class="select">
              <option value="English" selected={@full_params["language"] == "English"}>
                {gettext("English")}
              </option>

              <option value="French" selected={@full_params["language"] == "French"}>
                {gettext("French")}
              </option>

              <option value="----------" disabled>--------------------</option>
              <%= for language <- HardcodedValues.languages do %>
                <option value={language} selected={@full_params["language"] == language}>
                  {Gettext.gettext(DocmapperPhxWeb.Gettext, language)}
                </option>
              <% end %>
            </select>
          </form>
        </div>

        <div class="data-grid">
          <div class="stats-num-container">
            <h2>Overall</h2>
            <div class="stats-num-box">
              <div class="stats-big-num">{@doc_stats.total_n}</div>
              <div>Physicians Speak {@full_params["language"]}</div>
            </div>
            <div class="stats-num-box">
              <div class="stats-big-num">{@doc_stats.total_pct}</div>
              <div>of All Physicians in Ontario Speak {@full_params["language"]}</div>
            </div>
          </div>

          <div class="stats-num-container">
            <h2>Family Physicians</h2>
            <div class="stats-num-box">
              <div class="stats-big-num">{@doc_stats.famdoc_pct}</div>
              <div>of {@full_params["language"]}-speakers are Family Physicians</div>
            </div>

            <div class="stats-num-box">
              <div class="stats-big-num">{@doc_stats.famdocs_speak_pct}</div>
              <div>of Family Physicians speak {@full_params["language"]}</div>
            </div>
          </div>
          <div class="stats-num-container">
            <h2>Gender</h2>
            <div class="stats-gender-box">
              <div class="stats-gender-num">{@doc_stats.gender_man_pct}</div>
              <div>of {@full_params["language"]}-speakers Identified as Male</div>
            </div>
            <div class="stats-gender-box">
              <div class="stats-gender-num">{@doc_stats.gender_woman_pct}</div>
              <div>of {@full_params["language"]}-speakers Identified as Female</div>
            </div>
            <div class="stats-gender-box">
              <div class="stats-gender-num">{@doc_stats.gender_nonbinary_pct}</div>
              <div>of {@full_params["language"]}-speakers Identified as Non-Binary</div>
            </div>
          </div>
        </div>

        <div class="plot-grid">
          <div id="stats-specialties-container" class="stats-specialties-container">
            <div class="stat-plot-title-container">
              <h2>Top 5 Specialties for {@full_params["language"]} Speakers</h2>
            </div>
            <div id="specialties-plot-container" i style="height:300px; width: 100%;">
              <div id="specialties-plot" phx-hook=".SpecialtiesPlot" style="height:100%;width:100%;">
                <script
                  :type={Phoenix.LiveView.ColocatedHook}
                  name=".SpecialtiesPlot"
                >
                  export default {
                    mounted() {
                      this.handleEvent("new-stats", stats => {
                        el = document.getElementById("specialties-plot")
                        Plotly.newPlot(
                          el,
                          [{x: stats.specialties_n.count, y: stats.specialties_n.specialty, type: 'bar', orientation: 'h'}],
                          {
                            margin: { r: 0, t: 40, b: 20},
                            yaxis: {automargin: true},
                            autosize: true
                          },
                          {
                            responsive: true
                          }
                        ) // end Plotly.newPlot()
                      }) // end handleEvent("new-stats")
                    }// end mounted()
                  } // end default 
                </script>
              </div>
            </div>
          </div>

          <div id="lhin-plot-container" style="lhin-plot-container" >
            <div
              id="lhin-plot"
              class="lhin-plot"
              phx-hook="LeafletLhinsHook"
              phx-update="ignore"
            >
            </div>
          </div>
        </div>
        <DocmapperPhxWeb.MapLive.footer />
      </div>
    <% end) %>
    """
  end

  def menu_bar(assigns) do
    ~H"""
    <div class="menubar">
      <div class="header-title">🩺{gettext("DocMapper")}</div>
      <div class="lang-select" phx-click="change_locale"><a href="#">{gettext("FR")}</a></div>
    </div>
    """
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
      |> push_patch(to: ~p"/stats?#{full_params}")

    {:noreply, socket}
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
      |> push_patch(to: ~p"/stats?#{new_params}")

    {
      :noreply,
      socket
    }
  end
end
