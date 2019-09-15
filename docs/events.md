# Event system, introduction to transducers

Moon provides a mixin called `Eventable` that provides a sophisticated system of
event streams in order to make it easier to decouple logic and completely get
rid of polling.

To use Eventable in your custom class, all you need to do is include it, and
call the initializer:

```ruby
class Obj
  include Moon::Eventable

  def initialize
    initialize_eventable
    # ...
  end
end
```

Now your object will support defining callbacks for event types and triggering
events:

```ruby
obj = Obj.new

obj.on :eureka do
  puts "I just had an awesome idea!"
end

obj.trigger(:eureka)

```

# Using transducers as pipelines

Sometimes, simply triggering events is not enough. We might require to build
complex pipelines that will keep track of event state, or that will completely
transform the incoming events. Luckily, the `#on` method takes an optional
argument with a transducing step function to run on the incoming events:

```ruby
# gate filter

def gate(opener, closer)
  open = false
  return -> (e) {
    open = true if e.type == opener
      open = false if e.type == closer
      return open
  }
end

def type(sym)
  filtering {|event| event.type == sym }
end

ch = compose(
  # Only allow through when mouse has been down
  filtering(&gate(:mousedown, :mouseup)),
  # Filter by e.type === 'mousemove'
  type(:mousemove),
  # e -> [type, x, y]
  mapping { |e| [e.type, e.x, e.y] }
)


# Listen for relevant events
obj.on [:mousemove, :mouseup, :mousedown], ch do |e|
  puts "Got a dragging event! #{e}"
  trigger :dragging, self # generates a new event
end

trigger(Event.new(:mousemove, nil, 10, 20))
trigger(Event.new(:mousedown))
trigger(Event.new(:mousemove, nil, 12, 20))
trigger(Event.new(:mousemove, nil, 14, 20))
trigger(Event.new(:mouseup))
trigger(Event.new(:mousemove, nil, 16, 20))
trigger(Event.new(:mousemove, nil, 18, 20))

```


# using with children, event bubbling

