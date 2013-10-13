HyperSauce
==========

A client library for HAL+JSON APIs.

This is just a draft spec of how I think this could work. 

# Usage

Wack it in your Gemfile.

```
gem 'hypersauce'

```

Require before use.

```
require 'hypersauce'
```

Create a resource with the root path of you HAL API.

```
api = Hypersauce::Resource.new(url: 'http://www.testapi.com')
```

Access the attributes via the attributes hash.

```
api.attributes
# => {
#    title: 'Test API',
#    description: 'Used to test the Hypersauce Client'
# }
```

or via auto generated accessors.

```
api.title
# => 'Test API'
```

## Links

Access HAL links via the links hash.

```
api.links
# => {
#    self: #<Hypersauce::Link:0xABCD1234 @url="http://www.testapi.com" … >,
#    widgets: #<Hypersauce::Link:0xABCD1235 @url="http://www.testapi.com/widgets" … >
# }
```
```
api.links[:widgets]
# => #<Hypersauce::Link @url="http://localhost:9292/widgets" … >
```

Checkout the link attributes.

```
api.links[:widgets].attributes
# => {
#    href: 'http://www.testapi.com/widgets{?max_price}',
#    title: 'Widgets Collection',
#	 templated: true
# }
```

```
api.links[:widgets].templated?
# => true
```

Follow a link using the auto-generated method.

```
api.widgets
# => #<Hypersauce::Resource @url="http://www.testapi.com/widgets">
```

Provide options for templates links.

```
api.widgets(max_price: 20.0)
# => #<Hypersauce::Resource @url="http://www.testapi.com/widgets?max_price=20.0" … >
```

Chain links together!

```
api.widgets.next
# => #<Hypersauce::Resource @url="http://www.testapi.com/widgets?page=2"
```

## Embedded Resources

Access embedded resources via the 'embedded' accessor.

```
api.widgets.embedded
# => {
#   widgets: [
#		#<Hypersauce::Resource @url="http://www.testapi.com/widgets/1" … >,
#   	#<Hypersauce::Resource @url="http://www.testapi.com/widgets/2" … >,
#   	...
#	]
# }
```

Get all the embedded resources (regardless of type).

```
api.widgets.embedded.all
# => [
#	#<Hypersauce::Resource @url="http://www.testapi.com/widgets/1" … >,
#   #<Hypersauce::Resource @url="http://www.testapi.com/widgets/2" … >,
#   ...
# ]
```

Get the first (or last) embedded resource.

```
api.widgets.embedded.first
# => #<Hypersauce::Resource @url="http://www.testapi.com/widgets/1" … >
```

The embedded resources first, last and all methods are also available directly on the resource!

```
api.widgets.first
# => #<Hypersauce::Resource @url="http://www.testapi.com/widgets/1" … >
```

## Editing Objects

```
widget = api.widgets.first
# => #<Hypersauce::Resource @url="http://localhost:9292/widgets/1">

widget.name
# => 'Widget 1'

widget.name = 'New Widget Name'
widget.save
# => true

widget.name
# => 'New Widget Name'
```

## Server Validation Errors

```
widget.name = nil
widget.save
# => false

widget.errors
# => {
#   name: 'Name required'
# }

widget.name = 'New Widget Name'
widget.save
# => true

widget.errors
# => nil
```


## Creating objects

Call 'new' on a collection resource to create a new resource.

```
new_widget = api.widgets.new
# => #<Hypersauce::Resource @url="http://localhost:9292/widgets">
new_widget.is_new?
# => true
new_widget.name = 'Another Widget'
# OR
new_widget = api.widgets.new(name: 'Another Widget')
new_widget.save
# => true
new_widget
# => #<Hypersauce::Resource @url="http://localhost:9292/widgets/3">
```


## Resource Subclasses

You can also create Hypersause::Resource subclasses.
 
Note: I'm not sure how I'll figure out which subclass to create yet. It will probably be based on the link type/rel.

```
class TestApi < Hypersauce::Resource
  def initialize(url)
    super(url: url)
  end
end

class Widget < Hypersauce::Resource
  def to_s
  	"#{name} - Price $#{price}"
  end
end
```

```
api = TestApi.new('http://www.testapi.com')
widget = api.widgets.first
# => #<Widget @url="http://www.testapi.com/widgets/1" … >

widget.to_s
# => "Widget 1 - Price: $20.0"
```













