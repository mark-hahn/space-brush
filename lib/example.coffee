{SpaceBrush} = require './main.coffee'

class HelloView extends SpaceBrush
  @content: ->
    @div '.sample', outlet: 'sample', =>
      @template '#msgTemplate', =>
        @h1 outlet: 'heading', "The Sample package is dead!",
      @div '#msgHost', outlet: 'msgHost', =>
        @shadow outlet: 'shadowRoot', =>
          @div outlet: 'shadow', 'Shadow Content!'
      @div outlet: 'msgDisplay'

  initialize: (params) ->
    @greeting = params.greeting

  displayMessage: (message) ->
    @templates.msgTemplate.heading.innerHTML = message
    @appendTemplate('msgTemplate', 'msgDisplay')


view = new HelloView({greeting: 'Hello'})
view.displayMessage("Sample package is alive!")
document.body.appendChild(view.el)
console.log view


# view.el holds <hello-view> element
# view.greeting = 'Hello'
# view.msgDisplay = [Div element]
# view.personalGreeting = [Div Element]
# view.shadowRoot = [Document Fragment]
# view.templates = [Object containing templates]
# view.templates[template].element = [template element]
# view.templates[template].heading = [h1 element]
