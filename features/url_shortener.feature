Feature: shorten a url

  Scenario Outline: Shorten a url
    When I short the url "<url>"
    Then the hash of the short url is "<hash>"
  Examples:
    | url                                              | hash   |
    | http://sogilis.com                               | 3Ry2EI |
    | http://google.com                                | 24RiA9 |
    | http://i-am-a.very.long/url?with=some#parameters | 4DMSba |
