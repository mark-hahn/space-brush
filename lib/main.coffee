Tags =
  'a abbr address article aside audio b bdi bdo blockquote body button canvas
   caption cite code colgroup datalist dd del details dfn dialog div dl dt em
   fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
   iframe ins kbd label legend li main map mark menu meter nav noscript object
   ol optgroup option output p pre progress q rp rt ruby s samp script section
   select shadow small span strong style sub summary sup table tbody td textarea tfoot
   th thead time title tr u ul var video area base br col command embed hr img
   input keygen link meta param source template track wbr'.split /\s+/

SelfClosingTags = {}
'area base br col command embed hr img input keygen link meta param
 source track wbr'.split(/\s+/).forEach (tag) -> SelfClosingTags[tag] = true

Events =
  'blur change click dblclick error focus input keydown
   keypress keyup load mousedown mousemove mouseout mouseover
   mouseup resize scroll select submit unload'.split /\s+/

idCounter = 0

class SpaceBrush extends HTMLElement
  @builderStack: null

  Tags.forEach (tagName) ->
    SpaceBrush[tagName] = (args...) -> @currentBuilder.tag(tagName, args...)

  # Public: Add the given subview wired to an outlet with the given name
  #
  # * `name` {String} name of the subview
  # * `view` DOM element or jQuery node subview
  @subview: (name, view) ->
    @currentBuilder.subview(name, view)

  # Public: Add a text node with the given text content
  #
  # * `string` {String} text contents of the node
  @text: (string) -> @currentBuilder.text(string)

  # Public: Add a new tag with the given name
  #
  # * `tagName` {String} name of the tag like 'li', etc
  # * `args...` other arguments
  @tag: (tagName, args...) -> @currentBuilder.tag(tagName, args...)

  # Public: Add new child DOM nodes from the given raw HTML string.
  #
  # * `string` {String} HTML content
  @raw: (string) -> @currentBuilder.raw(string)

  @pushBuilder: ->
    builder = new Builder
    @builderStack ?= []
    @builderStack.push(builder)
    @currentBuilder = builder

  @popBuilder: ->
    @currentBuilder = @builderStack[@builderStack.length - 2]
    @builderStack.pop()

  @buildHtml: (fn) ->
    @pushBuilder()
    fn.call(this)
    [html, postProcessingSteps, observers] = @popBuilder().buildHtml()

  @render: (fn) ->
    [html, postProcessingSteps, observers] = @buildHtml(fn)
    div = document.createElement('div')
    div.innerHTML = html
    shadows = div.getElementsByTagName('shadow')
    for shadow in shadows
      root = shadow.parentNode.createShadowRoot()
      root.innerHTML = shadow.innerHTML
      shadow.parentNode.removeChild(shadow)
    fragment = div.childNodes
    step(fragment) for step in postProcessingSteps
    fragment

  el: null
  templates: null
  fastdom: null
  model: null
  observers: []

  constructor: (args...) ->
    [html, postProcessingSteps, observers] = @constructor.buildHtml -> @content(args...)
    @attached = => @attached?()
    @detached = => @detached?()
    @fastdom = require 'fastdom'
    dashName = this.constructor.name.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-')
    .toLowerCase()
    customElement = document.createElement(dashName)
    customElement.innerHTML = html
    # populate shadow roots
    shadows = customElement.getElementsByTagName('shadow')
    for shadow in shadows
      root = shadow.parentNode.createShadowRoot()
      @fastdom.write =>
        root.innerHTML = shadow.innerHTML
        @wireOutlets(this, root)
        @bindEventHandlers(this, root)
      if shadow.hasAttribute('outlet')
        this[shadow.getAttribute('outlet')] = root
      shadow.parentNode.removeChild(shadow)
    # get templates
    templates = customElement.getElementsByTagName('template')
    @templates = {} if templates.length > 0
    for template in templates
      content = template
      @templates[template.id] = {}
      @templates[template.id]['element'] = template
      @wireOutlets(@templates[template.id], template.content)
    step(customElement) for step in postProcessingSteps
    @el = customElement
    @wireOutlets(this, @el)
    @bindEventHandlers(this, @el)
    if postProcessingSteps?
      step(this) for step in postProcessingSteps
    @initialize?(args...)
    for observer in observers
      @addObjectObserver(observer[0])
    @attachObservers()

  prepend: (spacebrush) ->
    @fastdom.write =>
      @el.innerHTML = spacebrush.el.innerHTML + @el.innerHTML

  append: (spacebrush) ->
    @fastdom.write =>
      @el.appendChild(spacebrush.el)

  text: (content) ->


  val: (value) ->

  appendTemplate: (template, outlet, model) ->
    @fastdom.read =>
      content = @templates[template]['element'].content.cloneNode(true)
      div = document.createElement('div')
      @fastdom.write =>
        div.appendChild(content)
        this[outlet].innerHTML = this[outlet].innerHTML + div.innerHTML

  attachObservers: ->
    Object.observe @model, (changes) =>
      for fn in @observers
        this[fn](changes)

  addObjectObserver: (callback) ->
    @observers.push(callback)

  buildHtml: (params) ->
    @constructor.builder = new Builder
    @constructor.content(params)
    [html, postProcessingSteps, observers] = @constructor.builder.buildHtml()
    @constructor.builder = null
    postProcessingSteps

  wireOutlets: (view, el) ->
    for element in el.querySelectorAll('[outlet]')
      outlet = element.getAttribute('outlet')
      view[outlet] = element
      element.removeAttribute('outlet')

    undefined

  bindEventHandlers: (view, el) ->
    for eventName in Events
      selector = "[#{eventName}]"
      for element in el.querySelectorAll(selector)
        do (element) ->
          methodName = element.getAttribute(eventName)
          element.addEventListener eventName, (event) -> view[methodName](event, element)
      if typeof(el) is not 'function' and el.matches(selector)
        methodName = view.element.getAttribute(eventName)
        do (methodName) ->
          view.addEventListener eventName, (event) -> view[methodName](event, view)
    undefined

  end: ->
    @prevObject ? null

class Builder
  constructor: ->
    @document = []
    @postProcessingSteps = []
    @observers = []

  buildHtml: ->
    [@document.join(''), @postProcessingSteps, @observers]

  tag: (name, args...) ->
    options = @extractOptions(args)
    @openTag(name, options.attributes)
    if options.observer
      for observer in options.observer
        @observers.push(observer)
    if SelfClosingTags.hasOwnProperty(name)
      if options.text? or options.content?
        throw new Error("Self-closing tag #{name} cannot have text or content")
    else
      options.content?()
      @text(options.text) if options.text
      @closeTag(name)

  openTag: (name, attributes) ->
    attributePairs =
      for attributeName, value of attributes
        "#{attributeName}=\"#{value}\""

    attributesString =
      if attributePairs.length
        " " + attributePairs.join(" ")
      else
        ""

    @document.push "<#{name}#{attributesString}>"

  closeTag: (name) ->
    @document.push "</#{name}>"

  text: (string) ->
    escapedString = string
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')

    @document.push escapedString

  raw: (string) ->
    @document.push string

  subview: (outletName, subview) ->
    subviewId = "subview-#{++idCounter}"
    @tag 'div', id: subviewId
    @postProcessingSteps.push (view) ->
      view[outletName] = subview
      subview.parentView = view
      view.find("div##{subviewId}").replaceWith(subview)

  extractOptions: (args) ->
    options = {}
    options.attributes = {}
    attributes = {}
    observers = []
    for arg in args
      switch typeof(arg)
        when 'function'
          options.content = arg
        when 'string', 'number'
          if arg.toString().substring(0, 1) is "."
            attributes.class = arg.toString().substring(1, arg.toString().length)
          else if arg.toString().substring(0, 1) is "#"
            attributes.id = arg.toString().substring(1, arg.toString().length)
          else
            options.text = arg.toString()
        else
          if arg instanceof Array
            observers.push(arg)
          else
            options.attributes = arg
    options.attributes.class = attributes.class if attributes.class
    options.attributes.id = attributes.id if attributes.id
    if observers.length > 0
      options.observer = observers
    options

# Exports

exports.SpaceBrush = SpaceBrush
exports.$P = (fn) -> SpaceBrush.render.call(SpaceBrush, fn)
