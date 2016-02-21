require 'socket'
require 'uri'
require 'net/telnet'
require 'active_support/all'

# This class is used to capture query string verification errors
class VerificationError < StandardError
end

@timestamp  # time stamp used in console messages
@lutron     # telnet connection to a Lutron Homeworks controller
@event      # scary global event to be passed back in response

#================================================================================#
def parse(msg)

  raise VerificationError, 'no query string' if msg.count('?') ==  0

  paramstring = msg.split('?')[1]     # chop off the verb
  paramstring = paramstring.split(' ')[0] # chop off the HTTP version

  arguments = URI.decode_www_form(paramstring)
  #p arguments
  parms = arguments.to_h

  return parms
end
#================================================================================#
def switchStatusCmd(address, button)
  rsp = @lutron.cmd('RKLS, ' + address)
  # sometimes, the processor will return multiple stati.
  # first find the right line
  ledStatusLine = rsp[/\[#{address}\], \b[0-9]{24}\b/]
  ledStatus = ledStatusLine[/\b[0-9]{24}\b/]  # extract the status settings
  return ledStatus[button.to_i-1]
end
#================================================================================#
def switchOn(devicetype, address, button)
  if switchStatusCmd(address, button) != '0'  # can be 1, 2, or 3
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch already on'
    @event = 'noaction'
  else
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch is off. Turning it on'
    rsp = @lutron.cmd('KBP, ' + address + ' , ' + button)
    rsp = @lutron.cmd('KBR, ' + address + ' , ' + button)
    @event = 'switch:on'
  end
end
#================================================================================#
def switchOff(devicetype, address, button)
  if switchStatusCmd(address, button) == '0'
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch already off'
    @event = 'noaction'
  else
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch is on. Turning it off'
    rsp = @lutron.cmd('KBP, ' + address + ' , ' + button)
    rsp = @lutron.cmd('KBR, ' + address + ' , ' + button)
    @event = 'switch:off'
  end
end
#================================================================================#
def switchStatus(devicetype, address, button)
  if switchStatusCmd(address, button) == '0'
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch status is off'
    @event = 'switch:off'
  else
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| Switch status is on'
    @event = 'switch:on'
  end
end
#================================================================================#
# query string example: ?action=on&devicetype=K@address=01:05:06@button=1

def execute(parms)
  raise VerificationError, 'missing action key word' if !parms.has_key?('action')
  raise VerificationError, 'invalid action' if %w(on off flash status).exclude?(parms['action'])
  raise VerificationError, 'missing devicetype key word' if !parms.has_key?('devicetype')
  raise VerificationError, 'invalid device type' if %w(K).exclude?(parms['devicetype'])
  raise VerificationError, 'missing address key word' if !parms.has_key?('address')
  raise VerificationError, 'missing button key word' if !parms.has_key?('button')

  case parms['action']
    when 'flash'
      switchFlash(parms['devicetype'],parms['address'],parms['button'])
    when 'on'
      switchOn(parms['devicetype'],parms['address'],parms['button'])
    when 'off'
      switchOff(parms['devicetype'],parms['address'],parms['button'])
    when 'status'
      switchStatus(parms['devicetype'],parms['address'],parms['button'])
  end
end
#================================================================================#
server = TCPServer.new 8081   # listen on port 8081 for incoming connections

@lutron = Net::Telnet::new("Host" => ENV["LUTRONIP"],
                             "Timeout" => 10,
                             "Prompt" => /LNET> /)
# If your controller doesn't require credentials, comment out the following line of code.
@lutron.cmd(ENV["LUTRONUSER"]+' , '+ENV["LUTRONPW"]) { |c| print c }
#@lutron.close  # doesn't work on Lutron processor

loop do
  socket = server.accept  # wait on connection

  request = socket.gets   # read the first line of the request

  @timeStamp = Time.new   # used in console messages

  begin
    parms = parse(request) # parse query string into parms
    execute(parms)
    rspCode = '200 OK'
  rescue VerificationError => e
    puts @timeStamp.strftime('%d %b %Y %H:%M:%S') + '| ' +  e.to_s + ' | in: ' + request
    rspCode = '400 Bad Request'
    @event = e.to_s
  end
  response = "HTTP/1.1 " + rspCode + "\r\n" +
      "Content-Type: text/plain\r\n" +
      "Content-Length: #{@event.bytesize}\r\n" +
      "Connection: close\r\n" +
      "\r\n" +
      "#{@event}\r\n"
  socket.print response
  socket.close  # close the socket, which terminates the connection
end
