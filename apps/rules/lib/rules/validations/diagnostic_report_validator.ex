defmodule Rules.Validations.DiagnosticReportValidator do
  @moduledoc false

  alias Rules.Rpc.Cache

  def same_origin_episode?(patient_id, client_id, diagnostic_report_id) do
    with {:ok, diagnostic_report} <-
           Cache.run("medical_events_api", Api.Rpc, :diagnostic_report_by_id, [
             patient_id,
             diagnostic_report_id
           ]),
         {:ok, origin_episode} <-
           Cache.run("medical_events_api", Api.Rpc, :episode_by_id, [
             patient_id,
             diagnostic_report.origin_episode.identifier.value
           ]) do
      origin_episode.managing_organization.identifier.value == client_id
    else
      _ -> false
    end
  end
end
