# Functional Reactive Programming in Elm

note: That is the purpose of this talk, 
      Elm and Functional Reactive Programming is worth learning . 
      will not try to cover everything 
      Functional Reactive Programming 
      Elm


---


## What is Elm ? 

 > the best of functional programming in your browser

 - static typed pure functional language
 - designed for building web applictions
 - reactive by design 
 - compile to javascript


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
"ABC"
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


## Partial Apply / Function composition 

```elm
import String
threeTimes = String.repeat 3
-- <function> : String -> String

threeTimes "hi"
-- "hihihi" : String

not << isEven << sqrt
-- \n -> not (isEven (sqrt n))

sqrt >> isEven >> not
-- \n -> not (isEven (sqrt n))


```

note: used in event handler / address 


---


## Front-end web development is hard


* Frontend Web App/SPA is so complex now days!
  - Hard to build 
  - Hard to test
  - Hard to reason
* JavaScript is terriable language 


---


## Functional Reactive Programming might be the solution


---


## What is Front-end Web App  ?

Some program that 

  - query/update dom 
  - react to events (mouse/keyboard/touch)
  - read/write to browser datastore (cookie/localStorage/....)
  - talk to server  via ajax / websocket  


---


## Or ?


Some program that 

  - input 
    - user interactions (mouse, keyboard, ...)
    - server response (ajax response, websockt ...)
  - output
    - dom / ui
    - server request
    - ...


Note: everthing passed to javascript event handlers are input
      everthing browser (async) api call is output


---


<div style="background:white">
![Signal Process Network](http://elm-lang.org/assets/diagrams/overall-architecture.png)
</div>


Note: The main idea is that the vast majority of our application logic can be described in terms of the Elm Architecture, 
      allowing us to make the most of stateless functions and immutability. 
      In this realm we use signals to route events to the right place.

      When we want to have some effect on the world, we create a service totally separate from our core logic. 
      Each service may be in charge of a specific task, like managing database connections or communicating via websockets. 
      We script all of these effects with tasks.
      
      Service is not pure , which talk to outside world


---


Core Logic = Static Processing Network 
<div style="background:white">
![Signal Process Network](http://elm-lang.org/assets/diagrams/signals.png)
</div>


Note:
  You can think of signals as setting up a static processing network, 
  where a fixed set of inputs receive messages that propagate through the network, 
  ultimately leading to outputs that handle stuff like efficiently rendering things on screen.

  (Next Introduce Some Concept in order to express this)
  This part is pure functional, only the foldp has some states


---


## Signal

> A signal is a value that changes over time. 


```elm
Mouse.position : Signal (Int,Int)
```

```elm
main : Signal Html
```

Note: so we need a concept of signal


---


## Program with Signals


```elm
map : (a -> b) -> Signal a -> Signal b
filter : (a -> Bool) -> a -> Signal a -> Signal a
merge : Signal a -> Signal a -> Signal a
foldp : (a -> s -> s) -> s -> Signal a -> Signal s
```

You don't write function that operate on signal, 
You write function that operate on element of the signal.

Note: how to deal with signals ? 
      State is all about current value depends on history values


---


## Adress & Mailbox

```
type alias Mailbox a = 
    { address : Address a
    , signal : Signal a
    }
A Mailbox is a communication hub. It is made up of

an Address that you can send messages to
a Signal of messages sent to the mailbox
```


Note: How address are used ? 


---


## How Mailbox is Used ?

 * [runtime] create a mailbox on init
 * [runtime] make the `mailbox.signal` as input of the core logic
 * [core] core logic may output some __Effects__
 * [runtime] will ask the service to make the __Effects__ happen, and send the result to `mailbox.address`

Note: 
  talk about the address again in event handler, later 


---


## The Core Logic is  stateless


Note: how to write it ??


---


## The Elm Architecture

 - The Elm Architecture is a **simple** pattern for infinitely **nestable** components. 
 - It is great for **modularity, code reuse, and testing**. 
 - Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. 

note: 
  - link: https://github.com/evancz/elm-architecture-tutorial/
  - Nestable ? how to explain ? dom tree ? 
  - Modularity ? how to explain ?
  - Code Resue ? how to explain ?
  - Testing  - pure funciton, side effects as data 


---


## The Elm Architecture

```elm
-- MODEL
type alias Model = { ... }
init : (Model, Effects Action)

-- UPDATE
type Action = Reset | ...
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Reset -> ...
    ...

-- VIEW
view : Address Action -> Model -> Html
view address model =
  ...

```

note: 
  - model - application state
  - init  - application state, init action
  - view  - render model to html
  - update  - update the model for given action


---


## model

```elm
type alias Model =
  { topic : String
  , gifUrl : String
  }


init : String -> ( Model, Effects Action )
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )
```

note:  discuss Effects later 


---


## view

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ "width" => "200px" ] ]
    [ h2 [ headerStyle ] [ text model.topic ]
    , div [ imgStyle model.gifUrl ] []
    , button [ onClick address RequestMore ] [ text "More Please!" ]
    ]
```

`Signal.Address Action` = 
    an `Adress` which accept message with type `Action`.

note: 
   the address is used by __outside world__ to send action into elm land 
   address is passed in by outside world


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
      decodeResponse should return `String`
      Task.toMabye turn error into `Maybe.Nothing`
      compare to callback, the problem of callback is hard to reason, what will happen when the callback is excuted 
      here Effects.task means make effects from task


---


## Component Composition - model

```elm
type alias Model =
  { topic : String
  , gifList : List ( Int, RandomGif.Model )
  , uid : Int
  }


init : ( Model, Effects Action )
init =
  ( Model "" [] 0
  , Effects.none
  )

```


---


## Component Composition - update

```
type Action
  = Topic String
  | Create
  | SubMsg Int RandomGif.Action


update : Action -> Model -> ( Model, Effects Action )
update message model =
  case message of
    Topic topic ->
      ...
    Create ->
      ...
    SubMsg msgId msg ->
      let
        subUpdate (( id, randomGif ) as entry) =
          if id == msgId then
            let
              ( newRandomGif, fx ) =
                RandomGif.update msg randomGif
            in
              ( ( id, newRandomGif )
              , map (SubMsg id) fx
              )
          else
            ( entry, Effects.none )

        ( newGifList, fxList ) =
          model.gifList
            |> List.map subUpdate
            |> List.unzip
      in
        ( { model | gifList = newGifList }
        , batch fxList
        )

```


---


## Component Composition - view

```
view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ input
        [ placeholder "What kind of gifs do you want?"
        , value model.topic
        , onEnter address Create
        , on "input" targetValue (Signal.message address << Topic)
        ]
        []
    , div
        []
        (List.map (elementView address) model.gifList)
    ]


elementView : Signal.Address Action -> ( Int, RandomGif.Model ) -> Html
elementView address ( id, model ) =
  RandomGif.view (Signal.forwardTo address (SubMsg id)) model
```

note: 
  `forwardTo : Address b -> (a -> b) -> Address a`
  Create a new address. This address will tag each message it receives and then forward it along to some other address.
  explain sub address


---


## StartApp 

```elm
import Effects exposing (Never)
import RandomGifList exposing (init, update, view)
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

```

note: remove this slide, explain port


---


 - The Elm Architecture is a **simple** pattern for infinitely **nestable** components. 
 - It is great for **modularity, code reuse, and testing**. 
 - Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. 


note: ask the audience, do they understand the key points


---


## Any thoughts ? 

note: more discussion
  - But a lot of boilerplate code 
  - how the nested structure expressed in other language 
    html structure ? 


---


## Demo



---


## Some extend thoughts  

* Testing


Note: record all inputs / outputs


---


Links:

  * http://elm-lang.org
  * https://github.com/evancz/elm-architecture-tutorial/
