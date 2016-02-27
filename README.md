# Lutronic
Lutronic is a web service that drives a Lutron HomeWorks controller via Telnet. The service only works with older HomeWorks controllers that use the [HomeWorks RS232 protocol](http://www.lutron.com/TechnicalDocumentLibrary/HWI%20RS232%20Protocol.pdf). It will not work with HomeWorks QS. The application has been tested on OS X 10.11.3 using Ruby 2.2.0p0. It will not work with the version that comes with the OS: 2.0.0p247. It should work with 2.1.0.

The primary purpose of this service is to interface with a companion [Lutron HomeWorks device handler](https://github.com/gcortes/Lutron-HomeWorks-Switch) written for the Smartthings application. The interface uses a standard query string to send commands so any client can be written to interface with it. The Lutron controller has its own web server. It is a much better solution for human web based control.

## Requirements
* socket - included with Ruby
* uri - inclued with Ruby
* net/telnet - included with Ruby
* active_support/all - the gem is named activesupport
* ipaddress - gem

You can check the version of Ruby on OS X by entering the following command in Terminal:
```
ruby -version
```
There are several ways to install a newer verions of Ruby. If you are not a Ruby developer, you can just use Homebrew. Homebrew doesn't come with OS X so you will have to install it first. You find instructions [here.](https://www.ruby-lang.org/en/documentation/installation/)

## Set Up

### Install Software

You will need to download lutronic.rb and lutronic.yaml-TEMPLATE. A good location on OS X is in the scripts folder in your Home directory, but any location is fine. Change the name of the yaml file to lutronic.yaml. 

### Setting up the Configuration

Open up the lutronic.yaml file in your favortie editor. The inital template looks like this:

```
telnet:
  host: 127.0.0.0   # the IP address of your Lutron controller
  port: 23          # 23 is the default and is used by Lutron. Only change it if yours is different
  credentials: y    # set to y if your controller requires a sign in.
  user: youruser
  password: yourpw
sockets:
  number: 4
  starting_port: 8081
```
The following sections tell you how to determine the values for your environment. 

### Determining the Address of Your Lutron Processor

The host field is the IP address of your Lutron controller. The easiest way to find the address is to ask your Lutron installer. If that is not possible you can search for active IP addresses on your LAN. To verify that you have the right one, enter it into your browser and you will get a Lutron web page. It may be possible that the broswer can be disable in the Homeworks config. An alternative test is to try to Telnet to it.

The default Telnet port is 23 and is also the default used by Homeworks. It also can be changed in the Homeworks config. Most likely it hasn't.
 
### Determining Your User ID and Password
 
Depending you how your Lutron configuration is set up, you may not even need this. To find out, bring up a Telnet session with the IP address and port you determined in the previous step. The controller uses the default port so you don't have to specifiy one. If it doesn't ask for your credentials, you won't need them. Set credential to n is this is the case. You can then leave the user and password as is. If you do need them, you have two choices. You can ask your installer or you can bring up the Homeworks Illumination application on your Windows PC and look in the Ethernet addressing table. If you don't have the application, you can get it from Lutron. You will also need your configuration file. Your best bet is to work with Lutron tech support to get this done. They've always have been very helpful when I have spoke to them.

### Socket Setup

The starting_port is the first port on which the Lutronic application will listen for requests from your client. If this is the companion SmartThings Homework drive, you will need a unique port for each button you wish to control. You can specify as many as you think you will need. If they aren't used, they sit idle.  
  
## Operation
Start the service in a console session. This is Terminal on OS X.
```
ruby Lutronic.rb
```
This assumes you are in the directory that contains the application. If it is suceessful, it will display that the Telnet session was established and the sockets started. The only input the application will accepts is 'quit' to terminate it. If you use the console for other purposes, you should run this in it's own tab or window.


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
  
### Determining Keypad addresses and Button Numbers  

You can obtain the addresses and button numbers by running the HomeWorks Illumination application. If you do not have this software and your configuration file, you can ask your installer for a address report. An easy option is to bring up Telnet to your controller and push the button you wish to control. The activity will be reported  in the Telnet session. You are looking for an address in the form xx:xx:xx, x. The first part is the address. The second is the button number. You now have everything you need.
  
When the application receives a request, it sends the appropriate command to the Telnet session, loggs the actions to the Terminal window, and sends a response sent to the client.

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
