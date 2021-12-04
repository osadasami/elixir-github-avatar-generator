defmodule ElixirIdenticon do
  def main(input) do
    input
    |> hash
    |> color
    |> grid
    |> odd_squares
    |> pixel_map
    |> image
    |> save(input)
  end

  def hash(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %ElixirIdenticon.Image{hex: hex}
  end

  def color(%ElixirIdenticon.Image{hex: [r, g, b | _]} = image) do
    %ElixirIdenticon.Image{image | color: {r, g, b}}
  end

  def grid(%ElixirIdenticon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror/1)
      |> List.flatten()
      |> Enum.with_index()

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def mirror(row) do
    [first, second | _] = row
    row ++ [second, first]
  end

  def odd_squares(%ElixirIdenticon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _} ->
        rem(code, 2) == 0
      end)

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def pixel_map(%ElixirIdenticon.Image{grid: grid} = image) do
    grid =
      Enum.map(grid, fn {_, index} ->
        left = div(index, 5) * 50
        top = rem(index, 5) * 50

        top_left = {top, left}
        bottom_right = {top + 50, left + 50}

        {top_left, bottom_right}
      end)

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def image(%ElixirIdenticon.Image{color: color, grid: grid}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(grid, fn {top_left, bottom_right} ->
      :egd.filledRectangle(image, top_left, bottom_right, fill)
    end)

    :egd.render(image)
  end

  def save(image, filename) do
    File.write("images/#{filename}.jpg", image)
  end
end
