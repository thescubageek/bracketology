# NCAA Basketball Tournament Simulator

**Bracketology** simulates all the action of the NCAA Basketball Tournament and helps you build your brackets!

## How it works

Each game is simulated strictly using the rankings of the two teams in the matchup.

The simulation is based on a simple weighted coin flip. Each team is assigned the inverse ratio
of the other team's ranking, then a random number between 0.0 and 1.0 is determined using SecureRandom.
If the number lies within the home team's odds then the home team wins, otherwise the away team wins.

For example, if a team ranked #1 plays a team ranked #7 then the odds of home team winning are
(7.0 / 8.0) == 0.875 and the odds of away team winning are (1.0 / 8.0) == 0.125. If the random number
is <= 0.875 then home team wins. While this heavily favors highly ranked teams, it does introduce
some surprise upsets when the rankings are closer together, especially for middle-of-the-pack matchups.

## Setup

Bracketology requires Ruby > 2.5 and Ruby on Rails > 5.2.

The front end is locally started by running `rails s -p 3000` and runs under `http://localhost:3000`.

### Importing

The 2021 NCAA Tournament brackets matchups are stored in `brackets/import/ncaa_2021.json`. If you want to
use a different matchup file, add it to the `brackets/import` directory and then append the query parameter
`?file=<FILE_NAME>` to the URL.

### Exporting

Each time you view the front end it will generate a different simulation of the tournament. You can store
the results of the simulation in an export file into the `brackets/export` directory by appending
`?export=true` to the URL. Each simluation you run will then be exported into its own file.

### Averaging Results

You can get the overall average results of from a group of simulations by opening the Rails console `rails c`
and then running `Tournament.calculate_final_results`. This will take all of the files in the export
directory and find the most frequent winners of each bracket, then store the overall average results in
the `brackets/results` directory. Note that the more exported files you use then the closer the average
results will tend towards highly ranked teams dominating and fewer upsets. Using a smaller set of exports
will generate a high chance of upsets.

## Future Work

This is a quickly hacked together project for the 2021 NCAA Basketball Tournament. It will be expanded upon
in the years to come. There are still a number of unimplemented features.

### Testing

There are no tests yet. I know, I'm a bad developer. No cookie for me.

### Underdog Factor

Since the simulations heavily favor highly ranked teams, it would be nice to have a "Underdog Factor"
scalar that can be used to slant games more towards the underdogs, thereby introducing a greater chance
for upsets in the brackets.

### Seeded Results

I would like to have a hashed seed string that can be used to restore results to populate the brackets.
Since there are 2^68 total possible brackets (that's _295 quintillion!_) it'd be great to be able to
reproduce specific seeds. For now, the exported results files will have to do.
