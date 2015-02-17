
############  Old package-generator code

  constructor: (serializeState) ->
    @element = document.createElement('div')
    @element.classList.add('sample')

    message = document.createElement('div')
    message.textContent = "The Sample package is Alive! It's ALIVE!"
    message.classList.add('message')
    @element.appendChild(message)


############ New space-brush code that replaces the old package-generator code above

  @content: ->
    @div '.sample', =>
      @div '.message', "The Sample package is Alive! It's ALIVE!"
    
    
############ this space-brush code shows ES6 templates and shadows

  @content: ->
    @div '.sample', outlet: 'sample', =>
    
      @template '#msgTemplate', =>
        @h1 "The Sample package is ", => @content()
        
      @div '#msgHost', _shadow: "#msgTemplate", 'Alive!'
    
    
############ this space-brush code shows declarative declarative reactive binding

  # model file
  @modelPOJO = 
    firstName: 'Albert'
    lastName:  'Einstein'
    dates:
      born: 'March 14, 1879'
      died: 'April 18, 1955'
      
  # view file
  @content: ->
    @div =>
      @div 'Bio for ', =>
        @input ['.firstName']
        @input ['.lastName']
      @br()
      @div 'Born: ', => @input ['.dates.born']
      @div 'Died: ', => @input ['.dates.died']
      
  @initialize: ->
    @model  @modelFile.modelPOJO
      
      
############ space-brush code with programmatic binding

  # model file
  @modelPOJO = 
    firstName: 'Albert'
    lastName:  'Einstein'
    dates:
      born: 'March 14, 1879'
      died: 'April 18, 1955'
      
  # view file
  @content: ->
    @div =>
      @div 'Bio for ', =>
        @input ['firstName']
        @input ['lastName']
      @br()
      @div 'Born: ', => @input ['dateBorn']
      @div 'Died" ', => @input ['dateDied']
      
    
  @initialize: ->
      model = @modelFile.modelPOJO
      
      @firstName model.firstName
      @lastName  model.lastName
      @dateBorn  model.dates.born
      @dateDied  model.dates.died
      
      @.on 'change', (e) => 
        model.firstName  = @firstName()
        model.lastName   = @lastName()
        model.dates.born = @dateBorn()
        model.dates.died = @dateDied()

        
############ space-brush code with conditions

  @modelPOJO = 
    firstName: 'Albert'
    lastName:  'Einstein'
    dates:
      born: 'March 14, 1879'
      died: 'April 18, 1955'
    show:
      name:  yes
      nates: yes
    
  @content: ->
    @div =>
      @div ['.show.name'], 'Bio for ', =>
        @input ['.firstName']
        @input ['.lastName']
      @br()
      @div ['.show.dates'], =>
        @div 'Born: ', => @input ['.dates.born']
        @div 'Died: ', => @input ['.dates.died']
        
        
############ space-brush code with repetition
    
  @modelPOJO = 
    presidents: [
      name: 'Washington'
      name: 'Jefferson'
      name: 'Lincoln'
    ]
  
  @content: ->
    @div =>
      @div ['.presidents'], =>
        @span 'Name: '; @span ['.name']; @br()
        