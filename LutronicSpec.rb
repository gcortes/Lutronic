require 'rspec'

 describe 'Lutronic Web Service' do

  before :all do
    response = `curl -s "http://localhost:8081/?action=status&devicetype=K&address=01:06:05&button=1"`
    if response == 'switch:on'
      `curl -s "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`
      sleep(1)
    end
  end

  it 'should return an error when the action keyword is missing' do
    response = `curl -s "http://localhost:8081/?devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('missing action key word')
    sleep(1)
  end

  it 'should return an error when the action value is invalid' do
    response = `curl -s "http://localhost:8081/?action=light&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('invalid action')
    sleep(1)
  end

  it 'should return an error when the device type keyword is missing' do
    response = `curl -s "http://localhost:8081/?action=status&address=01:06:05&button=1"`
    expect(response).to eq('missing devicetype key word')
    sleep(1)
  end

  it 'should return an error when the device type value is invalid' do
    response = `curl -s "http://localhost:8081/?action=light&devicetype=X&address=01:06:05&button=1"`
    expect(response).to eq('invalid action')
    sleep(1)
  end

  it 'should return an error when the address keyword is missing' do
    response = `curl -s "http://localhost:8081/?action=status&devicetype=K&button=1"`
    expect(response).to eq('missing address key word')
    sleep(1)
  end

  it 'should return an error when the button keyword is missing' do
    response = `curl -s "http://localhost:8081/?action=status&devicetype=K&address=01:06:05"`
    expect(response).to eq('missing button key word')
    sleep(1)
  end

  it 'should report the switch off when it is' do
    response = `curl -s "http://localhost:8081/?action=status&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('switch:off')
    sleep(1)
  end

  it 'should turn the switch on when it is off' do
    response = `curl -s "http://localhost:8081/?action=on&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('switch:on')
    sleep(1)
  end

  it 'should do nothing when turning the switch on when it is already on' do
    response = `curl -s "http://localhost:8081/?action=on&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('noaction')
    sleep(1)
  end

  it 'should turn the switch off when it is on' do
    response = `curl -s "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('switch:off')
    sleep(1)
  end

  it 'should do nothing when turning the switch off when it is already off' do
    response = `curl -s "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`
    expect(response).to eq('noaction')
    sleep(1)
  end

end