
## Space-Brush, a reactive coffeescript HTML DSL for Atom

Space Brush is a successor to space-pen. The name brush comes from it giving a much wider brush of capabilities. This doc assumes that the the reader is well-versed in the original space-pen and space-pen-views.

### Features

- **Simple**  Inherits the original Atom space-pen philosophy.  This means that brief code can be simple and expressive.

- **Modern**  Supports web components such as custom elements, templates, and DOM shadowing.

- **Like space-pen** Coffeescript is leveraged as much as possible as a DSL.  Javascript could be used but it would be verbose and hard to write/maintain.

- **No logic in HTML** All logic is in the model object and code with nothing in the view.  The pure html is not spoiled with injected logic.

- **Easy bindings** Two-way bindings are provided with plain old javascript objects. The binding is very fast with no polling since `Object.observe` is used.  The bindings can be purely declarative with a direct link from the DOM to the model object, or programmatic with code acting as a go-between as in the old space pen. Both methods can be used at once, even on the same property.

- **Choice of MV or MVC**   Declarative can be thought of as MV, model-view, and the programmatic can be thought of as MVC, model-view-control, where the programmatic code is the controller.  These can co-exist without any confusion.

- **No jQuery**  JQuery is not a dependency.  It should be pointed out that jQuery-like programmatic access is still supported by using native DOM access functions.  Space-brush makes it easy for jQuery users to transition from a programmatic to declarative idiom at their own pace.

### Status:

  A proposal spec only.  Implementation to come.

### Web componenets

- Custom elements are specified with a space-brush function `@customElement`.  It has one argument that is a class constructor and an optional second argument that is the name of a parent element tag. The class's prototype is cloned onto the custom element's prototype so it defines the element's properties.  The element's tag name created is the dashed version of the class's upper camel case name.  E.g. `MyEle` is converted to the element tag `my-ele`.

- The `@customElement` call can be placed anywhere in a space-pen html tree but the recommended place is at the top as a sibling of, and before, the html root div. It must precede any usage of the element tag it creates. It has no return value and doesn't create anything in the DOM. It may not include a function as an argument.

- A custom element is used as any other element like `@div`, but using the camel-case version of the class name. E.g. `@myEle ...` generates the html `<my-ele ...`.

- `<template>` is supported via a standard `@template`. Standard space-pen html is nested in the `@template` which can be placed anywhere in the tree, including the top level.

- The javascript needed to make an element a shadow root, `.createShadowRoot()`, is provided transparently.  The element to host a shadow has a special attribute named `_template` with its value as the id of the template.  

### Bindings

- Bindings are specified in the space-brush DSL by the use of arrays just as attributes are specified by hashes.  Luckily space-pen didn't use arrays in the DSL so they are available.  In the simplest form an array can be substituted for attribute values, text content, or even elements themselves.  

- Binding syntax is a string within an array like `['foo']` or `['.foo.bar']`.  The former defines a variable accessor similar to space-pen's `outlet:`. This is used for the programmatic access method.  The latter is a key path that directly connects the DOM value to the model object.

- An accessor function is a space-brush function that enables setting and getting values to/from the DOM.  E.g. the accessor created by `@input value:['foo'] ...` is used in the code like `@foo`.  Setting the value looks like `@foo('bar')` and getting looks like `val = @foo()`.   

- The declarative method uses a path key that specifies the location in the model object.  `@input value:['.foo.bar`] ...` means the input value is tightly bound to `model.foo.bar` where model is the default model object.  Any change to one changes the other.

### Conditional logic

- An element itself can be bound by including an array as an argument.  The syntax is `@div ['myEle'], ...`.  Conditional showing and hiding the element is controlled by the value of the bound variable.  If the value is "truthy" then the element is shown and if "falsey" the element is hidden.

### Repetition logic

- The syntax for repetition of an element is the same as condition.  The element is repeated if the bound value is a number.  The element can be repeated zero or more times.  Note that a value of zero and  one are redundant with the conditional logic but luckily `0` means hidden and `1` means shown when thinking of them as either conditions or repetitions.

- Note that both the condition and repetition logic are controlled outside of the HTML in code.  The DSL semantics are pure presentation.

### Arrays

- If the bound value is an array then the element if repeated once for each item in the array.  The array item can be an object which then becomes the model for the DOM subtree of that element.


### Javascript

- There are no globals created by space-brush.  This will be managed by either namespacing all of the view or by putting the entire view in a shadow DOM. This has not been decided.

- There is a space-brush function `$P` that renders space-brush code outside of the `@content: ->` property.  It replaces the space pen `$$`.  The `$` looks like an `S` so `$P` is an acronym for space-brush.

### jQuery and the lack thereof

- The code outside of the space-brush DSL has to use native DOM functions or provide its own jQuery which means it needs to do either `@ele().textContent = 'hello'` or `$(@ele()).text('hello')`.

### Add-on features

- If an element's first argument is a string with a specific format then that string specifies the `id` and `class` replacing the need for those attributes.  This is stolen from teacup.  An example is ...

         @div '#id.class1.class2'
    
### Examples

These will be provided in a separate doc which has not been written yet.

