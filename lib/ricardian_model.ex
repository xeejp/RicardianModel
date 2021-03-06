defmodule RicardianModel do 
  use XeeThemeScript 
  require Logger 
  alias RicardianModel.Main 
  alias RicardianModel.Host 
  alias RicardianModel.Participant 
  # Callbacks 
  def script_type do 
    :message 
  end 
  def install, do: nil 
  def init do 
    {:ok, %{"data" => Main.init()}} 
  end 
  def wrap_result({:ok, _} = result), do: result 
  def wrap_result(result), do: Main.wrap(result) 
  def join(data, id) do 
    wrap_result(Main.join(data, id)) 
  end 
  def handle_received(data, %{"action" => action, "params" => params}) do 
    Logger.debug("[RicardianModel] #{action} #{inspect params}") 
    result = case {action, params} do 
      {"fetch contents", _} -> Host.fetch_contents(data) 
      {"change page", page} -> Host.change_page(data, page) 
      {"match", _} -> Host.match(data) 
    end 
    wrap_result(result) 
  end 
  def handle_received(data, %{"action" => action, "params" => params}, id) do 
    Logger.debug("[RicardianModel] #{action} #{inspect params}") 
    result = case {action, params} do 
      {"fetch contents", _} -> Participant.fetch_contents(data, id) 
      {"fetch ranking", _} -> Participant.fetch_ranking(data, id) 
      {"propose", %{"goods" => goods, "g1" => g1, "g2" => g2}} -> Participant.propose(data, id, goods, g1, g2) 
      {"update proposal", payload} -> Participant.update_proposal(data, id, payload) 
      {"change goods", new} -> Participant.change_goods(data, id, new) 
      {"accept", _} -> Participant.accept(data, id) 
      {"reject", _} -> Participant.reject(data, id) 
    end 
    wrap_result(result) 
  end 
end 
