# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

# Lock Context Module
defmodule Gorilla.LockContext do
  import Ecto.Query
  alias Gorilla.{Repo, LockMeta, Lock}

  # Get a lock map
  def new_lock(lock \\ %{}) do
    %{
      name: lock.name,
      owner: lock.owner,
      expire_at: lock.expire_at,
      uuid: Ecto.UUID.generate()
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
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  # Count all locks
  def count_locks(country, gender) do
    case {country, gender} do
      {country, gender} when country != "" and gender != "" ->
        from(u in Client,
          select: count(u.id),
          where: u.country == ^country,
          where: u.gender == ^gender
        )
        |> Repo.one()

      {country, gender} when country == "" and gender == "" ->
        from(u in Client,
          select: count(u.id)
        )
        |> Repo.one()

      {country, gender} when country != "" and gender == "" ->
        from(u in Client,
          select: count(u.id),
          where: u.country == ^country
        )
        |> Repo.one()

      {country, gender} when country == "" and gender != "" ->
        from(u in Client,
          select: count(u.id),
          where: u.gender == ^gender
        )
        |> Repo.one()
    end
  end

  # Retrieve a lock by ID
  def get_lock_by_id(id) do
    Repo.get(Client, id)
  end

  # Get lock by uuid
  def get_lock_by_uuid(uuid) do
    from(
      u in Client,
      where: u.uuid == ^uuid
    )
    |> Repo.one()
  end

  # Get lock by username
  def get_lock_by_username(username) do
    from(
      u in Client,
      where: u.username == ^username
    )
    |> Repo.one()
  end

  # Update a lock
  def update_lock(lock, attrs) do
    lock
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  # Delete a lock
  def delete_lock(lock) do
    Repo.delete(lock)
  end

  # Retrieve all locks
  def get_locks() do
    Repo.all(Client)
  end

  # Retrieve locks
  def get_locks(country, gender, offset, limit) do
    case {country, gender, offset, limit} do
      {country, gender, offset, limit} when country != "" and gender != "" ->
        from(u in Client,
          where: u.country == ^country,
          where: u.gender == ^gender,
          limit: ^limit,
          offset: ^offset
        )
        |> Repo.all()

      {country, gender, offset, limit} when country == "" and gender == "" ->
        from(u in Client,
          limit: ^limit,
          offset: ^offset
        )
        |> Repo.all()

      {country, gender, offset, limit} when country != "" and gender == "" ->
        from(u in Client,
          where: u.country == ^country,
          limit: ^limit,
          offset: ^offset
        )
        |> Repo.all()

      {country, gender, offset, limit} when country == "" and gender != "" ->
        from(u in Client,
          where: u.gender == ^gender,
          limit: ^limit,
          offset: ^offset
        )
        |> Repo.all()
    end
  end

  # Create a new lock meta attribute
  def create_lock_meta(lock_id, attrs \\ %{}) do
    changeset = ClientMeta.changeset(%ClientMeta{}, %{lock_id: lock_id} ++ attrs)
    Repo.insert(changeset)
  end

  # Retrieve a lock meta attribute by ID
  def get_lock_meta_by_id(id) do
    Repo.get(ClientMeta, id)
  end

  # Update a lock meta attribute
  def update_lock_meta(lock_meta, attrs) do
    changeset = ClientMeta.changeset(lock_meta, attrs)
    Repo.update(changeset)
  end

  # Delete a lock meta attribute
  def delete_lock_meta(lock_meta) do
    Repo.delete(lock_meta)
  end

  # Get lock meta by lock and key
  def get_lock_meta_by_key(lock_id, meta_key) do
    from(
      u in ClientMeta,
      where: u.lock_id == ^lock_id,
      where: u.key == ^meta_key
    )
    |> Repo.one()
  end

  # Get lock metas
  def get_lock_metas(lock_id) do
    from(
      u in ClientMeta,
      where: u.lock_id == ^lock_id
    )
    |> Repo.all()
  end
end
