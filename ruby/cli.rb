require_relative 'config'

class Cli
  def run
    self.emails = (1..3).map { |i| "leaky_bucket_app#{i}@hubspot.com" } 
    200.times { start_worker }
  end

  private

  attr_accessor :api, :ids, :emails

  def start_worker
    puts 'Sleep 1 second to avoid 429 error'
    sleep 1

    api_client = ::Hubspot::Crm::Contacts::ApiClient.new
    self.api = ::Hubspot::Crm::Contacts::BatchApi.new(api_client)

    response = create_contacts
    self.ids = response.results.map(&:id)
    remove_contacts
  end

  def create_contacts
    puts "Create contacts: #{emails}"
    api.create(contacts_object, auth_names: 'hapikey')
  end

  def contacts_object
    ::Hubspot::Crm::Contacts::BatchInputSimplePublicObjectInput.new(
      inputs: contacts
    )
  end

  def contacts
    emails.map do |email|
      ::Hubspot::Crm::Contacts::SimplePublicObjectInput.new(
        properties: { email: email }
      )
    end
  end

  def remove_contacts
    puts ("Remove contacts: #{ids}")
    api.archive(ids_object, auth_names: 'hapikey')
  end

  def ids_object
    ::Hubspot::Crm::Contacts::BatchInputSimplePublicObjectId.new(
      inputs: ids
    )
  end
end

Cli.new.run
