require "./spec_helper"

def run_in_temp_dir(&)
  dir = File.tempname
  Dir.mkdir(dir)
  begin
    Dir.cd(dir) do
      yield
    end
  ensure
    Dir.children(dir).reject(/\.\.?/).each do |f|
      path = Path[dir, f]
      File.delete(path)
    end
    Dir.delete(dir)
  end
end

describe Secrets::Handler do

  it "should be able to set and retrieve a single secret" do
    run_in_temp_dir do
      password = "top-secret"
      secret_key = "universal-secret"
      secret_value = 42.to_s
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets({secret_key, secret_value})
      actual_secret_value = secrets_handler.get_secrets(secret_key)
      actual_secret_value.should eq([{secret_key, secret_value}])
    end
  end

  it "should be able to set and retrieve multiple secrets" do
    run_in_temp_dir do
      password = "top-secret"
      first_secret = {"first-secret", "first-value"}
      second_secret = {"second-secret", "second-value"}
      non_existing_key = "no-secret"
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets(first_secret, second_secret)
      actual_secret_values = secrets_handler.get_secrets([first_secret.first, second_secret.first, non_existing_key])
      actual_secret_values.should eq([first_secret, second_secret, {non_existing_key, nil}])
    end
  end

  it "should be able to remove a single secret" do
    run_in_temp_dir do
      password = "top-secret"
      secret_key = "universal-secret"
      secret_value = 42.to_s
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets({secret_key, secret_value})
      secrets_handler.remove_secrets(secret_key)
      actual_secret_value = secrets_handler.get_secrets(secret_key)
      actual_secret_value.should eq([{"universal-secret", nil}])
    end
  end

  it "should be able to remove multiple secrets" do
    run_in_temp_dir do
      password = "top-secret"
      first_secret = {"first-secret", "first-value"}
      second_secret = {"second-secret", "second-value"}
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets(first_secret, second_secret)
      secrets_handler.remove_secrets(first_secret.first, second_secret.first)
      actual_secret_values = secrets_handler.get_secrets([first_secret.first, second_secret.first])
      actual_secret_values.should eq([{first_secret.first, nil}, {second_secret.first, nil}])
    end
  end

  it "should be able to get all keys" do
    run_in_temp_dir do
      password = "top-secret"
      first_secret = {"first-secret", "first-value"}
      second_secret = {"second-secret", "second-value"}
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets(first_secret, second_secret)
      actual_keys = secrets_handler.get_keys
      actual_keys.should eq([first_secret.first, second_secret.first])
    end
  end

  it "should be able to get all secrets" do
    run_in_temp_dir do
      password = "top-secret"
      first_secret = {"first-secret", "first-value"}
      second_secret = {"second-secret", "second-value"}
      secrets_handler = Secrets::Handler.new(password)
      secrets_handler.set_secrets(first_secret, second_secret)
      actual_secrets = secrets_handler.get_all_secrets
      actual_secrets.should eq([first_secret, second_secret])
    end
  end

end
