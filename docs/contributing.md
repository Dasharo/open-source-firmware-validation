# Contributing

## Code

* Install pre-commit hooks after cloning repository:

```bash
pre-commit install
```

## Issues

If you are certain that the issue is related to this repository, create issue
directly
[here](https://github.com/Dasharo/open-source-firmware-validation/issues/new/choose).
Otherwise, create an issue in
[dasharo-issues repisotory](https://github.com/Dasharo/dasharo-issues/issues/new/choose).

# Guidelines

A list of guidelines we shall follow during transition to improve the quality
of this repository. We start with getting rid of duplicated keywords, reducing
the size of `keywords.robot` file, and improving their overall quality.

There are other areas of interest that we will look into in the next steps
and add as guidelines:
* variables (use Python/YAML, not robot syntax),
* platform-configs (get rid of duplication, and unused data),
* separate test for different OS into different suites,
* prepare the OS for running test suite via some dedicated tools (e.g. Ansible),
  rather than implementing keywords for that from scratch,
* reduce the number of unnecessary power events, so tests can finish quicker,
* improve overall code quality by enabling back more
  [robocop checks we cannot pass right now](https://github.com/Dasharo/open-source-firmware-validation/blob/main/robocop.toml),
* To Be Continued.

## Pre-commit and CI checks

1. Make sure to use `pre-commit` locally. All pre-commit and other CI checks
   must pass of course, prior requesting for review. Please check the status of
   checks in your PR. If the failure is questionable, provide your arguments
   for that, rather than silently ignoring this fact.

## Code style

1. It is automatically handled by
  [robotidy](https://robotidy.readthedocs.io/en/stable/). The current rules
  can be found
  [here](https://github.com/Dasharo/open-source-firmware-validation/blob/main/.robotidy).

## Keywords

1. No new keywords in `keywords.robot` will be accepted
* new keywords must be placed in a logically divided modules, under `lib/`
      directory
    - see
        [openbmc-test-automation](https://github.com/openbmc/openbmc-test-automation/tree/master/lib)
      as a reference
* if you need to modify something in `keywords.robot`, you should create a new
      module under `lib/`
* if you add new keyword module, you should review the `keywords.module` and
      move related keywords there as well, if suitable
1. If keyword from keywords.robot can be reused or improved, do that instead
   of creating a new one
   - keyword duplication will not be accepted,
   - you will be asked to use/improve existing keywords instead.
1. You are encouraged to use Python for more sophisticaed or complex keywords
   (e.g. more convoluted data parsing and processing). We are not forced to use
   RF for all keywords. Especially when it is simply easier to use Python.
1. For reading from terminal (no matter if it is Telnet, or SSH),
   following keywords must be used:
   - `Read From Terminal Until Prompt`
   - `Read From Terminal Until`
   - `Read From Terminal`
   Usage of other keywords is prohibited. Whenever you modify a test/keyword,
   you should rework it to use one of the above.
1. For writing into terminal, following keywords must be used:
   - `Execute Command In Terminal`
   - `Write Into Terminal`
   - `Write Bare Into Terminal`
   Usage of other keywords is prohibited. Whenever you modify a test/keyword,
   you should rework it to use one of the above.
   You should use `Execute Command In Terminal` unless you have a very good
   reason not to. Thanks to that, your keyword will not leave floating output
   in buffer to be received by another keywords, not expecting that.

## Documentation

* Each new (or modified) file, test, keyword, must have a `[Documentation]`
  section.
