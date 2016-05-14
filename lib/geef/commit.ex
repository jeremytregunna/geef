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

end
