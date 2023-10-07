defmodule Excontainers.CephContainer do
  @moduledoc """
  Functions to build and interact with Ceph containers.
  """

  alias Excontainers.Container
  alias Docker.LogWaitStrategy

  @ceph_s3_port 8080
  @ceph_mon_port 3300
  @ceph_demo_uid "test"
  @ceph_demo_access_key "test"
  @ceph_demo_secret_key "test"
  @cehp_demo_bucket "test"
  @ceph_default_image "quay.io/ceph/demo:latest-quincy"
  @ceph_successful_start_regex "/opt/ceph-container/bin/demo: SUCCESS"

  @doc """
  Builds a Ceph container.

  Uses Ceph 17 by default, aka quincy, but a custom image can also be set.
  However, the image must be derived or similar in many aspects to quay.io/ceph/demo.

  ## Options

  - `access_key` sets the access key for the demo user
  - `secret_key` sets the secret key for the demo user
  - `bucket` sets the name of the demo bucket
  """
  def new(image \\ @ceph_default_image, opts \\ []) do
    demo_access_key = Keyword.get(opts, :access_key, @ceph_demo_access_key)
    demo_secret_key = Keyword.get(opts, :secret_key, @ceph_demo_secret_key)
    demo_bucket = Keyword.get(opts, :bucket, @cehp_demo_bucket)

    Docker.Container.new(
      image,
      exposed_ports: [@ceph_s3_port, @ceph_mon_port],
      environment: %{
        CEPH_DEMO_UID: @ceph_demo_uid,
        CEPH_DEMO_ACCESS_KEY: demo_access_key,
        CEPH_DEMO_SECRET_KEY: demo_secret_key,
        CEPH_DEMO_BUCKET: demo_bucket,
        CEPH_PUBLIC_NETWORK: "0.0.0.0/0",
        MON_IP: "127.0.0.1",
        RGW_NAME: "localhost"
      },
      wait_strategy: wait_strategy()
    )
  end

  @doc """
  Returns the port on the _host machine_ where the Ceph container is listening.
  """
  def port(pid), do: with({:ok, port} <- Container.mapped_port(pid, @ceph_s3_port), do: port)

  @doc """
  Returns the connection url to connect to the Ceph server from the _host machine_.
  """
  def connection_url(pid) do
    "http://localhost:#{port(pid)}"
  end

  defp wait_strategy do
    LogWaitStrategy.new(@ceph_successful_start_regex)
  end
end
