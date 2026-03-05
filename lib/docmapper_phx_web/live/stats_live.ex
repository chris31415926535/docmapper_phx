defmodule DocmapperPhxWeb.StatsLive do
  use Phoenix.LiveView
  use DocmapperPhxWeb, :verified_routes
  alias DocmapperPhxWeb.HardcodedValues
  alias DocmapperPhx.Doctors
  use Gettext, backend: DocmapperPhxWeb.Gettext

  def mount(_params, _session, socket) do
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
      <DocmapperPhxWeb.MapLive.menu_bar />
      <form phx-change="search-update">
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

      <div>
        <div>{@doc_stats.total_n} Physicians Speak {@full_params["language"]}</div>
        <div>{@doc_stats.total_pct} of All Physicians in Ontario</div>
      </div>

      <div class="stats-num-box">
        <div class="stats-big-num">{@doc_stats.famdoc_pct}</div>
        <div>of {@full_params["language"]}-speakers are Family Physicians</div>
      </div>

      <div class="stats-num-box">
        <div class="stats-big-num">{@doc_stats.famdocs_speak_pct}</div>
        <div>of Family Physicians speak {@full_params["language"]}</div>
      </div>

      <div id="stats-specialties-container" class="stats-specialties-container">
<div>
<h2>
Top 5 Specialties for {@full_params["language"]} Speakers</h2>
</div>
      <div id="specialties-plot-container"i style="height:300px; width: 100%;">
        <div id="specialties-plot" phx-hook=".SpecialtiesPlot" style="height:100%;width:100%;">
          <script
            :type={Phoenix.LiveView.ColocatedHook}
            name=".SpecialtiesPlot"
          >
                          export default {
                            mounted() {
                            console.log("hell yeah!")
                  //              	TESTER = document.getElementById('tester');
                  //          Plotly.newPlot( TESTER, [{
                  //          x: [1, 2, 3, 4, 5],
                  //          y: [1, 2, 4, 8, 16] }], {
                  //          margin: { t: 0 } } );

                            this.handleEvent("new-stats", stats => {
                            el = document.getElementById("specialties-plot")
            Plotly.newPlot(el,
            [{x: stats.specialties_n.count, y: stats.specialties_n.specialty, type: 'bar', orientation: 'h'}],
            {
//            title: {
//              text: `Top 5 Specialties for ${stats.language} Speakers`,
//              font: {
//                size: 24,
//                weight: 'bold'
//              }
//            },
            margin: { r: 0, t: 40, b: 20},
            yaxis: {automargin: true},
             autosize: true
             },
             {
             responsive: true
             }
             )
                              console.log(stats);
                            })
                            }// end mounted()

                          } 
                      
                
          </script>
        </div>
        </div>
      </div>

      <div>
        <pre>
    {inspect(@doc_stats, pretty: true)}
    </pre>
      </div>
      <DocmapperPhxWeb.MapLive.footer />
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
