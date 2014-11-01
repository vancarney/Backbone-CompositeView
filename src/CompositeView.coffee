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
    childrenComplete:->
    initialize:(o)->
      @setElement o.el if o? and o.el
      @setCollection o.collection if o? and o.collection
      @__parent = o.__parent if o? and o.__parent
      if typeof @init == 'function'
        if o? then @init o else @init() 
      @createChildren()
) jQuery