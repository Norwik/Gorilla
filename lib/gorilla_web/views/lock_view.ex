# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule GorillaWeb.LockView do
  use GorillaWeb, :view

  # Render lock
  def render("index.json", %{lock: lock, timeout: timeout, metadata: metadata}) do
    %{
      id: lock.id,
      resource: lock.resource,
      token: lock.token,
      owner: lock.owner,
      timeout: timeout,
      metadata: metadata,
      expireAt: lock.expire_at,
      createdAt: lock.inserted_at,
      updatedAt: lock.updated_at
    }
  end

  # Render errors
  def render("error.json", %{error: error}) do
    %{errorMessage: error}
  end
end
