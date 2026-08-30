# The driver reads its credentials and its region straight out of the
# environment, and several examples set those variables to prove it. Without
# this the values leak from one example into the next, and out of the suite
# into whatever else the process goes on to do.
RACKSPACE_ENVIRONMENT_VARIABLES = %w{
  RACKSPACE_USERNAME
  RACKSPACE_API_KEY
  RACKSPACE_REGION
  OS_USERNAME
  OS_PASSWORD
  OS_REGION_NAME
}.freeze

RSpec.configure do |config|
  config.around do |example|
    saved = RACKSPACE_ENVIRONMENT_VARIABLES.to_h { |name| [name, ENV.fetch(name, nil)] }
    RACKSPACE_ENVIRONMENT_VARIABLES.each { |name| ENV.delete(name) }

    begin
      example.run
    ensure
      saved.each do |name, value|
        value.nil? ? ENV.delete(name) : ENV[name] = value
      end
    end
  end
end
