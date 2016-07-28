
require 'cgi'

class CogCmd::Groove::Ticket < Cog::Command
  def run_command
    ticket_id = request.args[0]
    ticket = fetch_ticket(ticket_id)
    messages = fetch_messages(ticket_id)

    ticket['customer_name'] = ticket['links']['customer']['href'].split('/').last

    if ticket.nil?
      # If we were called explicitly, but didn't get a ticket_id as an
      # argument, return a descriptive error message.
      if ticket_id.nil?
        response.content = "Error. The groove:ticket command must be called with a ticket ID."
      else
        response.content = "No ticket found for ticket ID #{ticket_id}"
      end
    else

      response.template = 'ticket'
      response['ticket'] = ticket
      response['messages'] = messages
    end
  end

  def fetch_ticket(ticket_id)
    resp = client.ticket(ticket_id)
    return nil if resp.nil?

    ticket = {
      "links" => Hash[resp.rels.map { |k,v| [ k, { 'href' => v.href } ] }]
    }

    resp.data.each_pair do |k,v|
      ticket[k.to_s] = v
    end

    ticket != {} ? ticket : nil
  end

  def fetch_messages(ticket_id, count=5)
    resp = client.messages(ticket_id, per_page: count)
    return [] if resp.nil?

    resp.map do |message|
      author = rel_target(message, 'author')
      recipient = rel_target(message, 'recipient')

      slack_body = CGI.unescapeHTML(message.plain_text_body.gsub(/(\A\s*)|(\s*\z)/, '').split("\n").join("\n>"))

      {
        to: recipient,
        from: author,
        body: message.plain_text_body,
        slack_body: slack_body
      }
    end
  end

  def rel_target(obj, name, default = nil)
    return default unless obj.rels.has_key?(name)
    obj.rels[name].href.split('/').last
  end

  def client
    client ||= GrooveHQ::Client.new(ENV['GROOVE_API_TOKEN'])
  end
end
