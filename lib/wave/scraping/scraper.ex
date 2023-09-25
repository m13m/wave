defmodule Wave.Scraping.Scraper do
  @moduledoc """
  Documentation for `Scraper`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Scraper.hello()
      :world

  """
  def work() do
    1..5
    |> Enum.random()
    |> IO.inspect()
    |> :timer.seconds()
    |> Process.sleep()
  end

  def online?("google.com"), do: false

  def online?(_), do: true
end
