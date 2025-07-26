defmodule Gap.Policy.EMail do
  @moduledoc """
  We store a deterministic hash of email, not plain text.
  That way, we are not afraid of a leak of data.

  """
  alias Gap.Policy.UniqueHash

  @tokenprefix "EM"

  @doc """
  hash a email.
  """
  def hash_email(email) do
    UniqueHash.hash(@tokenprefix, normalize_email(email))
  end

  @doc """
  normalize a email, trim and lowercae for now
  """
  def normalize_email(email) do
    email |> String.trim() |> String.downcase()
  end

  @doc """
  Check if a given string is a valid token
  """
  def is_email(token) do
    UniqueHash.is_prefix(token, @tokenprefix)
  end
end
