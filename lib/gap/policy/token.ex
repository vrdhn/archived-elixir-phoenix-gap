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

  @usertokenprefix "UA"
  @grouptokenprefix "GT"

  @doc """
  Generate a token. Ussing UUID to ensure that token is globally unique
  """
  def create_user_token() do
    UniqueHash.hash(@usertokenprefix, Ecto.UUID.generate())
  end

  @doc """
  Check if a given string is a valid token
  """
  def is_user_token(token) do
    UniqueHash.is_prefix(token, @usertokenprefix)
  end

  @doc """
  Generate a token. Ussing UUID to ensure that token is globally unique
  """
  def create_group_token() do
    UniqueHash.hash(@grouptokenprefix, Ecto.UUID.generate())
  end

  @doc """
  Check if a given string is a valid token
  """
  def is_group_token(token) do
    UniqueHash.is_prefix(token, @grouptokenprefix)
  end
end
