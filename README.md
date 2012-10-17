## Quick Start

Initialize with a block of code:

```ruby
foo_generator = Stepladder::Worker.new { "foo" }

foo_generator.ask #=> "foo"
```

Initialize with a block of code and an injected value:

```ruby
evens = Stepladder::Worker.new(0) { |value| value += 2 }

evens.ask #=> 0
evens.ask #=> 2
evens.ask #=> 4
```

Or just override the mutator:

```ruby
hulk = Stepladder::Worker.new

def hulk.mutator(value)
  "smash!"
end

hulk.ask #=> "smash!"
```

And obviously you could do the same with a subclass:

```ruby
class Monster < Stepladder::Worker
  def mutator(value)
    "mash"
  end
end

frank = Monster.new
frank.ask #=> "mash"
```

## Stepladder: a fibrous micro framework

This framework was inspired and shamelessly plundered from Dave Thomas'
great article [Pipelines Using Fibers in Ruby
1.9](http://pragdave.blogs.pragprog.com/pragdave/2007/12/pipelines-using.html).
In particular I was really intrigued by the possibility of extremely low
coupling between a sequence of workers through the use of fibers.

## Wut?

The purpose of Stepladder is extremely loose coupling between workers in
a series.  Each worker should need to know as little as possible about
its neighbor.  Under the hood a worker uses Ruby fibers to handoff its
work product (i.e. `Fiber.yield stuff`) and to ask for something new
to work on (i.e. `supplier.resume`).

## Ok, but why is it called "Stepladder"?

This framework's name was inspired by a conversation with Tim Wingfield
in which we joked about the profusion of new frameworks in the Ruby
community.  We quickly began riffing on a fictional framework called
"Stepladder" which all the cool kids, we asserted, were (or would soon
be) using.

I have waited a long time to make that farce a reality, but hey, I take
joke frameworks very seriously.
([Really?](http://github.com/joelhelbling/really))

Hopefully we will soon know the answer to the age-old question: "How
many Ruby fibers does it take to screw in a lightbulb?"
