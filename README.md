# Lutronic
A web service that drives a Luton HomeWorks Controller via FTP.
The service only works with older Homeworks controllers that use the HomeWorks RS232 protocol. It will not work with HomeWorks QS.
The application has been tested on OS X 10.11.3 using Ruby 2.2.0p0. It will not work with the version that comes with the OS: 2.0.0p247. It should work with 2.1.0.

## Requirements
* socket - included with Ruby
* uri - inclued with Ruby
* net/telnet - included with Ruby
* active_support/all - the gem is named activesupport

You can check the version of Ruby on OS X by entering the following command in Terminal:
```
ruby -version
```
There are several ways to install a newer verions of Ruby. If you are not a Ruby developer, you can just use Homebrew. 
Homebrew doesn't come with OS X so you will have to install it first. You find instructions [here.](https://www.ruby-lang.org/en/documentation/installation/)

## Operation
Start the service in a Terminal session.
```
ruby Lutronic.rb
```
This assumes you are in the directory that contains the application. Its operation will lock up the Terminal session until you enter control-c to abort it.

At this time, the service only supports keypad button press and keypad button LED status. This will allow to turn on and off lights and scenes and check their status.

To control your lights and scenes, use the followig query strings:
```
  ?action=on@devicetype=K&address=01:06:05&button=1
  ?action=off@devicetype=K&address=01:06:05&button=1
  ?action=status&devicetype=K&address=01:06:05&button=1
```  
  where
  
  * action is self explanatory
  * devicetype is always K for Keypad. Future versions may support additional types
  * address is the device address from the configuration
  * button is the number of the button on the device
  
  You can obtain the addrsses and button numbers by running the HomeWorks Ilumination application. If you do not have this software and your 
  configuation file, you can ask your installer for a address report. Another option is to use Telnet to connect to your controller and push the
  button you wish to control. The activity is sent to the Telnet session. Depending on your configuration, you may need a user id and password to
  open the Telnet session. They can be found in the configuration or you can get them from your installer. This service assumes you will need a 
  user id and pasword. You nust alter the code to insert yours or take it out if it is not required.
  
  ## Smartthings
  
  This service was written to serve a companion Lutron Homeworks device handler.
