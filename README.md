# SpaceBrush

** Currently in Production **

## Write markup on the final frontier

SpaceBrush is a powerful but minimalistic client-side view framework for
CoffeeScript. It combines the "view" and "controller" into a single SpaceBrush
object, whose markup is expressed with an embedded DSL similar to Markaby for
Ruby.

## Basics

View objects extend from the View class and have a @content class method where
you express their HTML contents with an embedded markup DSL:

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: ->
    @h1 "Spacecrafts"
    @ol =>
      @li "Apollo"
      @li "Soyuz"
```
Views descend from HTMLElement's prototype, so when you construct one the element will be converted into a custom element.

``` html
<spacecraft-list>
  <h1>Spacecrafts</h1>
  <ol>
    <li>Apollo</li>
    <li>Soyuz</li>
  </ol>
</spacecraft-list>
```

SpaceBrush comes equipped with helper methods similar to that of jQuery without the whole library. These include:

- `append(spacebrush)`
- `prepend(spacebrush)`
- `find(elementQuery)`
- `on(event, [elementQuery], callback)`
- `text([string])`
- `val([value])`
- `remove()`
- `hide()`
- `show()`

```coffeescript
view = new SpacecraftList
view.find('ol').append('<li>Star Destroyer</li>')
view.prepend('<input type="text" id="input" value="">')
input = view.find('#input')
input.hide()
input.remove()
view.on 'click', 'li', ->
  alert "They clicked on #{$(this).text()}"
```

But SpacePen views are more powerful than normal jQuery fragments because they
let you define custom methods:

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: -> ...

  addSpacecraft: (name) ->
    @find('ol').append "<li>#{name}</li>"


view = new SpacecraftList
view.addSpacecraft "Enterprise"
```

You can also pass arguments on construction, which get passed to both the
`@content` method and the view's constructor.

```coffeescript
class SpacecraftList extends SpashBrush
  @content: (params) ->
    @h1 params.title
    @ol =>
      @li name for name in params.spacecraft

view = new SpacecraftList(title: "Space Weapons", spacecraft: ["TIE Fighter", "Death Star", "Warbird"])
```

Methods from the SpaceBrush prototype can be gracefully overridden using `super`:

```coffeescript
class SpacecraftList extends SpashBrush
  @content: -> ...

  hide: ->
    console.log "Hiding Spacecraft List"
    super()
```

If you override the SpashBrush class's constructor, ensure you call `super`.
Alternatively, you can define an `initialize` method, which the constructor will
call for you automatically with the constructor's arguments.

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: -> ...

  initialize: (params) ->
    @title = params.title
```

## Outlets and Events

SpaceBrush will automatically create named reference for any element with an
`outlet` attribute. For example, if the `ol` element has an attribute
`outlet=list`, the SpaceBrush object will have a `list` entry pointing to a SpaceBrush
wrapper for the `ol` element.

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: ->
    @h1 "Spacecrafts"
    @ol outlet: "list", =>
      @li "Apollo"
      @li "Soyuz"
      @li "Space Shuttle"

  addSpacecraft: (name) ->
    @list.append("<li>#{name}</li>")
```

Elements can also have event name attributes whose value references a custom
method. For example, if a `button` element has an attribute
`click=launchSpacecraft`, then SpacePen will invoke the `launchSpacecraft`
method on the button's parent view when it is clicked:

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: ->
    @h1 "Spacecrafts"
    @ol =>
      @li click: 'launchSpacecraft', "Saturn V"

  launchSpacecraft: (event, element) ->
    console.log "Preparing #{element.name} for launch!"
```

## Object Binding

Two-way bindings are provided via the native Object.observe() method. The bindings be done in the declaration of the DSL Markup `[modelValue, callback]` or added via the `addObjectObserver(modelValue, callback)` method. Both methods can be used at once, even on the same property.

SpaceBrush comes with a built in model property that points to your Object model, when there are changes in the model, they will update the view according to your observers.

```coffeescript
class SpacecraftList extends SpaceBrush
  @content: (params) ->
      @h1 params.title
      @ol [@model, 'displayList'], =>
        @li name for name in params.spacecrafts

  @initialize: (spacecrafts) ->
    @model = spacecrafts
    @addObjectObserver(@model, 'logChange') - manual binding

  @displayList: (changes) ->

  @logChange: ->
    console.log "Model changed!"

```

## Markup DSL Details

### Tag Methods (`@div`, `@h1`, etc.)

As you've seen so far, the markup DSL is pretty straightforward. From the
`@content` class method or any method it calls, just invoke instance methods
named for the HTML tags you want to generate. There are 3 types of arguments you
can pass to a tag method:

* *Strings*: The string will be HTML-escaped and used as the text contents of the generated tag.

* *Hashes*: The key-value pairs will be used as the attributes of the generated tag.

* *Arrays*: Used for binding observers to object, for more information see the Binding section

* *Functions* (bound with `=>`): The function will be invoked in-between the open and closing tag to produce the HTML element's contents.

If your string begins with a `.` or `#` the string will be used for it's ID or class.

If you need to emit a non-standard tag, you can use the `@tag(name, args...)`
method to name the tag with a string:

```coffeescript
@tag 'bubble', type: "speech", => ...
```

### Text Methods

* `@text(string)`: Emits the HTML-escaped string as text wherever it is called.

* `@raw(string)`: Passes the given string through unescaped. Use this when you need to emit markup directly that was generated beforehand.

## Subviews

Subviews are a great way to make your view code more modular. The
`@subview(name, view)` method takes a name and another view object. The view
object will be inserted at the location of the call, and a reference with the
given name will be wired to it from the parent view. A `parentView` reference
will be created on the subview pointing at the parent.

```coffeescript
class Spacecraft extends SpaceBrush
  @content: (params) ->
    @div =>
      @subview 'launchController', new LaunchController(countdown: params.countdown)
      @h1 "Spacecraft"
      ...
```

## Freeform Markup Generation

You don't need a SpaceBrush class to use the SpaceBrush markup DSL. Call `SpaceBrush.render`
with an unbound function (`->`, not `=>`) that calls tag methods, and it will
return a document fragment for ad-hoc use. This method is also assigned to the
`$B` global variable for convenience.

```coffeescript
view.list.append $B ->
  @li =>
    @text "Starship"
    @em "Enterprise"
```

### Attached/Detached Hooks
The `initialize` method is always called when the view is still a detached DOM
fragment, before it is appended to the DOM. This is usually okay, but
occasionally you'll have some initialization logic that depends on the view
actually being on the DOM. For example, you may depend on applying a CSS rule
before measuring an element's height.

For these situations, use the `attached` hook. It will be called whenever your
element is actually attached to the DOM. Past versions of SpacePen would also
call this hook when your element was attached to another detached node, but that
behavior is no longer supported.

To be notified when your element is detached from the DOM, implement the
`detached` hook.

```coffeescript
class Spacecraft extends SpaceBrush
  @content: -> ...

  attached: ->
    console.log "With CSS applied, my height is", @height()

  detached: ->
    console.log "I have been detached."
```

## Hacking on SpaceBrush

```sh
git clone https://github.com/atom/space-brush.git
cd space-brush
npm install
npm start
```

* Open http://localhost:1337 to run the specs
* Open http://localhost:1337/benchmark to run the benchmarks
* Open http://localhost:1337/examples to browse the examples
