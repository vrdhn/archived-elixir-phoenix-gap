defmodule Gap.Policy.FakeName do
  @moduledoc """
  Generates fake names in adjective-noun format.
  Uses colors, emotions, motion, and other descriptive words as adjectives,
  combined with animals and plants as nouns.
  """

  @adjectives ~w[
    red blue green gold pink gray cyan teal lime mint coral amber jade ruby azure ivory
    happy glad jolly merry sunny bright cheery peppy upbeat bubbly giddy elated joyful bliss zesty keen
    blue down glum moody somber weepy sulky dreary misty foggy dim dull heavy quiet still soft
    quick fast slow swift brisk fleet rapid agile nimble zippy hasty snappy speedy flying dashing racing
    tiny small mini wee petite micro grand vast mega jumbo huge big
    smooth rough silky fuzzy bumpy glossy matte velvety crisp fluffy
    warm cool hot cold frosty snowy sunny cloudy breezy misty
    striped dotted round square curved spiral wavy zigzag twisted straight
    young old new fresh ancient modern early late dawn dusk
    quiet loud soft musical whispery humming chirpy melodic rhythmic gentle
    crystal silver bronze copper pearl marble silk cotton wool linen
    cosmic stellar lunar solar starry nebula orbit comet galaxy meteor
    bold shy wise wild calm fierce proud noble brave sly clever sharp strong light
  ]

  @nouns ~w[
    cat dog fox owl bee ant bat elk cod eel hawk dove crow jay wren duck goose seal deer
    bear wolf lynx otter mole mouse rat hare lamb goat pig ox yak pony cub pup kit joey calf
    oak elm ash fir pine palm moss fern vine sage mint basil thyme rose lily iris daisy tulip pansy
    poppy peony aster clover cedar birch maple willow bamboo lotus orchid jasmine lavender reed grass herb
    bloom bud leaf stem root seed berry bean pea
    stone rock sand clay snow ice rain wind cloud star moon sun
    button coin key bell shell pebble feather ribbon thread bead
    apple orange berry nut honey sugar spice tea cocoa vanilla
    note chord beat tune song verse melody rhythm harmony echo
    hill valley creek pond brook ridge meadow grove field glen
    brush quill lens prism wheel gear spring bolt thread weave
    blossom snowflake raindrop sunbeam breeze frost dew mist shade glow
  ]

  @doc """
  Generates a random fake name in the format "Adjective Noun".

  ## Examples

      iex> FakeName.generate()
      "Happy Fox"
      
      iex> FakeName.generate()
      "Swift Oak"
  """
  def generate do
    adjective = @adjectives |> Enum.random() |> String.capitalize()
    noun = @nouns |> Enum.random() |> String.capitalize()

    "#{adjective} #{noun}"
  end
end
