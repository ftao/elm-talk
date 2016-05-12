import Html exposing (Html, div, button)
import Html.Events exposing (onClick)
import Html.App as Html
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)
import Date exposing (Date, fromTime, hour)



main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model = {
  time: Time,
  timezone: Float
}


init : (Model, Cmd Msg)
init =
  ({time = 0, timezone = 0}, Cmd.none)



-- UPDATE


type Msg
  = Tick Time
  | SetTimeZone Float


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      ({model | time = newTime}, Cmd.none)
    SetTimeZone timezone ->
      ({model | timezone = timezone}, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick



-- VIEW


view : Model -> Html Msg
view model =
  let
    time = model.time - (model.timezone * 3600)
    hours = (fromTime time) |> hour

    angle =
      turns (Time.inMinutes time)

    handX =
      toString (50 + 40 * cos angle)

    handY =
      toString (50 + 40 * sin angle)

    angleMinute =
      turns (Time.inHours time)
      
    handMinuteX =
      toString (50 + 30 * cos angleMinute)

    handMinuteY =
      toString (50 + 30 * sin angleMinute)     

    angleHour =
      turns ((toFloat hours) / 12.0)
      
    handHourX =
      toString (50 + 20 * cos angleHour)

    handHourY =
      toString (50 + 20 * sin angleHour)     
 
      
  in
    div []
    [ div [] [ text (toString model.timezone)]
    , div [] [ text (toString hours)]
    , svg [ viewBox "0 0 100 100", width "300px" ]
        [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
        , line [ x1 "50", y1 "50", x2 handX, y2 handY, stroke "#023963" ] []
        , line [ x1 "50", y1 "50", x2 handMinuteX, y2 handMinuteY, stroke "#ffffff" ] []
        , line [ x1 "50", y1 "50", x2 handHourX, y2 handHourY, stroke "#999999" ] []
        ]
    , button [onClick (SetTimeZone (model.timezone + 1))][text "Increse Timzone"]
    ]

