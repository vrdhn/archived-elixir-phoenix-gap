defmodule Gap.Policy.UniqueHash do
  @moduledoc """
  Deterministically generates and validates base64-encoded SHA-256 hashes with prefixes.

  Format: "prefix:base64(hash(constant + prefix + text))"
  """

  @constant "f139caf3-9c1a-415c-999a-0800f6048422"
  @hash_length 44

  @doc """
  Returns a deterministic string with the given `prefix` and base64-encoded SHA-256 hash.
  """
  def hash(prefix, text) when is_binary(prefix) and is_binary(text) do
    input = "#{@constant}:#{prefix}:#{text}"

    hash = :crypto.hash(:sha256, input)
    encoded = Base.url_encode64(hash, padding: true)

    "#{prefix}:#{encoded}"
  end

  @doc """
  Checks if the string starts with the given prefix followed by a colon,
  and contains a 44-character base64 SHA-256 hash.
  """
  def is_prefix(string, prefix) when is_binary(string) and is_binary(prefix) do
    case String.split(string, ":", parts: 2) do
      [^prefix, hash_part] when byte_size(hash_part) == @hash_length ->
        # Valid base64 hash?
        Base.url_decode64(hash_part) != :error

      _ ->
        false
    end
  end
end
