# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule GorillaWeb.LockController do
  use GorillaWeb, :controller
  alias Gorilla.LockContext

  # Create a new Lock Endpoint
  def create_lock(conn, params) do
    resource = params["resource"] || ""

    lock = LockContext.get_lock_by_resource(resource)

    if lock do
      conn
      |> put_status(:conflict)
      |> render("error.json", %{error: "Lock with resource #{resource} held by another owner"})
    else
      lock =
        LockContext.new_lock(%{
          timeout: params["timeout"] || 0,
          resource: resource,
          owner: params["owner"] || ""
        })

      metadata = params["metadata"] || []

      timeout = DateTime.diff(lock.expire_at, DateTime.utc_now(), :second)

      case LockContext.create_lock(lock) do
        {:ok, result} ->
          # Store metadata
          for value <- metadata do
            meta =
              LockContext.new_meta(%{
                key: "lock_metadata_value",
                value: value,
                lock_id: result.id
              })

            LockContext.create_lock_meta(meta)
          end

          conn
          |> put_status(:created)
          |> render("index.json", %{lock: result, timeout: timeout, metadata: metadata})

        {:error, changeset} ->
          messages =
            changeset.errors()
            |> Enum.map(fn {field, {message, _options}} -> "#{field}: #{message}" end)

          conn
          |> put_status(:bad_request)
          |> render("error.json", %{error: Enum.at(messages, 0)})
      end
    end
  end

  # Update Lock Endpoint
  def update_lock(conn, params) do
    resource = params["resource"] || ""
    token = params["token"] || ""
    new_timeout = params["timeout"] || 0

    lock = LockContext.get_lock_by_token_resource(resource, token)

    if lock do
      timeout = DateTime.diff(lock.expire_at, DateTime.utc_now(), :second)

      if timeout <= 0 do
        LockContext.delete_lock(lock)

        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: "Lock with resource #{resource} not found"})
        |> halt
      else
        new_lock =
          LockContext.update_lock(
            lock,
            LockContext.new_lock(%{
              timeout: new_timeout,
              resource: resource,
              owner: lock.owner
            })
          )

        case new_lock do
          {:ok, result} ->
            items = LockContext.get_lock_metas(result.id)
            metadata = Enum.map(items, fn item -> item.value end)

            conn
            |> put_status(:created)
            |> render("index.json", %{lock: result, timeout: new_timeout, metadata: metadata})

          {:error, changeset} ->
            messages =
              changeset.errors()
              |> Enum.map(fn {field, {message, _options}} -> "#{field}: #{message}" end)

            conn
            |> put_status(:bad_request)
            |> render("error.json", %{error: Enum.at(messages, 0)})
        end
      end
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", %{error: "Lock with resource #{resource} not found"})
    end
  end

  # Get Lock Endpoint
  def get_lock(conn, %{"resource" => resource, "token" => token}) do
    lock = LockContext.get_lock_by_token_resource(resource, token)

    if lock do
      timeout = DateTime.diff(lock.expire_at, DateTime.utc_now(), :second)

      if timeout <= 0 do
        LockContext.delete_lock(lock)

        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: "Lock with resource #{resource} not found"})
        |> halt
      else
        items = LockContext.get_lock_metas(lock.id)
        metadata = Enum.map(items, fn item -> item.value end)

        conn
        |> put_status(:ok)
        |> render("index.json", %{lock: lock, timeout: timeout, metadata: metadata})
      end
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", %{error: "Lock with resource #{resource} not found"})
    end
  end

  # Release Lock Endpoint
  def release_lock(conn, %{"resource" => resource, "token" => token}) do
    lock = LockContext.get_lock_by_token_resource(resource, token)

    if lock do
      LockContext.delete_lock(lock)

      conn
      |> send_resp(:no_content, "")
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", %{error: "Lock with resource #{resource} not found"})
    end
  end
end
