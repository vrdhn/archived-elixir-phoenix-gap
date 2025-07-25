defmodule GapWeb.PlatHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use GapWeb, :html

  embed_templates "plat_html/*"
end
