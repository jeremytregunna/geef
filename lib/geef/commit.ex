defmodule Geef.Commit do
  use Geef

  @type t :: Object[type: :commit]

  @spec lookup(pid, Oid.t) :: Commit.t
  def lookup(repo, id) do
    Object.lookup(repo, id, :commit)
  end

  @spec tree_id(Object.t) :: Oid.t
  def tree_id(%Object{type: :commit, handle: handle}) do
    :geef_nif.commit_tree_id(handle)
  end

  @spec tree(t) :: {:ok, Tree.t} | {:error, any}
  def tree(%Object{type: :commit, handle: handle, repo: repo}) do
    Tree.lookup repo, :geef_nif.commit_tree_id(handle)
  end

  @spec tree!(t) :: Tree.t
  def tree!(commit = %Object{type: :commit}), do: tree(commit) |> Geef.assert_ok

  @spec create(pid, Signature.t, Signature.t, iolist, Oid.t, [Oid.t], [:proplists.property()]) :: {:ok, Oid.t} | {:error, term}
  def create(repo, author = %Signature{}, committer = %Signature{}, message, tree, parents, opts \\ []) do
    :geef_commit.create(repo, Signature.to_record(author), Signature.to_record(committer), message, tree, parents, opts)
  end

  @spec message(t) :: {:ok, String.t} | {:error, term}
  def message(commit = %Object{type: :commit}) do
    commit
    |> Object.to_record()
    |> :geef_commit.message()
  end

  @spec message!(t) :: String.t
  def message!(commit), do: message(commit) |> Geef.assert_ok

  @spec author(t) :: {:ok, Signature.t} | {:error, term}
  def author(commit = %Object{type: :commit}) do
    maybe_signature =
      commit
    |> Object.to_record()
    |> :geef_commit.author()
    case maybe_signature do
      {:ok, record} -> {:ok, Signature.from_record(record)}
      e -> e
    end
  end

  @spec author!(t) :: Signature.t
  def author!(commit), do: author(commit) |> Geef.assert_ok

  @spec committer(t) :: {:ok, Signature.t} | {:error, term}
  def committer(commit = %Object{type: :commit}) do
    maybe_signature =
      commit
    |> Object.to_record()
    |> :geef_commit.committer()
    case maybe_signature do
      {:ok, record} -> {:ok, Signature.from_record(record)}
      e -> e
    end
  end

  @spec committer!(t) :: Signature.t
  def committer!(commit), do: committer(commit) |> Geef.assert_ok

  @spec parent_count(t) :: {:ok, pos_integer} | {:error, term}
  def parent_count(commit = %Object{type: :commit}) do
    commit
    |> Object.to_record()
    |> :geef_commit.parent_count()
  end

  @spec parent_count!(t) :: pos_integer
  def parent_count!(commit), do: parent_count(commit) |> Geef.assert_ok

  @spec parent_id(t, non_neg_integer) :: {:ok, Oid.t} | {:error, term}
  def parent_id(commit = %Object{type: :commit}, n) do
    commit
    |> Object.to_record()
    |> :geef_commit.parent_id(n)
  end

  @spec parent_id!(t, non_neg_integer) :: Oid.t
  def parent_id!(commit, n), do: parent_id(commit, n) |> Geef.assert_ok

end
