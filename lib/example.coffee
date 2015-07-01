{SpaceBrush} = require './main.coffee'

class HelloView extends SpaceBrush
  @content: (params) ->
    @div =>
      @div params.greeting
      @label for: 'name', "What is your name? "
      @div =>
        @input name: 'name', outlet: 'name'
        @button click: 'sayHello', "That's My Name"
      @div outlet: "personalGreeting"

  initialize: (params) ->
    @greeting = params.greeting

  sayHello: ->
    @personalGreeting.innerHTML = "#{@greeting}, #{@name.value}"


view = new HelloView({greeting: 'Hello'})
document.body.appendChild(view)

# view.element holds <hello-view> element
# view.greeting = 'Hello'
# view.name = [Input Element]
# view.personalGreeting = [Div Element]
