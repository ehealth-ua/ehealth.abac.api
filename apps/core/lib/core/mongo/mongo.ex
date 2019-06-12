defmodule Core.Mongo do
  @moduledoc false

  alias BSON.Binary
  alias BSON.ObjectId
  alias DBConnection.Poolboy
  alias Mongo, as: M
  require Logger

  defdelegate start_link(opts), to: M
  defdelegate object_id, to: M

  defp execute(fun, args) do
    opts =
      args
      |> List.last()
      |> Keyword.put(:pool, Poolboy)

    enriched_args =
      args
      |> List.replace_at(Enum.count(args) - 1, opts)
      |> List.insert_at(0, :mongo)

    try do
      apply(M, fun, enriched_args)
    rescue
      error ->
        Logger.info("Error: #{inspect(error)}, #{fun}: #{inspect(enriched_args)}")
        reraise(error, __STACKTRACE__)
    end
  end

  def generate_id do
    Mongo.IdServer.new()
  end

  def aggregate(coll, pipeline, opts \\ []) do
    execute(:aggregate, [coll, pipeline, opts])
  end

  def command(query, opts \\ []) do
    execute(:command, [query, opts])
  end

  def command!(query, opts \\ []) do
    execute(:command!, [query, opts])
  end

  def find(coll, filter, opts \\ []) do
    execute(:find, [coll, filter, opts])
  end

  def find_one(coll, filter, opts \\ []) do
    execute(:find_one, [coll, filter, opts])
  end

  def insert_one(coll, doc, opts \\ []) do
    execute(:insert_one, [coll, doc, opts])
  end

  def insert_one!(coll, doc, opts \\ []) do
    execute(:insert_one!, [coll, doc, opts])
  end

  def update_one(coll, %{"_id" => _} = filter, update, opts \\ []) do
    execute(:update_one, [coll, filter, update, opts])
  end

  def prepare_doc(%DateTime{} = doc), do: doc

  def prepare_doc(%NaiveDateTime{} = doc) do
    DateTime.from_naive!(doc, "Etc/UTC")
  end

  def prepare_doc(%Binary{} = doc), do: doc
  def prepare_doc(%ObjectId{} = doc), do: doc

  def prepare_doc(%Date{} = doc) do
    date = Date.to_erl(doc)
    {date, {0, 0, 0}} |> NaiveDateTime.from_erl!() |> DateTime.from_naive!("Etc/UTC")
  end

  def prepare_doc([%{__struct__: _} | _] = docs) do
    Enum.map(docs, &prepare_doc/1)
  end

  def prepare_doc(%{__struct__: _} = doc) do
    doc
    |> Map.from_struct()
    |> Enum.into(%{}, fn {k, v} -> {k, prepare_doc(v)} end)
  end

  def prepare_doc(%{} = doc) do
    Enum.into(doc, %{}, fn {k, v} -> {k, prepare_doc(v)} end)
  end

  def prepare_doc(doc), do: doc

  def convert_to_uuid(set, path) do
    uuid = Map.get(set, path)

    if is_binary(uuid) do
      Map.replace!(set, path, string_to_uuid(uuid))
    else
      set
    end
  end

  def convert_to_uuid(set, path, subpath) do
    put_item = fn uuid, item ->
      if is_binary(uuid) do
        put_in(item, subpath, string_to_uuid(uuid))
      else
        item
      end
    end

    case Map.get(set, path) do
      nil ->
        set

      values when is_list(values) ->
        items =
          Enum.map(values, fn item ->
            uuid = get_in(item, subpath)
            put_item.(uuid, item)
          end)

        Map.replace!(set, path, items)

      %{} = value ->
        uuid = get_in(value, subpath)
        Map.replace!(set, path, put_item.(uuid, value))
    end
  end

  def string_to_uuid(value) when is_binary(value) do
    %BSON.Binary{binary: UUID.string_to_binary!(value), subtype: :uuid}
  rescue
    _ -> nil
  end
end
