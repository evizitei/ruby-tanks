# Ruby Tanks

This is a fun program written for Bring Your Kids To Work day
at Udacity, 2017.  The point is to help kids see what a software engineer
does by seeing how they figure out what they want the computer to do,
and then how to tell the computer to do it.

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
