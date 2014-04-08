Feature: Key value store

  Background: Git storage

  Scenario Outline: store a value identified by a key
    Given a key "<key>"
    And a value "<value>"
    When store the value under the key
    Then the value under "<key>" is "<value>"
  Examples:
    | key  | value       |
    | key  | value       |
    | plop | bla bla bla |
