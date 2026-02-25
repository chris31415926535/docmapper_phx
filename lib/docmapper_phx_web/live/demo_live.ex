defmodule DocmapperPhxWeb.DemoLive do

use Phoenix.LiveView
def mount(_params, _session, socket) do
	socket = assign(socket, :count, 0)
	{:ok, socket}
end

def render(assigns) do
	~H"""
		<.menu_bar />
		<.search_bar />
		Howdy!!! {@count}
	<button phx-click="test">click me</button>
	"""
end


def menu_bar(assigns) do
	~H"""
	<div> sadfkjh</div>
	"""
end


def search_bar(assigns) do
~H"""
<div>
I'm looking for a ... who speaks ...
</div>
	
"""

end


def handle_event("test", _unsigned_params, socket) do
	IO.puts("hello")

	{:noreply, socket |> assign(:count, socket.assigns.count + 1)}
end
	
	

end	

			
