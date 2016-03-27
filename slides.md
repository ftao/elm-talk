# Functional Reactive Programming in Elm


---


## Contents

 * What is Elm
 * Elm Basics
 * The Elm Architecture 
 * Functional Reactive Programming
 * Is it ready for real world product 
 * Real world Example
 * Why Elm ? 
 * QA


note: We do not need introduce Signal / Effect in The Elm Architecture 

---


## What is Elm ? 

 >> the best of functional programming in your browser

 - static typed pure functional programing language
 - designed for building web applictions
 - builtin *reactivity*
 - compile to javascript
 - First Order FRP


---


## Elm Basics

 * Int / Float / Bool / Char / String
 * Tuple 
 * List
 * Union Types
 * Records

note: only introduce the part that needed for elm-architecture

---


## Basic Types

```elm
13
13.0
True
'a'
'ABC'
[1, 2, 3]
('A', True)
```


---

## Union Types

```elm
type User = Anonymous | LoggedIn String
type Maybe a = Just a | Nothing
type List a = Empty | Node a (List a)

userPhoto : User -> String
userPhoto user =
    case user of
      Anonymous ->
          "anon.png"

      LoggedIn name ->
          "users/" ++ name ++ "/photo.png"

```

note: type is used to make contracts
  union types can be used to exporess complex contracts
  http://elm-lang.org/guide/model-the-problem


---


## Records

```elm
point =                    -- create a record
  { x = 3, y = 4 }

point.x                    -- access field

map .x [point,{x=0,y=0}]   -- field access function

{ point | x = 6 }          -- update a field

{ point |                  -- update many fields
    x = point.x + 1,
    y = point.y + 1
}

dist {x,y} =               -- pattern matching on fields
  sqrt (x^2 + y^2)

type alias Location =      -- type aliases for records
  { line : Int
  , column : Int
  }
```


note: 
  like object, not dict, more like c struct 
  http://elm-lang.org/docs/records


---


## Define Functions

```elm
square n =
  n^2

hypotenuse a b =
  sqrt (square a + square b)

distance (a,b) (x,y) =
  hypotenuse (a-x) (b-y)

(?) : Maybe a -> a -> a
(?) maybe default =
  Maybe.withDefault default maybe

infixr 9 ?

\x = x * 2
```

---


## Apply Functions

```elm
-- alias for appending lists and two lists
append xs ys = xs ++ ys
xs = [1,2,3]
ys = [4,5,6]

-- All of the following expressions are equivalent:
a1 = append xs ys
a2 = (++) xs ys

b1 = xs `append` ys
b2 = xs ++ ys

c1 = (append xs) ys
c2 = ((++) xs) ys
```


---


## Apply Functions

```elm

f <| x = f x
x |> f = f x

dot =
  scale 2 (move (20,20) (filled blue (circle 10)))

dot' =
  circle 10
    |> filled blue
    |> move (20,20)
    |> scale 2
```


---


## Currying / Partial Apply

```elm
import String
threeTimes = String.repeat 3
-- <function> : String -> String

threeTimes "hi"
-- "hihihi" : String
```

note: used in event handler / address 


---


## The Elm Architecture

  The Elm Architecture is a **simple** pattern for infinitely **nestable** components. 
  It is great for **modularity, code reuse, and testing**. 
  Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. 


---


Every component look the same way

 * model - application state
 * view  - render model to html
 * update  - update the model for given action

note: https://github.com/evancz/elm-architecture-tutorial/


---


```elm
-- MODEL

type alias Model = { ... }


-- UPDATE

type Action = Reset | ...

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Reset -> ...
    ...

-- VIEW

view : Address Action -> Model -> Html
view =
  ...
```

---

## Side Effects as Data

```elm
update : Action -> Model -> (Model, Effects Action)
```

Effects is a piece of **data** which describe the "side effects".

For example: 

```elm
type Action
    = RequestMore
    | NewGif (Maybe String)

Http.get decodeResponse (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task
```


note: example http request, should be 
      when the side effects finished, the runtime will send a `Action` update back. 

---

## view

```elm
type Action = Increment | Decrement

-- view 
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [ onClick address Decrement ] [ text "-" ]
    , div [ ] [ text (toString model) ]
    , button [ onClick address Increment ] [ text "+" ]
    ]
```

`Signal.Address Action` = 
    an `Adress` which accept message with type `Action`.


---


![elm-architecture](https://raw.githubusercontent.com/evancz/elm-architecture-tutorial/master/diagrams/signal-graph-summary.png)


---


## Component Composition - model

```elm

type alias Model =
    { todoList : List (Int, Todo.Model)
    , uid : Int
    , newTodo: String
    }

init = 
  ( { todoList : []
    , uid : 0
    , newTodo: ""
    } 
  , Effects.None
  )

```


---


## Component Composition - update

```
type Action 
  = Create
  | SubMsg Int Todo.Action

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Create -> ...
    SubMsg id action ->
      let
        subModel, subEffect = Todo.update action (getById id model.todoList)
      in
        ( { model | todoList = setById id subModel model.todoList }
        , Effects.map (SubMsg id) subEffect
        )

```


---


## Component Composition - view

```
view : Signal.Address Action -> Model -> Html
view address model =
  let 
     todoList = model.todoList |>  renderTodo
  in 
    div [ style [ ("display", "flex") ] ]
        todoList 

renderTodo address (id, model) =
  let 
    subAddress = Signal.forwardTo address (SubMsg id)
  in 
    Todo.view subAddress model
  
```

note: explain sub address


---


## StartApp 

```elm
import TodoList exposing (init, update, view)
import StartApp

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

main =
  app.html

```

---


 - The Elm Architecture is a **simple** pattern for infinitely **nestable** components. 
 - It is great for **modularity, code reuse, and testing**. 
 - Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. 


---


## What's Great about this ? 

 - It's Simple 
 - Easy to navigate the codebase 
 - Easy to debug, easy to locate the possible bug location 


NEED UPDATE 

 - It is quite simple 
 - But a lot of boilerplate code 


note: do we need write similiar code in other framework / language
   in oo, we build the tree of component, 
   in javascript ? html ? the nested is express in template language / html
   many time 


---


## Behind the Magic 

Signal Process Network 


---


## Why Elm ? 

easy to understand / easy to reason / reduce complex 
how many time do you speed in understand old code


---


Links:

  * https://github.com/evancz/elm-architecture-tutorial/
  * https://gist.github.com/staltz/868e7e9bc2a7b8c1f754
