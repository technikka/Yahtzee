# Yahtzee

A command-line implementation of the classic dice game written in Ruby. Players roll, hold, and score dice over thirteen rounds while following the traditional Yahtzee ruleset.

Originally developed while learning object-oriented programming in Ruby, the project provided practice designing game logic, modeling game state, and building an interactive terminal application.

## Features

- Complete implementation of the traditional Yahtzee scoring system.
- Interactive command-line gameplay.
- Roll and hold dice between throws.
- Dynamic scorecard with score validation.
- Turn-based gameplay across thirteen rounds.

## Technologies

- Ruby

## Gameplay

When prompted, enter one of the following commands:

|Command|Description|
|---|---|
|`roll`|Roll the unheld dice.|
|`roll all`|Roll all five dice.|
|`hold <indices>`|Hold the selected dice (e.g. `hold 014`).|
|`remove <indices>`|Return held dice to the roll area (e.g. `remove 014`).|
|`score <category>`|Apply a score to the selected category and end the turn.|
|`card`|Display the current scorecard.|

When selecting a scoring category, enter the corresponding number shown on the scorecard.

## What I Learned

Yahtzee was one of my earlier Ruby projects and gave me valuable experience modeling game rules and maintaining application state across many turns. Implementing the scoring system required translating a familiar board game into code while keeping the gameplay intuitive from a command-line interface.

The project also reinforced the importance of organizing object-oriented code around clear responsibilities, an approach that continued to influence my later projects.