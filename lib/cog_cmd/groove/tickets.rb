
require 'text-table'
require 'groovehq'

class CogCmd::Groove::Tickets < Cog::Command
  def run_command
    client = GrooveHQ::Client.new(ENV['GROOVE_API_TOKEN'])
    states = [ request.options['state'] || %w(unread opened) ].flatten
    assignee = request.options['assignee']
    from = request.options['from']

    params = assignee.nil? ? {} : { :assignee => assignee }
    params[:customer] = from unless from.nil?

    results = []
    table = Text::Table.new
    table.head = %w(# Title Sender State Updated)

    states.each do |state|
      filter = params.merge(state: state)
      tickets = client.tickets(filter)

      tickets.each do |ticket|
        results << ticket
        customer = ticket.rels['customer'].href.split('/').last
        table.rows << [ ticket.number, ticket.title, customer, state, ticket.updated_at ]
      end
    end

    if table.rows == []
      message = assignee.nil? ? "" : "#{assignee} in "
      response.content = "No tickets where found for #{message} states: #{states.join(", ")}"
    else
      response.template = 'table'
      response['tickets'] = results
      response['table'] = table.to_s
    end
  end
end
