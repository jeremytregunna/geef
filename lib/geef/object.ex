defmodule Geef.Object do
  @behaviour Access

  alias Geef.Object
  alias Geef.Tree

  require Record

  defstruct type: nil, id: nil, handle: nil, repo: nil

  def to_record(%Geef.Object{type: type, id: id, handle: handle}) do
    {:geef_object, type, id, handle}
  end

  def lookup(repo, id) do
    case :geef_repo.lookup_object(repo, id) do
      {:ok, type, handle} ->
        {:ok, %Geef.Object{type: type, id: id, handle: handle, repo: repo}}
      error ->
        error
    end
  end

  def lookup(repo, id, type) do
    case lookup(repo, id) do
      {:ok, obj = %Geef.Object{type: ^type}} ->
        {:ok, obj}
      {:ok, _obj} ->
        {:error, :type_mismatch}
      error ->
        error
    end
  end

  def lookup!(repo, id) do
    case lookup(repo, id) do
      {:ok, obj} ->
        obj
      {:error, err} ->
        raise err
    end
  end

  def fetch(tree = %Object{type: :tree}, key) when is_number(key) do
    Tree.nth(tree, key)
  end

  def fetch(tree = %Object{type: :tree}, key) do
    Tree.get(tree, key)
  end

  def get(tree = %Object{type: :tree}, key, default) do
    case fetch(tree, key) do
      {:ok, entry} -> entry
      {:error, _} -> default
    end
  end

  def get_and_update(_tree, _key, _fun) do
    raise ArgumentError, message: "Git data is immutable"
  end

  def pop(_tree, _key) do
    raise ArgumentError, message: "Git data is immutable"
  end
end
