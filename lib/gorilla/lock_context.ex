# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

# Lock Context Module
defmodule Gorilla.LockContext do
  import Ecto.Query
  alias Gorilla.{Repo, LockMeta, Lock}

  # Get a client map
  def new_client(client \\ %{}) do
    %{
      age: client.age,
      country: client.country,
      gender: client.gender,
      last_seen: DateTime.utc_now(),
      secret: Ecto.UUID.generate(),
      state: client.state,
      username: client.username,
      uuid: Ecto.UUID.generate(),
      user_id: client.user_id
    }
  end

  # Get a client meta map
  def new_meta(meta \\ %{}) do
    %{
      key: meta.key,
      value: meta.value,
      client_id: meta.client_id
    }
  end

  # Create a new client
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  # Count all clients
  def count_clients(country, gender) do
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

  # Retrieve a client by ID
  def get_client_by_id(id) do
    Repo.get(Client, id)
  end

  # Get client by uuid
  def get_client_by_uuid(uuid) do
    from(
      u in Client,
      where: u.uuid == ^uuid
    )
    |> Repo.one()
  end

  # Get client by username
  def get_client_by_username(username) do
    from(
      u in Client,
      where: u.username == ^username
    )
    |> Repo.one()
  end

  # Update a client
  def update_client(client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  # Delete a client
  def delete_client(client) do
    Repo.delete(client)
  end

  # Retrieve all clients
  def get_clients() do
    Repo.all(Client)
  end

  # Retrieve clients
  def get_clients(country, gender, offset, limit) do
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

  # Create a new client meta attribute
  def create_client_meta(client_id, attrs \\ %{}) do
    changeset = ClientMeta.changeset(%ClientMeta{}, %{client_id: client_id} ++ attrs)
    Repo.insert(changeset)
  end

  # Retrieve a client meta attribute by ID
  def get_client_meta_by_id(id) do
    Repo.get(ClientMeta, id)
  end

  # Update a client meta attribute
  def update_client_meta(client_meta, attrs) do
    changeset = ClientMeta.changeset(client_meta, attrs)
    Repo.update(changeset)
  end

  # Delete a client meta attribute
  def delete_client_meta(client_meta) do
    Repo.delete(client_meta)
  end

  # Get client meta by client and key
  def get_client_meta_by_key(client_id, meta_key) do
    from(
      u in ClientMeta,
      where: u.client_id == ^client_id,
      where: u.key == ^meta_key
    )
    |> Repo.one()
  end

  # Get client metas
  def get_client_metas(client_id) do
    from(
      u in ClientMeta,
      where: u.client_id == ^client_id
    )
    |> Repo.all()
  end
end
