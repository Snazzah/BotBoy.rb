![BotBoy](https://raw.github.com/SnazzyPine25/BotBoy/master/bb-logo.png)
[![discord](https://img.shields.io/badge/discord-join-7289DA.svg)](https://discord.gg/0vjTDaDsgOQWUtlv)
============
A big bundle of API stuff and image generators.

## How to run
You need Ruby 2.3, Bundler and ImageMagick.
You can download ImageMagick from [http://www.imagemagick.org/](http://www.imagemagick.org/) or, if you are on Ubuntu, you can easily running this command:
```
sudo apt-get install libmagickwand-dev
```
First, install all the dependencies using `bundle install`. Then make a file called 1 `bb-auth` and follow this format:
```
TOKEN HERE
171456123456123456
```
Then, use `ruby botboy.rb` to run it.

## Settings and Configuration
### If you want Mention Prefixes:
In the file `botboy.rb`, simply replace `USER_ID` with the bots User ID.

### If you want to change source code settings:
You can set them all after line 28.

### If you want to use the eval command:
Replaye with your ID in line 551 in the source code.

## Things I really need help with.
  * Masking in dis-card commands.
  * Better way to customize settings.
  * Requesting in mcserv command.
  * Fallback to commands.
  * A better meme command handler.
  * Unbug cat command.
