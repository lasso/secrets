require "./spec_helper"

def run_in_temp_dir(&)
  dir = File.tempname
  puts "Running test in #{dir}"
  Dir.mkdir(dir)
  begin
    Dir.cd(dir) do
      yield
    end
  ensure
    Dir.children(dir).reject(/\.\.?/).each do |f|
      path = Path[dir, f]
      puts "Deleting #{path}"
      File.delete(path)
    end
    puts "Deleting #{dir}"
    Dir.delete(dir)
  end
end

describe Secrets::SecretsHandler do

  it "should be able to set a single secret" do
    run_in_temp_dir do
      password = "top-secret"
      secret_key = "universal-secret"
      secret_value = 42.to_s
      secrets_handler = Secrets::SecretsHandler.new(password)
      secrets_handler.set_secret(secret_key, secret_value)
      actual_secret_value = secrets_handler.get_secret(secret_key)
      actual_secret_value.should eq(secret_value)
    end
  end

end
