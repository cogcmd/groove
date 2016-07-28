class CogCmd::Groove::Trigger < Cog::Command
  def run_command
    response.template = 'trigger'
    response['ticket'] = request.input['body']
  end
end
