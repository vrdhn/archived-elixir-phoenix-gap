defmodule Gap.Policy.Token do
  @moduledoc """
  Should you put the user id directly in the token, even if it's encrypted and
  signed. No, the theory being that anything thatis unchangable in the data
  base, should not leave the code.

  Instead we put a token in the cookie. To invalidate existing user sessions, we
  can regenreate the token.

  In the database we store token as a string

  """
  alias Gap.Policy.UniqueHash

  @tokenprefix "UA"

  @doc """
  Generate a token. Ussing UUID to ensure that token is globally unique
  """
  def create_token() do
    UniqueHash.hash(@tokenprefix, Ecto.UUID.generate())
  end

  @doc """
  Check if a given string is a valid token
  """
  def is_token(token) do
    UniqueHash.is_prefix(token, @tokenprefix)
  end
end
