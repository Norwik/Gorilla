# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

# Lock Context Module
defmodule Gorilla.LockContext do
  import Ecto.Query
  alias Gorilla.{Repo, Lock, LockMeta}

  # Get a lock map
  def new_lock(lock \\ %{}) do
    %{
      resource: lock.resource,
      owner: lock.owner,
      expire_at: DateTime.utc_now() |> DateTime.add(lock.expire_at, :second),
      token: Ecto.UUID.generate()
    }
  end

  # Get a lock meta map
  def new_meta(meta \\ %{}) do
    %{
      key: meta.key,
      value: meta.value,
      lock_id: meta.lock_id
    }
  end

  # Create a new lock
  def create_lock(attrs \\ %{}) do
    %Lock{}
    |> Lock.changeset(attrs)
    |> Repo.insert()
  end

  # Retrieve a lock by ID
  def get_lock_by_id(id) do
    Repo.get(Lock, id)
  end

  # Get lock by token
  def get_lock_by_token(token) do
    from(
      u in Lock,
      where: u.token == ^token
    )
    |> Repo.one()
  end

  # Get lock by resource
  def get_lock_by_resource(resource) do
    from(
      u in Lock,
      where: u.resource == ^resource
    )
    |> Repo.one()
  end

  # Get lock by resource and token
  def get_lock_by_token_resource(resource, token) do
    from(
      u in Lock,
      where: u.resource == ^resource,
      where: u.token == ^token
    )
    |> Repo.one()
  end

  # Update a lock
  def update_lock(lock, attrs) do
    lock
    |> Lock.changeset(attrs)
    |> Repo.update()
  end

  # Delete a lock
  def delete_lock(lock) do
    Repo.delete(lock)
  end

  # Retrieve all locks
  def get_locks() do
    Repo.all(Lock)
  end

  # Create a new lock meta attribute
  def create_lock_meta(lock_id, attrs \\ %{}) do
    changeset = LockMeta.changeset(%LockMeta{}, %{lock_id: lock_id} ++ attrs)
    Repo.insert(changeset)
  end

  # Retrieve a lock meta attribute by ID
  def get_lock_meta_by_id(id) do
    Repo.get(LockMeta, id)
  end

  # Update a lock meta attribute
  def update_lock_meta(lock_meta, attrs) do
    changeset = LockMeta.changeset(lock_meta, attrs)
    Repo.update(changeset)
  end

  # Delete a lock meta attribute
  def delete_lock_meta(lock_meta) do
    Repo.delete(lock_meta)
  end

  # Get lock meta by lock and key
  def get_lock_meta_by_key(lock_id, meta_key) do
    from(
      u in LockMeta,
      where: u.lock_id == ^lock_id,
      where: u.key == ^meta_key
    )
    |> Repo.one()
  end

  # Get lock metas
  def get_lock_metas(lock_id) do
    from(
      u in LockMeta,
      where: u.lock_id == ^lock_id
    )
    |> Repo.all()
  end
end
