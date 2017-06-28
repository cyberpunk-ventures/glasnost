defmodule Glasnost.Steemlike.OpsConsumer do
  use GenStage
  require Logger
  alias Glasnost.Golos

  def start_link(args, options \\ []) do
    GenStage.start_link(__MODULE__, args, options)
  end

  def init(%{config: config} = args \\ []) do
    Logger.info("Ops consumer for #{config.token} is initializing...")
    schema = config.schema
    new_config = config
      |> Map.put(:vote_schema, Module.concat(schema, Vote))
      |> Map.put(:comment_schema, Module.concat(schema, Comment))
    {:consumer, %{config: new_config}, subscribe_to: args.config.subscribe_to}
  end

  def handle_events(events, _from, state) do
    Logger.info("events arrived...")
    IO.inspect(events)
    comments_to_update_new = events
      |> Enum.filter(& &1.metadata.type === :comment)
      |> Enum.map(&Map.get(&1, :data))
      |> Enum.map(&Map.take(&1, [:author, :permlink]))

    comments_to_update_votes = events
      |> Enum.filter(& &1.metadata.type === :vote)
      |> Enum.map(&Map.get(&1, :data))
      |> Enum.map(&Map.take(&1, [:author, :permlink]))

    commments_to_update = comments_to_update_new ++ comments_to_update_votes
      |> Enum.uniq

    for %{author: a, permlink: p} <- comments_to_update_new do
      state.config.comment_schema.get_data_and_update(a, p)
    end

    {:noreply, [], state}
  end

end