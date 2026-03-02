defmodule DocmapperPhxWeb.DemoLive do
  use Phoenix.LiveView
  alias DocmapperPhxWeb.HardcodedValues

  def mount(_params, _session, socket) do
    doctors =
      DocmapperPhx.Doctors.search_doctors(%{
        gender: "any",
        language: "English",
        doctype: "a Family Physician"
      })

    socket =
      socket
      |> assign(:count, 0)
      |> assign(:docs, doctors)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="docmapper-container">
      <.menu_bar />
      <.search_bar genders={HardcodedValues.genders()} />
      <div class="doclist">
        Howdy!!! {@count}

        {inspect(length(@docs))}
      </div>

      <div id="docmap-container" class="docmap-container" phx-update="ignore">
        <div id="map" class="docmap" phx-hook="MapHook" />
      </div>

      <div class="footer">
        <button phx-click="test">click me</button>
      </div>
    </div>
    """
  end

  def menu_bar(assigns) do
    ~H"""
    <div class="menubar">MENU SHOULD BE ON ITS OWN LINE</div>
    """
  end

  def search_bar(assigns) do
    ~H"""
    <div class="searchbar">
      <form phx-change="search-update">
        <div>
          <span> I'm looking for </span>
          <span>
            <select name="doctype">
              <%= for doc_type <- HardcodedValues.doc_types do %>
                <option value={doc_type}>{doc_type}</option>
              <% end %>
            </select>
          </span>
        </div>
        <div>
          <span>Who speaks</span>
          <span>
            <select name="language">
              <%= for language <- HardcodedValues.languages do %>
                <option value={language}>{language}</option>
              <% end %>
            </select>
          </span>
        </div>
        <div>
          <span>And who identifies as</span>
          <span>
            <select name="gender">
              <%= for op <- @genders do %>
                <option value={op.value}>{op.label}</option>
              <% end %>
            </select>
          </span>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("search-update", params, socket) do
    IO.inspect(params)
    doctors = DocmapperPhx.Doctors.search_doctors(params)

    {:noreply, assign(socket, docs: doctors)}
  end

  def handle_event("test", _unsigned_params, socket) do
    IO.puts("hello")

    {:noreply, socket |> assign(:count, socket.assigns.count + 1)}
  end
end
