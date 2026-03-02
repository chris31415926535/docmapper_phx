defmodule DocmapperPhxWeb.DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    doctors = DocmapperPhx.Doctors.list_doctors()

    socket =
      socket
      |> assign(:count, 0)
      |> assign(:docs, doctors)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="docmapper-container">
      {inspect @docs}
      <.menu_bar />
      <.search_bar genders={[
        %{label: "a Man", value: "man"},
        %{label: "a Woman", value: "woman"},
        %{label: "Non-Binary", value: "non-binary"}
      ]} />
      <div class="doclist">
        Howdy!!! {@count}
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
        <span> I'm looking for a </span>
        <span>
          <select name="doctype">
            <option value="doctor">doctor</option>
          </select>
        </span>
        <span>who speaks</span>
        <span>
          <select name="language">
            <option value="english">English</option>
          </select>
        </span>
        <span>and who identifies as</span>
        <span>
          <select name="gender">
            <%= for op <- @genders do %>
              <option value={op.value}>{op.label}</option>
            <% end %>
          </select>
        </span>
      </form>
    </div>
    """
  end

  def handle_event("search-update", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_event("test", _unsigned_params, socket) do
    IO.puts("hello")

    {:noreply, socket |> assign(:count, socket.assigns.count + 1)}
  end
end
