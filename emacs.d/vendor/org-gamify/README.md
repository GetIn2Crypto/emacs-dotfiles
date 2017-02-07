# Org-gamify

**Synopsis:** Org-agenda module for turning task management into a game.

## What is gamification? ##

*Gamification* refers to the use, in real life, of the sorts of motivational
systems that are typically present in games (especially videogames). Examples
of such motivational systems include the accrual of "points" or virtual
currency, earning achievements or badges, "levelling up", collecting sets of
virtual items, competing against other people to rise to the top of
leaderboards, and so on.

Some people find themselves motivated by these systems when they encounter them
in real life settings, just as some people are motivated by them in the context
of games.

A recent book that portrays gamification in a positive light is "Reality is
Broken" by Jane McGonigal.

Gamification has been applied in a variety of areas including marketing,
education and training, fitness, social networks, and task management. Some
example implementations of the latter:

-   [HabitRPG](http://habitrpg.com) (Web, iOS, Android)
-   [Epic Win](http://www.rexbox.co.uk/epicwin/) (iOS)
-   [Chore Wars](http://www.chorewars.com) (Web)
-   [Todoist](http://www.todoist.com/karma) ("karma" feature)

### Criticisms ###

Gamification has been criticised as manipulative and exploitative. I don't
think gamification has these properties inherently, but it is certainly
possible to use gamification in harmful ways.

Some criticisms:

-   Gamification provides a way to manipulate people into doing things they would
    not otherwise want to do.
-   A proportion of people will become addicted to gamification systems (this is
    probably unavoidable, but you can avoid having a business model that revolves
    around causing addiction).

## Why did I write this, and why should you try it? ##

I encountered some of the gamified task management systems listed above, and
found the concept intriguing. However I decided against using them, because (1)
they would lock my task data into a closed proprietary database, and (2) their
underlying task management system is quite primitive. I had used the task
management aspects of Org mode intermittently in the past, and have written an
extension for org mode (`org-drill`), so am familiar with its API. I decided to
write a theme-agnostic "gamification" extension for Org mode which would allow
users to add HabitRPG-like functionality to their Org mode task management
systems.

I wrote `org-gamify` as a fairly flexible library. Basic currency costs and
rewards can be implemented without any elisp programming knowledge (beyond
defining currencies). Arbitrarily complex systems can be created if the user is
willing to write some elisp. Unlike HabitRPG and Epic Win, it is unthemed,
leaving users free to design "fantasy", "sci-fi", "sports" or other themes if
they wish.

Trying `org-gamify` might be worthwhile even if you don't continue with it, as
it makes you think about rewards -- things you enjoy -- and it makes you
quantify how much enjoyment you get from them, compared with how much effort
you expend on chores. Most existing task management systems completely ignore
the concept of rewards.

## How it works ##

The user defines one or more currencies using the macro
`define-gamify-currency`. Each currency can have a name, minimum and maximum
allowed values, a category, custom functions that run after its balance is
increased or decreased, and some appearance options such as a custom icon.

The balance of each of these currencies is stored in the global variable
`org-gamify-inventory`. This variable is saved between Emacs sessions. The
balances of all currencies can be viewed using the interactive command
`M-x org-gamify-show-inventory`.

Within the agenda, any task can be given a property `CURRENCY_DELTAS`, whose
value must be a list. Each member of this list takes the form `(CURRENCY
CHANGE)` where `CURRENCY` is the name of a defined currency (a symbol), and
`CHANGE` is a positive or negative number.

When a task's todo state changes to a "done" state (including repeating tasks),
the changes listed in `CURRENCY_DELTAS` are applied to the global variable
org-gamify-inventory. Currency changes can be overridden or generated
dynamically for any task by adding functions to the hook variable
`org-gamify-delta-functions`; if all of the functions in this variable return
nil then the value of `CURRENCY_DELTAS` is used.

Exactly once per day, every function listed in the hook variable
`org-gamify-daily-update-functions` is run for every active task in the agenda.
This provides a way to provide daily rewards or punishments based on whether
habits are being maintained, how many tasks are left undone, and so on.

## Installation and setup ##

Download `org-gamify.el` and save it somewhere. Add the path to `org-gamify.el`
to your `load-path`.

    (add-to-list 'load-path "/path/to/org-gamify.el")

In your emacs init file, define one or more currencies using
`define-gamify-currency`. The simplest setup would be just a single currency
("money" or "gold" or "points"), which increases when you complete tasks and
which you spend on rewards. It should have a minimum allowed value of 0 and an
enforcement style of `block`.

Assign `CURRENCY_DELTAS` properties for the tasks in your agenda. I find this
system works well with habits (org-habit), so add some habit tasks if you have
not already done so.

Now create "reward" tasks - these are things you enjoy, which will incur a
currency *cost* when you complete them. They should be represented as repeating
"TODO" items that are hidden from your normal agenda views somehow - for
example by scheduling them far in the future, or defining a new todo state
called "REWARD" which is filtered out of agenda views.

You will want to create a custom agenda view to show you a list of
available rewards.

## Usage ##

Use agenda mode as normal, but as you mark each task done, you will see a
message (or messages) telling you when your currency balances have changed.

When you want to spend currency on a reward, go to your "rewards" agenda view
and mark a reward item "done".

Use `M-x org-gamify-show-inventory` to list all currency balances.

## Example setup ##

Load `org-gamify` in your emacs init file.

    (add-to-list 'load-path "/path/to/org-gamify.el")

Define some currencies. Here, we define two currencies, "gold" and "karma".
Both are limited to non-negative values. Both will be earned by completing
tasks. We will allow gold to be spent on rewards, while karma cannot be spent
so it only ever increases. The category property allows currencies to be
grouped according to their category when displaying the inventory. The
`define-game-currency` macro has several other optional arguments &#x2013; see the
documentation string for details.

    (define-gamify-currency gold
             :name "gold"
             :category "Money"
             :min 0 :enforce-min block)

    (define-gamify-currency karma
      :name "karma"
      :category "Experience"
      :min 0 :enforce-min truncate)

Define currency awards for tasks. The following task awards 4 gold and 2 karma
when completed.

    ** TODO Finish first draft of chapter one
       :PROPERTIES:
       :CURRENCY_DELTAS: ((gold +4) (karma +2))
       :END:

Create some "reward" tasks which cost currency. If the reward can be used more
than once then it should be set up as a repeating task. Putting the scheduled
date far in the future helps to ensure that it does not show up in any normal
agenda views.

**Note:** You will need make Org mode recognise "REWARD" as an active todo state,
e.g. by adding it to `org-todo-keywords`.

    ** REWARD Watch a movie on Netflix
       SCHEDULED: <2030-01-01 12:00 .+1h>
       :PROPERTIES:
       :CURRENCY_DELTAS: ((gold -5))
       :END:

Define an agenda custom view to show rewards.

    (push '("r" "Rewards"
            todo "REWARD"
            ((org-agenda-time-grid nil)
             (org-agenda-dim-blocked-tasks 'invisible)
             (org-agenda-todo-ignore-scheduled nil)
             (org-agenda-todo-ignore-deadlines nil)
             ))
          org-agenda-custom-commands)

## Designing reward systems ##

-   **Extrinsic rewards:** Allow the user to "purchase" real life rewards that
    exist outside the game system, such as entertainment, restaurant meals,
    snacks, fancy coffee, alcoholic beverages, luxury purchases, etc.
-   **Sense of progress or achievement:** As the person engages with the system
    over time they steadily accumulate some resource that reflects their
    investment in the system (experience, levels, "badges" for achievements).
-   **Random rewards:** Experiments in operant conditioning (the "Skinner box")
    have shown that the most effective reward schedule is to
    dole out rewards unpredictably. The gameplay of many
    videogames and gambling games is based around this fact.
    This could be implemented either as giving a reward less
    than 100% of the time when a task is completed, or as
    occasionally giving a special, more valuable reward (a
    "rare drop") instead of the default reward.
-   **Self-expression and creativity:** Reward the user with a resource that does
    not confer an in-game advantage but that can be used creatively in some
    way, for example virtual clothing or armour that the person can use to
    dress their avatar in an online game.
-   **Competition:** the person may enjoy feeling that they have earned rewards
    faster or more efficiently than other human competitors, or
    may they simply enjoy the idea of showing off their
    achievements to other admiring users.
-   **Music and sound effects:** There is a reason that chimes and trumpets sound
    when you successfully perform a task or reach a goal in a videogame or
    slot machine. Pleasure is a reward, and pleasant sights and sounds produce
    pleasure.

## Ideas from games ##

Massively multiplayer online games, free-to-play mobile games, pen & paper
role-playing games, and complex board and card games are all fertile sources of
ideas for gamification. All are replete with currency systems that overlap and
interact, to motivate, reward and punish players.

### Experience and levels ###

Have a currency called "experience" or "XP". It increases whenever you complete
a task. Have another currency called "level". When XP exceeds a certain value,
level gets incremented automatically, and XP resets.

### Reward for maintaining habits ###

Define a "daily update" function that checks how many days a habit task has
been maintained for. If this is more than a threshold number, then
automatically give a small currency reward for maintaining the habit without a
break.

Alternatively, when a habit task is marked as done, it could check how many
days it has been maintained, and the reward for completing the task could
increase as the number of days increases.

### Bad habits ###

You could include "bad habit" tasks. These incur costs when you mark them done.
There could be rewards linked to the number of days you go without indulging in
a bad habit.

### Random rewards ###

Whenever you get a reward, there could be a small chance that you will get a
much better reward instead, such as increased amount of currency or a
different, rare type of currency, or a temporary buff (see below). This could
be more likely if the task is "hard" or has subtasks, or if you have completed
a large number of tasks that day.

### Buffs ###

A "buff" is a temporary character enhancement, usually conveyed by a magic
spell.

You could implement a buff as a currency which expires (resets to zero) after a
certain number of days (or tasks). Buffs could be purchasable or could "drop"
as rare rewards.

Ideas for "buffs" include "double currency rewards" or "double experience" or
"immunity from punishments".

### Spells and abilities ###

"Spells" or "special abilities" could be set up as repeatable todo items which
have a cost in one currency ("mana", gold etc) and either a gain in another
currency (such as a buff), or some other special effect.

You might need to learn the spell before you are allowed to "cast" it. Learning
could come via random drops, or automatically on levelling up.

### Currency conversion ###

Repeatable todo items that allow conversion of a set amount of one currency
into another.

### Hit points ###

You may wish to have a "hit points" or "health" resource which is decremented
when you fail to keep up with habits or when tasks get very overdue. You could
define spells which allow you to heal yourself. Your maximum hit points could
increase when you level up. You would need to define what the consequences are
for your hit points reaching zero -- maybe you lose levels and buffs, or forget
spells.