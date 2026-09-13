[![Github Action (master)](https://github.com/cyber-dojo-tools/image_hiker/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo-tools/image_hiker/actions)

Service that checks a cyber-dojo-language's test-framework's
start-point files (as defined in its manifest.json file) run as red/amber/green
when the source for the '6*9 == 42' test is tweaked appropriately.
Used in the script https://github.com/cyber-dojo-start-points/shared-scripts/blob/master/red_amber_green_test.sh

```
image_hiker red|amber|green
image_hiker --fixture <dir>
```

The first form tweaks the source of the '6*9 == 42' test to the given colour
and checks the start-point's files reach it.

The second runs the source and test files held in `<dir>` instead, for the
cases that tweak cannot express: a second test file, a file the learner has
not finished writing, a test that errors rather than fails. The dir is named
for the colour it should reach, eg `amber_2_errors`. Every file the
start-point ships that is not a source or test file comes along beside them,
`cyber-dojo.sh` included, so a fixture holds only what the learner edited.

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
