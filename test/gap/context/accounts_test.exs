defmodule Gap.Context.AccountsTest do
  use Gap.DataCase

  alias Gap.Context.Accounts
  alias Gap.Schema.{User, Group, Member, Session}
  alias Gap.Policy.{Token, EMail}

  describe "create_user/0" do
    test "creates a user with fake name, token, and empty email hash" do
      assert {:ok, %User{} = user} = Accounts.create_user()

      assert user.id != nil
      assert is_binary(user.name)
      assert user.name != ""
      assert Token.is_token(user.auth_token)
      assert user.email_hash == nil
      assert user.inserted_at != nil
      assert user.updated_at != nil
    end

    test "creates users with unique tokens" do
      assert {:ok, user1} = Accounts.create_user()
      assert {:ok, user2} = Accounts.create_user()

      assert user1.auth_token != user2.auth_token
    end
  end

  describe "find_user_by_email/1" do
    setup do
      {:ok, user} = Accounts.create_user()
      email = "test@example.com"
      {:ok, updated_user} = Accounts.update_email_user(user, email)

      %{user: updated_user, email: email}
    end

    test "finds user by plain text email", %{user: user, email: email} do
      found_user = Accounts.find_user_by_email(email)

      assert found_user.id == user.id
      assert found_user.email_hash == EMail.hash_email(email)
    end

    test "returns nil for non-existent email" do
      assert Accounts.find_user_by_email("nonexistent@example.com") == nil
    end

    test "returns nil for empty string" do
      assert Accounts.find_user_by_email("") == nil
    end

    test "is case insensitive" do
      {:ok, user} = Accounts.create_user()
      email = "Test@Example.com"
      {:error, _} = Accounts.update_email_user(user, email)

      assert Accounts.find_user_by_email("test@example.com") != nil
      assert Accounts.find_user_by_email("Test@Example.com") != nil
    end
  end

  describe "find_user_by_token/1" do
    setup do
      {:ok, user} = Accounts.create_user()
      %{user: user}
    end

    test "finds user by valid token", %{user: user} do
      found_user = Accounts.find_user_by_token(user.auth_token)

      assert found_user.id == user.id
      assert found_user.auth_token == user.auth_token
    end

    test "returns nil for non-existent token" do
      fake_token = Token.create_token()
      assert Accounts.find_user_by_token(fake_token) == nil
    end

    test "returns nil for invalid token format" do
      assert Accounts.find_user_by_token("invalid_token") == nil
      assert Accounts.find_user_by_token("") == nil
      # wrong prefix
      assert Accounts.find_user_by_token("EM123") == nil
    end
  end

  describe "regenerate_user_token/1" do
    setup do
      {:ok, user} = Accounts.create_user()
      %{user: user}
    end

    test "regenerates token for user", %{user: user} do
      original_token = user.auth_token

      assert {:ok, updated_user} = Accounts.regenerate_user_token(user)
      assert updated_user.auth_token != original_token
      assert Token.is_token(updated_user.auth_token)
      assert updated_user.id == user.id
    end

    test "invalidates old token", %{user: user} do
      original_token = user.auth_token

      assert {:ok, _updated_user} = Accounts.regenerate_user_token(user)
      assert Accounts.find_user_by_token(original_token) == nil
    end

    test "new token can be used to find user", %{user: user} do
      assert {:ok, updated_user} = Accounts.regenerate_user_token(user)

      found_user = Accounts.find_user_by_token(updated_user.auth_token)
      assert found_user.id == user.id
    end
  end

  describe "update_email_user/2" do
    setup do
      {:ok, user} = Accounts.create_user()
      %{user: user}
    end

    test "updates user email with plain text email", %{user: user} do
      email = "new@example.com"

      assert {:ok, updated_user} = Accounts.update_email_user(user, email)
      assert updated_user.email_hash == EMail.hash_email(email)
      assert updated_user.email_hash != EMail.hash_email("")
    end

    test "can update email multiple times", %{user: user} do
      email1 = "first@example.com"
      email2 = "second@example.com"

      assert {:ok, user1} = Accounts.update_email_user(user, email1)
      assert {:ok, user2} = Accounts.update_email_user(user1, email2)

      assert user2.email_hash == EMail.hash_email(email2)
      assert user2.email_hash != user1.email_hash
    end

    test "updated email can be used to find user", %{user: user} do
      email = "findable@example.com"

      assert {:ok, _updated_user} = Accounts.update_email_user(user, email)

      found_user = Accounts.find_user_by_email(email)
      assert found_user.id == user.id
    end

    test "enforces unique email constraint", %{user: user} do
      # Create another user with an email
      {:ok, user2} = Accounts.create_user()
      email = "duplicate@example.com"
      {:ok, _user2} = Accounts.update_email_user(user2, email)

      # Try to update first user with same email
      assert {:error, %Ecto.Changeset{}} = Accounts.update_email_user(user, email)
    end
  end

  describe "create_group/1" do
    test "creates group with valid name" do
      name = "Test Group"

      assert {:ok, %Group{} = group} = Accounts.create_group(name)
      assert group.name == name
      assert group.id != nil
      assert group.inserted_at != nil
      assert group.updated_at != nil
    end

    test "fails to create group with empty name" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_group("")
    end

    test "allows groups with same name" do
      name = "Duplicate Group"

      assert {:ok, group1} = Accounts.create_group(name)
      assert {:ok, group2} = Accounts.create_group(name)

      assert group1.id != group2.id
      assert group1.name == group2.name
    end
  end

  describe "create_member/4" do
    setup do
      {:ok, user} = Accounts.create_user()
      {:ok, group} = Accounts.create_group("Test Group")
      %{user: user, group: group}
    end

    test "creates member with valid data", %{user: user, group: group} do
      name = "John Doe"
      role = "admin"

      assert {:ok, %Member{} = member} = Accounts.create_member(user, group, name, role)
      assert member.name == name
      assert member.role == role
      assert member.user_id == user.id
      assert member.group_id == group.id
      assert member.id != nil
    end

    test "fails with empty name", %{user: user, group: group} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_member(user, group, "", "admin")
    end

    test "fails with empty role", %{user: user, group: group} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_member(user, group, "John", "")
    end

    test "enforces unique constraint on user_id and group_id", %{user: user, group: group} do
      # Create first member
      assert {:ok, _member1} = Accounts.create_member(user, group, "John", "admin")

      # Try to create second member with same user and group
      assert {:error, %Ecto.Changeset{}} = Accounts.create_member(user, group, "Jane", "member")
    end

    test "allows same user in different groups", %{user: user} do
      {:ok, group1} = Accounts.create_group("Group 1")
      {:ok, group2} = Accounts.create_group("Group 2")

      assert {:ok, _member1} = Accounts.create_member(user, group1, "John", "admin")
      assert {:ok, _member2} = Accounts.create_member(user, group2, "John", "member")
    end

    test "allows different users in same group", %{group: group} do
      {:ok, user2} = Accounts.create_user()
      {:ok, user3} = Accounts.create_user()

      assert {:ok, _member1} = Accounts.create_member(user2, group, "User2", "admin")
      assert {:ok, _member2} = Accounts.create_member(user3, group, "User3", "member")
    end
  end

  describe "find_groups/1" do
    setup do
      {:ok, user} = Accounts.create_user()
      {:ok, group1} = Accounts.create_group("Group 1")
      {:ok, group2} = Accounts.create_group("Group 2")
      {:ok, group3} = Accounts.create_group("Group 3")

      # User is member of group1 and group2, but not group3
      {:ok, member1} = Accounts.create_member(user, group1, "User in Group 1", "admin")
      {:ok, member2} = Accounts.create_member(user, group2, "User in Group 2", "member")

      %{
        user: user,
        group1: group1,
        group2: group2,
        group3: group3,
        member1: member1,
        member2: member2
      }
    end

    test "returns all groups user belongs to", %{user: user, group1: group1, group2: group2} do
      groups = Accounts.find_groups(user.id)

      assert length(groups) == 2

      group_ids = Enum.map(groups, & &1.group.id)
      assert group1.id in group_ids
      assert group2.id in group_ids
    end

    test "returns groups with member details", %{user: user, member1: member1, member2: member2} do
      groups = Accounts.find_groups(user.id)

      member_names = Enum.map(groups, & &1.member.name)
      member_roles = Enum.map(groups, & &1.member.role)

      assert member1.name in member_names
      assert member2.name in member_names
      assert member1.role in member_roles
      assert member2.role in member_roles
    end

    test "returns empty list for user with no groups" do
      {:ok, user_without_groups} = Accounts.create_user()

      assert Accounts.find_groups(user_without_groups.id) == []
    end

    test "returns empty list for non-existent user" do
      assert Accounts.find_groups(999_999) == []
    end

    test "does not return groups user is not a member of", %{user: user, group3: group3} do
      groups = Accounts.find_groups(user.id)

      group_ids = Enum.map(groups, & &1.group.id)
      refute group3.id in group_ids
    end
  end

  describe "integration tests" do
    test "complete user workflow" do
      # Create user
      assert {:ok, user} = Accounts.create_user()

      # Update email
      email = "integration@example.com"
      assert {:ok, user} = Accounts.update_email_user(user, email)

      # Find by email
      found_user = Accounts.find_user_by_email(email)
      assert found_user.id == user.id

      # Find by token
      found_user = Accounts.find_user_by_token(user.auth_token)
      assert found_user.id == user.id

      # Regenerate token
      old_token = user.auth_token
      assert {:ok, user} = Accounts.regenerate_user_token(user)
      assert user.auth_token != old_token

      # Old token should not work
      assert Accounts.find_user_by_token(old_token) == nil

      # New token should work
      found_user = Accounts.find_user_by_token(user.auth_token)
      assert found_user.id == user.id
    end

    test "complete group membership workflow" do
      # Create users and groups
      assert {:ok, user1} = Accounts.create_user()
      assert {:ok, user2} = Accounts.create_user()
      assert {:ok, group1} = Accounts.create_group("Engineering")
      assert {:ok, group2} = Accounts.create_group("Design")

      # Add user1 to both groups
      assert {:ok, _member1} = Accounts.create_member(user1, group1, "User 1 Engineer", "admin")
      assert {:ok, _member2} = Accounts.create_member(user1, group2, "User 1 Designer", "member")

      # Add user2 to only group1
      assert {:ok, _member3} = Accounts.create_member(user2, group1, "User 2 Engineer", "member")

      # Check user1 groups
      user1_groups = Accounts.find_groups(user1.id)
      assert length(user1_groups) == 2

      group_names = Enum.map(user1_groups, & &1.group.name)
      assert "Engineering" in group_names
      assert "Design" in group_names

      # Check user2 groups
      user2_groups = Accounts.find_groups(user2.id)
      assert length(user2_groups) == 1
      assert hd(user2_groups).group.name == "Engineering"
    end
  end

  describe "update_session_token/2 and find_token_from_session/1" do
    test "inserts new session and retrieves auth_token" do
      session_cookie = "cookie123"
      auth_token = "tokenABC"

      {:ok, _session} = Accounts.update_session_token(session_cookie, auth_token)
      assert Accounts.find_token_from_session(session_cookie) == auth_token
    end

    test "updates existing session's auth_token" do
      session_cookie = "cookie456"
      old_token = "oldToken"
      new_token = "newToken"

      # Insert old session
      {:ok, _session} = Accounts.update_session_token(session_cookie, old_token)
      assert Accounts.find_token_from_session(session_cookie) == old_token

      # Update it
      {:ok, _session} = Accounts.update_session_token(session_cookie, new_token)
      assert Accounts.find_token_from_session(session_cookie) == new_token
    end

    test "returns nil for non-existent session" do
      assert Accounts.find_token_from_session("nonexistent_cookie") == nil
    end

    test "upsert does not raise on duplicate session_cookie and updates auth_token" do
      session_cookie = "upsert_cookie"
      first_token = "token_one"
      updated_token = "token_two"

      # First insert
      {:ok, _session1} = Accounts.update_session_token(session_cookie, first_token)
      assert Accounts.find_token_from_session(session_cookie) == first_token

      # Attempt upsert (should update the token, not raise)
      {:ok, _session2} = Accounts.update_session_token(session_cookie, updated_token)
      assert Accounts.find_token_from_session(session_cookie) == updated_token
    end

    test "raises unique constraint error on duplicate session_cookie without upsert" do
      valid_attrs = %{session_cookie: "duplicate_cookie", auth_token: "token123"}

      # First insert should succeed
      {:ok, _session} =
        %Session{}
        |> Session.changeset(valid_attrs)
        |> Repo.insert()

      # Second insert should fail due to unique constraint
      {:error, changeset} =
        %Session{}
        |> Session.changeset(valid_attrs)
        |> Repo.insert()

      assert %{session_cookie: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
