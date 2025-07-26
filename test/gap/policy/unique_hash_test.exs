defmodule Gap.Policy.UniqueHashTest do
  use ExUnit.Case, async: true
  alias Gap.Policy.UniqueHash

  describe "hash/2" do
    test "generates a deterministic 44-char base64 hash with prefix" do
      result = UniqueHash.hash("user", "alice@example.com")
      assert String.starts_with?(result, "user:")
      assert byte_size(result) == byte_size("user:") + 44
    end

    test "hash is deterministic for same input" do
      h1 = UniqueHash.hash("user", "same-input")
      h2 = UniqueHash.hash("user", "same-input")
      assert h1 == h2
    end

    test "hash changes when prefix changes" do
      h1 = UniqueHash.hash("user", "example")
      h2 = UniqueHash.hash("admin", "example")
      refute h1 == h2
    end

    test "hash changes when text changes" do
      h1 = UniqueHash.hash("user", "a")
      h2 = UniqueHash.hash("user", "b")
      refute h1 == h2
    end
  end

  describe "is_prefix/2" do
    test "returns true for valid prefix and hash" do
      token = UniqueHash.hash("user", "alice@example.com")
      assert UniqueHash.is_prefix(token, "user")
    end

    test "returns false for incorrect prefix" do
      token = UniqueHash.hash("user", "bob@example.com")
      refute UniqueHash.is_prefix(token, "admin")
    end

    test "returns false for malformed input" do
      assert UniqueHash.is_prefix("invalidinput", "user") == false
      assert UniqueHash.is_prefix("user:too_short", "user") == false
      assert UniqueHash.is_prefix("user:not@base64!", "user") == false
    end
  end
end
