{SpaceBrush} = require './main.coffee'

class Spacecraft extends SpaceBrush
  @content: (params) ->
    @h1 params.title
    @ol outlet: 'spacecraftList', ['updateList'], =>
      @li name for name in params.spacecrafts

  initialize: (params) ->
    @model = params
    @addObjectObserver('logChange')

  updateList: (changes) ->
    for change in changes
      if change.name is 'spacecrafts'
        console.log 'Updating list'
        @spacecraftList.innerHTML = ''
        for name in @model.spacecrafts
          li = document.createElement('li')
          name = document.createTextNode(name)
          li.appendChild(name)
          @spacecraftList.appendChild(li)

  logChange: ->
    console.log "Model changed!"

view = new Spacecraft(title: "Spacecrafts", spacecrafts: ["Apollo I", "Apollo II"])
document.body.appendChild(view.el)
view.model.spacecrafts = ["Apollo III", "Apollo IV"]
