# Ruby Tanks

This is a fun program written for Bring Your Kids To Work day
at Udacity, 2017.  The point is to help kids see what a software engineer
does by seeing how they figure out what they want the computer to do,
and then how to tell the computer to do it.

![UdaciTanks](/assets/ruby-tanks.png)

## Setup

To run this on your own machine, check out the repo, and make sure
you have ruby 2.4.1 installed one way or another (rbenv would be a great
  choice).

Ruby Tanks is built on top of Gosu, which is dependent on http://www.libsdl.org/,
so before you do anything else you'll need to have that installed. If you're
on a Mac with homebrew, it's just:

`brew install sdl2`

You'll need bundler:

`gem install bundler`

and then you should be able to install dependencies from the root directory
of this project:

`bundle install`

## Playing

To start the game, you can use the script at "bin/play":

`./bin/play`

## Participating

The goal here is to have players write bots that play laser tag against each other.
Right now the game initializes with 2 "RandomBots" that just pick a random
action for each tick, but any bot that matches the same interface (accepts
  the game state and returns a desired action of [left, right, up, down, shoot])
could be input, so the bot can be as complicated as you want.

If you write your own bot, go into "game.rb" and replace one of the random
bots with your bot (or add it as a 3rd), and the game should just work.

## Game structure:

* Each Tank starts with 1000 energy
* moving costs 1 energy
* shooting costs 10 energy
* getting hit by a laser loses 100 energy
* picking up a battery gains back 80 energy
* going below 0 causes your tank to be "tagged" and it stops
* last tank with energy wins
