defmodule RicardianModel.Actions do
  alias RicardianModel.Main
  alias RicardianModel.Host
  alias RicardianModel.Participant

  def update_host_contents(data) do
    host = get_action("update contents", Host.format_data(data))
    format(data, host)
  end

  def update_participant_contents(data, id) do
    action = get_action("update contents", Participant.format_contents(data, id))
    format(data, nil, dispatch_to(id, action))
  end

  def update_proposal(data, id, payload) do
    group_id = get_in(data, [:participants, id, :group])
    group = get_in(data, [:groups, group_id])
    target = case group do
      %{u1: ^id, u2: target} -> target
      %{u2: ^id, u1: target} -> target
    end
    format(data, nil, dispatch_to(target, get_action("change proposal", payload)))
  end

  def proposed(data, id, group_id) do
    group = get_in(data, [:groups, group_id])
    host = get_action("proposed", %{
      "groupID" => group_id,
      "state" => group.state,
      "g1proposal" => group.g1proposal,
      "g2proposal" => group.g2proposal,
    })
    target = case group do
      %{u1: ^id, u2: target} -> target
      %{u2: ^id, u1: target} -> target
    end
    participant = dispatch_to(target, get_action("proposed", %{
      "state" => group.state,
      "g1proposal" => group.g1proposal,
      "g2proposal" => group.g2proposal,
    }))
    format(data, host, participant)
  end

  def change_page(data, page) do
    action = get_action("change page", page)
    format(data, nil, dispatch_to_all(data, action))
  end

  def join(data, id, participant) do
    action = get_action("join", %{id: id, user: participant})
    format(data, action)
  end

  def matched(data) do
    %{participants: participants, groups: groups} = data
    host = get_action("matched", %{participants: participants, groups: groups})
    participant = Enum.map(participants, fn {id, p} ->
      payload = if is_nil(p.group) do
        Participant.format_participant(p)
      else
        Map.merge(Participant.format_participant(p), Participant.format_group(data, Map.get(groups, p.group), id))
      end
      {id, %{action: get_action("matched", payload)}}
    end) |> Enum.into(%{})
    format(data, host, participant)
  end

  # Utilities

  defp get_action(type, params) do
    %{
      type: type,
      payload: params
    }
  end

  defp dispatch_to(map \\ %{}, id, action) do
    Map.put(map, id, %{action: action})
  end

  defp dispatch_to_all(%{participants: participants}, action) do
    Enum.reduce(participants, %{}, fn {id, _}, acc -> dispatch_to(acc, id, action) end)
  end

  defp format(data, host, participants \\ %{}) do
    result = %{"data" => data}
    unless is_nil(host) do
      result = Map.put(result, "host", %{action: host})
    end
    unless is_nil(participants) do
      result = Map.put(result, "participant", participants)
    end
    {:ok, result}
  end
end
