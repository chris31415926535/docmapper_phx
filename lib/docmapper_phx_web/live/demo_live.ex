defmodule DocmapperPhxWeb.DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :count, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="docmapper-container">
      <.menu_bar />
      <.search_bar />

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
      I'm looking for a ... who speaks ...
    </div>
    """
  end

  def handle_event("test", _unsigned_params, socket) do
    IO.puts("hello")

    {:noreply, socket |> assign(:count, socket.assigns.count + 1)}
  end
end
