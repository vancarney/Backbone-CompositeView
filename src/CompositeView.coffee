#### global
# > References the root environment RikkiTikki is operating in
global = exports ? window
# Includes Backbone & Underscore if the environment is NodeJS
_         = (unless typeof exports is 'undefined' then require 'underscore' else global)._
Backbone  = unless typeof exports is 'undefined' then require 'backbone' else global.Backbone
(($)->
  class Backbone.CompositeView extends Backbone.View 
    collection: null
    __children: []
    __parent:   null
    createChildren:->
      if typeof @subviews != 'undefined' and @subviews? and _.isObject @subviews
        _.each @subviews, ((view, selector)=>
          return if typeof view == 'undefined'
          _.each (@$el.find selector), (v,k)=>
            @__children.push (@[selector] = new view
              el: v
              __parent:@
            )
        )
        @delegateEvents()
      @childrenComplete()
      @render()
    getElement:->
      @$el
    setElement:(el)->
      @$el = $(@el = el) if el
      @delegateEvents()
      @
    setCollection:(c)->
      @__collection.off "change reset add remove" if @__collection
      (@__collection = c).on "change reset add remove", @render, @
      @
    getCollection:->
      @__collection
    getChildren:->
      @__children
    getChild:(sel)->
      return throw 'clazz must be type <Function>' unless typeof clazz is 'function'
      @__children[sel] || null
    addChild:(sel,clazz,opts)->
      return throw 'clazz must be type <Function>' unless typeof clazz is 'function'
      @subviews[sel] = clazz
      @createChildren() unless opts?.create? and opts.create == false
      @
    removeChild:(sel,opts)->
      return unless sel
      if typeof sel is 'string'
        if @__children[sel]?
          @__children[sel].remove()
          delete @__children[sel]
      else
        throw 'param sel must be CSS Selector String'
      @
    replaceChild:(sel,clazz)->
      return throw 'param sel must be CSS Selector String' unless sel? and typeof sel is 'string'
      @__children[sel] = clazz if typeof sel is 'string' and clazz instanceof Backbone.View
      @
    removeAllChildren:->
      _.each _.keys( @__children  ), (v)=>
        @[v].remove()
        delete @[v]
        delete @__children[v]
      @
    childrenComplete:->
      @
    initialize:(o)->
      _.extend @, Backbone.Events
      @setElement o.el if o? and o.el
      @setCollection o.collection if o? and o.collection
      @__parent = o.__parent if o? and o.__parent
      if typeof @init == 'function'
        if o? then @init o else @init() 
      @createChildren()
) jQuery