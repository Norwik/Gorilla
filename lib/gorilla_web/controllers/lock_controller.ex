# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule GorillaWeb.LockController do
  use GorillaWeb, :controller
  alias Gorilla.LockContext

  # Create a new Lock Endpoint
  def create(conn, params) do
    resource = params["resource"] || ""
    metadata = params["metadata"] || []
    owner = params["owner"] || ""
    timeout = params["timeout"] || 0

    case LockContext.get_lock_by_resource(resource) do
      # If there is no lock
      nil ->
        lock =
          LockContext.new_lock(%{
            timeout: timeout,
            resource: resource,
            owner: owner
          })

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
            |> render("index.json", %{
              lock: result,
              timeout: timeout,
              metadata: metadata
            })

          {:error, changeset} ->
            messages =
              changeset.errors()
              |> Enum.map(fn {field, {message, _options}} -> "#{field}: #{message}" end)

            conn
            |> put_status(:bad_request)
            |> render("error.json", %{error: Enum.at(messages, 0)})
        end

      # If there is a lock for this resource
      _ ->
        conn
        |> put_status(:conflict)
        |> render("error.json", %{
          error: "Lock with resource #{resource} held by another owner"
        })
    end
  end

  # Update Lock Endpoint
  def update(conn, params) do
    resource = params["resource"] || ""
    token = params["token"] || ""
    new_timeout = params["timeout"] || 0

    case LockContext.get_lock_by_token_resource(resource, token) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: "Lock with resource #{resource} not found"})

      lock ->
        timeout = DateTime.diff(lock.expire_at, DateTime.utc_now(), :second)

        cond do
          timeout <= 0 ->
            LockContext.delete_lock(lock)

            conn
            |> put_status(:not_found)
            |> render("error.json", %{error: "Lock with resource #{resource} not found"})

          true ->
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
    end
  end

  # Get Lock Endpoint
  def get(conn, %{"resource" => resource, "token" => token}) do
    case LockContext.get_lock_by_token_resource(resource, token) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{error: "Lock with resource #{resource} not found"})

      lock ->
        timeout = DateTime.diff(lock.expire_at, DateTime.utc_now(), :second)

        cond do
          timeout <= 0 ->
            LockContext.delete_lock(lock)

            conn
            |> put_status(:not_found)
            |> render("error.json", %{error: "Lock with resource #{resource} not found"})

          true ->
            items = LockContext.get_lock_metas(lock.id)
            metadata = Enum.map(items, fn item -> item.value end)

            conn
            |> put_status(:ok)
            |> render("index.json", %{lock: lock, timeout: timeout, metadata: metadata})
        end
    end
  end

  # Release Lock Endpoint
  def release(conn, %{"resource" => resource, "token" => token}) do
    lock = LockContext.get_lock_by_token_resource(resource, token)

    case lock do
      # If not found
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", %{
          error: "Lock with resource #{resource} not found"
        })

      # If lock found
      lock ->
        LockContext.delete_lock(lock)

        conn
        |> send_resp(:no_content, "")
    end
  end
end
