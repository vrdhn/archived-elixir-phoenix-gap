defmodule Gap.Policy.EMailTest do
  use ExUnit.Case, async: true

  alias Gap.Policy.EMail

  describe "hash_email/1 and is_email/1 black-box behavior" do
    test "hash_email returns a non-empty string containing colon" do
      email = "alice@example.com"
      token = EMail.hash_email(email)

      assert is_binary(token)
      assert String.contains?(token, ":")
      # sanity check: not empty or trivial
      assert byte_size(token) > 20
    end

    test "is_email returns true for a valid hashed email token" do
      email = "bob@example.com"
      token = EMail.hash_email(email)

      assert EMail.is_email(token)
    end

    test "is_email returns false for invalid inputs" do
      assert EMail.is_email("") == false
      assert EMail.is_email("randomstring") == false
      assert EMail.is_email("prefix:short") == false
      assert EMail.is_email("token:!!!notbase64===") == false
    end

    test "hash_email returns different tokens for different emails" do
      token1 = EMail.hash_email("user1@example.com")
      token2 = EMail.hash_email("user2@example.com")

      refute token1 == token2
    end

    test "hash_email returns same token for same email (deterministic)" do
      email = "same@example.com"
      token1 = EMail.hash_email(email)
      token2 = EMail.hash_email(email)

      assert token1 == token2
    end
  end

  @snapshots %{
    "alice.smith@gmail.com" => "EM:yUmYkeO9-xN8cSMLG1vsCdKafSCIGMW9j5e64TtW00w=",
    "bob.jones@yahoo.com" => "EM:Cm6AMy3vsCzBBYvDBwvH3zIAmIsg20kR2x-2cXs8tKc=",
    "carol.white@outlook.com" => "EM:ecUBp1ekhj7Z7VbKgQaJ3B3L-o3dihsaNhQ1bOHRDu4=",
    "david.brown@hotmail.com" => "EM:1pW0q7E7lDhikXlqlccmDGyi8C8SsY5Z26_Jbs-QJ0E=",
    "eva.johnson@protonmail.com" => "EM:jLh92dASoKnbAdvMPOERp-uPhUGWKpFA4r-McDjYyUI=",
    "frank.wilson@icloud.com" => "EM:mA8d74gMOrVhmz8Z-K4RDiNKB3OFyx3dnO-Dd3BH_DI=",
    "grace.lee@company.com" => "EM:FUZsr655SWoR59IQKNFcrsZuz6BkH4LRFvXRZ4RAg94=",
    "henry.martin@example.org" => "EM:k6L_Ym7xoBpiepxquZOTMBAXOpw68T9wEsyZNoYr6OY=",
    "irene.evans@university.edu" => "EM:cuOA3kkKGRdjxcSJl2-aJZyV3X4wXGGp32oFGJEQtX0=",
    "jack.moore@startup.io" => "EM:Mm8M6kzJ0ktHfAVai2EQJQnRxlL6ubxK2reV4VT7EXw="
  }

  test "hash_email output matches snapshot map" do
    for {email, expected_hash} <- @snapshots do
      actual_hash = EMail.hash_email(email)
      assert actual_hash == expected_hash, "Hash for #{email} changed!"
    end
  end
end
