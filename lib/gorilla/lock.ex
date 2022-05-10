# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule Gorilla.Lock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locks" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :owner, :string
    field :expire_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(lock, attrs) do
    lock
    |> cast(attrs, [:uuid, :name, :owner, :expire_at])
    |> validate_required([:uuid, :name, :owner, :expire_at])
  end
end
