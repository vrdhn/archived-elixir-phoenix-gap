defmodule Gap.Context.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Gap.Repo

  alias Gap.Schema.{User, Group, Member, Session}
  alias Gap.Policy.{Token, EMail, FakeUser}

  @doc """
  Creates a user with a fake name, generated token, and empty email hash.

  ## Examples

      iex> create_user()
      {:ok, %User{}}

      iex> create_user()
      {:error, %Ecto.Changeset{}}
  """
  def create_user do
    attrs = %{
      name: FakeUser.generate(),
      user_token: Token.create_user_token(),
      email_hash: nil
    }

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds a user by their plain text email.

  ## Examples

      iex> find_user_by_email("user@example.com")
      %User{}

      iex> find_user_by_email("nonexistent@example.com")
      nil
  """
  def find_user_by_email(email) when is_binary(email) do
    email_hash = EMail.hash_email(email)

    User
    |> where([u], u.email_hash == ^email_hash)
    |> Repo.one()
  end

  @doc """
  Finds a user by their authentication token.

  ## Examples

      iex> find_user_by_token("UA...")
      %User{}

      iex> find_user_by_token("invalid_token")
      nil
  """
  def find_user_by_token(token) when is_binary(token) do
    case Token.is_user_token(token) do
      true ->
        User
        |> where([u], u.user_token == ^token)
        |> Repo.one()

      false ->
        nil
    end
  end

  @doc """
  Regenerates the authentication token for a user.

  ## Examples

      iex> regenerate_user_token(user)
      {:ok, %User{}}

      iex> regenerate_user_token(user)
      {:error, %Ecto.Changeset{}}
  """
  def regenerate_user_token(%User{} = user) do
    new_token = Token.create_user_token()

    user
    |> User.changeset(%{user_token: new_token})
    |> Repo.update()
  end

  @doc """
  Updates a user's email with the provided plain text email.

  ## Examples

      iex> update_email_user(user, "new@example.com")
      {:ok, %User{}}

      iex> update_email_user(user, "invalid_email")
      {:error, %Ecto.Changeset{}}
  """
  def update_email_user(%User{} = user, email) when is_binary(email) do
    email_hash = EMail.hash_email(email)

    user
    |> User.changeset(%{email_hash: email_hash})
    |> Repo.update()
  end

  @doc """
  Creates a group with the given name.

  ## Examples

      iex> create_group("My Group")
      {:ok, %Group{}}

      iex> create_group("")
      {:error, %Ecto.Changeset{}}
  """
  def create_group(name) when is_binary(name) do
    attrs = %{
      name: name,
      group_token: Token.create_group_token()
    }

    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a member linking a user to a group with a name and role.

  ## Examples

      iex> create_member(user, group, "John Doe", "admin")
      {:ok, %Member{}}

      iex> create_member(user, group, "", "")
      {:error, %Ecto.Changeset{}}
  """
  def create_member(%User{id: user_id}, %Group{id: group_id}, name, role)
      when is_binary(name) and is_binary(role) and not is_nil(user_id) and not is_nil(group_id) do
    attrs = %{
      user_id: user_id,
      group_id: group_id,
      name: name,
      role: role
    }

    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds all groups that a user is a member of, returning groups with membership details.

  ## Examples

      iex> find_groups(user_id)
      [%{group: %Group{}, member: %Member{}}]

      iex> find_groups(nonexistent_user_id)
      []
  """
  def find_groups(user_id) when is_integer(user_id) do
    query =
      from m in Member,
        join: g in Group,
        on: m.group_id == g.id,
        where: m.user_id == ^user_id,
        select: %{group: g, member: m}

    Repo.all(query)
  end

  @doc """
  Updates or inserts a session with the given session_cookie and user_token.
  """
  def update_session_token(session_cookie, user_token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.insert(
      %Session{
        session_cookie: session_cookie,
        user_token: user_token,
        inserted_at: now,
        updated_at: now
      },
      on_conflict: [
        set: [
          user_token: user_token,
          updated_at: now
        ]
      ],
      conflict_target: :session_cookie
    )
  end

  @doc """
  Finds the user_token associated with the given session_cookie.
  """
  def find_token_from_session(session_cookie) do
    case Repo.get_by(Session, session_cookie: session_cookie) do
      nil -> nil
      session -> session.user_token
    end
  end
end
