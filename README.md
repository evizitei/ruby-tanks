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
Right now the game initializes with all the bots in a leaderboard-gathering
mode where it just pits them against each other at random and sees how they do,
but any bot that matches the same interface (accepts
  the game state and returns a desired action of [left, right, up, down, shoot])
could be input, so the bot can be as complicated as you want.

You can control the pairing by turning IN_STATS_MODE to "false" in game.rb
and manually picking 2 bots from the ones
imported into the "game.rb" file to pit against
each other by editing the constructor in include only the
bots you want (comment out the rest), make sure to give them different
colored images.

If you write your own bot, go into "game.rb" and replace one of the random
bots with your bot (or add it as a 3rd), and the game should just work.

### RECOMMENDED PEDAGOGY:

The UserBot is built to allow the user to explore
how to beat bots by controlling it themselves.  The
best way to learn the most from this toy is to first
pick a bot to defeat and put it into the ring with
a UserBot (just one at a time, it's fun to watch 5 bots go at it
but it's hard to figure much out in that environment at first).

Then use the controls to see what it takes
to beat that bot manually.  When you can articulate
that as a strategy, you can write a bot to try to
encode that strategy and see how it works.

## Game structure:

* Each Tank starts with 1000 energy
* doing nothing costs 1 energy (batteries run down over time)
* moving costs 2 energy
* shooting costs 10 energy
* getting hit by a laser loses 150 energy
* picking up a battery gains back 80 energy (max 1000)
* going below 0 causes your tank to be "tagged" and it stops
* last tank with energy wins
* lasers that strike each other cancel out
* When the game is over, hold down the "ENTER" key to run the same game again with new random seed.

## Leaderboard (statistics)

any individual match is interesting, but what's really neat is to see how bots compete
over time.  To watch an ongoing leaderboard develop, add all the bots you
want to see matched with each other to the initial bots array in game.rb
and set IN_STATS_MODE to true.  It will then run indefinitely,
each game picking 2 bots at random and keeping track of which one wins
(periodically dumping that information to a json file, and keeping a leaderboard
  on the game interface itself).

## Training QBots

There are reinforcement learning bots available to play with in "src/lib/qbots".
At the moment their q_matrixes are abstracted to reduce dimensionality, so
there are basically human hints built into their weight structure, but it's
still neat to watch them learn.  To try one, comment out all the other bots
and include just a Q-learning bot and it's named oponent (like BoringBot and BoringQBot).

at the top of game.rb set IN_TRAINING = true, and choose your epoch count (LEARNING_EPOCHS).  The
game will run much faster as it uses a faster tick, and it will run through that many game
iterations, dumping the current bot's weights as it goes after each epoch.  Over time
the exploration rate will go down and the bot should converge on a working strategy
for defeating it's opponent.

Once a QBot seems to be performing ok in test trials, if you set IN_TRAINING to false
in game.rb and run again you can watch it perform strictly to the policy it learned
(no more exploration), and the results are pretty interesting.  trained weights
for some are stored in the weights directory and will be loaded automatically, delete
those files if you want to watch them train from scratch.
