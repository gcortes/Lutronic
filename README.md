# Lutronic
Lutronic is a web service that drives a Lutron HomeWorks Controller via Telnet. The service only works with older HomeWorks controllers that use the HomeWorks RS232 protocol. It will not work with HomeWorks QS unless it also supports the same protocol. The application has been tested on OS X 10.11.3 using Ruby 2.2.0p0. It will not work with the version that comes with the OS: 2.0.0p247. It should work with 2.1.0.

The primary purpose of this service is to interface with a companion [Lutron HomeWorks device handler](https://github.com/gcortes/Lutron-HomeWorks-Switch) written for the Smartthings application. The interface uses a standard query string to send commands so any client can be written to interface with it. The Lutron controller has its own web server. It is a much better solution for human web based control.

## Requirements
* socket - included with Ruby
* uri - inclued with Ruby
* net/telnet - included with Ruby
* active_support/all - the gem is named activesupport

You can check the version of Ruby on OS X by entering the following command in Terminal:
```
ruby -version
```
There are several ways to install a newer verions of Ruby. If you are not a Ruby developer, you can just use Homebrew. Homebrew doesn't come with OS X so you will have to install it first. You find instructions [here.](https://www.ruby-lang.org/en/documentation/installation/)

## Set Up

### Install Software

The only file you will need to run the service is Lutronic.rb. A good location is in the scripts folder in your Home directory, but any location is fine. When you run the service, it will use three environment variables to start the Telnet session:
```
export LUTRONUSER=yourUserID
export LUTRONPW=yourPassword
export LUTRONIP=yourIP
```
Place these lines in your .bash_profile or any other file that will be executed when you bring up a Terminal window. If you put it in your .bash_profile, be sure to run

```
source ~/.bash_profile
```

to make the variables available to the active session. You will need to run a different command if you have placed them elsewhere. Alternatively, you can hard code your credential into the program itself. Just remember your changes will be wiped out if you download a new version. For the IP address change
 
```
@lutron = Net::Telnet::new("Host" => ENV["LUTRONIP"], 
```
 to
```
@lutron = Net::Telnet::new("Host" => "10.0.0.199", 
```
replacing 10.0.0.199 with the IP address of your Lutron controller. The second line to change is
```
@lutron.cmd(ENV["LUTRONUSER"]+' , '+ENV["LUTRONPW"]) { |c| print c } 
``` 
A hard coded version would look like this:
```
@lutron.cmd('youruserid ,  yourpassword) { |c| print c } 
``` 

### Determining Your IP Adress

The easiest way to find out the address is to ask your installer. If that is not possible you can search for active IP addresses on your LAN. To verify that you have the right one, enter it into your browser and you will get a Lutron web page.
 
### Determining Your User ID and Password
 
Depending you how your Lutron configuration is set up, you may not even need this. To find out, bring up a Telnet session with the IP address you determined in the previous step. The controller uses the default port so you don't have to specifiy one. If it doesn't ask for your credentials, you won't need them. If it does you have two choices. You can ask your installer or you can bring up the Homeworks Illumination application on your Windows PC and look in the addressing tables. If you don't have the application, you can get it from Lutron. You will also need you configuration file. Your best bet is to work with Lutron tech support to get this done. They've always have been very helpful when I have spoke to them.
  
### Determining Keypad addresses and Button Numbers  

You can obtain the addresses and button numbers by running the HomeWorks Illumination application. If you do not have this software and your configuration file, you can ask your installer for a address report. An easy option is to bring up Telnet to your controller and push the button you wish to control. The activity will be reported  in the Telnet session. You are looking for an address in the form xx:xx:xx, x. The first part is the address. The second is the button number. You now have everything you need.
  

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
  
The appropriate command is sent to the Telnet session, logged to the Terminal window, and a response sent to the client.

### Testing It Out in Baby Steps
  
  If you choose, you can enter the information in to your client and see if it works. If it doesn't, test in incremental steps or start this way.
  
  From a web browser on the same device and the service, enter:
  ```
  http://localhost/?action=status&devicetype=K&address=01:06:05&button=1
  ```
  substituting your address and button. If you get any one line response, you've reached it.
  
  If that works, go to a browser on another device on your LAN and enter:
  ```
  http://19.0.0.199/?action=status&devicetype=K&address=01:06:05&button=1
  ```
  being sure to replace the IP address with the one running Lutronic. If that doesn't work you may have firewall issues. If it does, you client should work as well.
