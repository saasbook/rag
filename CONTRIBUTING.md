Development Process
------------------

Our default working branch is `master`.  We do work by creating branches off `master` for new features and bugfixes.  Each developer will usually work with a [fork of the main repository](https://help.github.com/articles/fork-a-repo/)

Before starting work on a new feature or bugfix, please ensure you have [synced your fork to upstream/master](https://help.github.com/articles/syncing-a-fork/):

```
git pull upstream/master
```

Note that you should be re-syncing daily (even hourly at very active times) on your feature/bugfix branch to ensure that you are always building on top of very latest develop code.

We use [Waffle](https://waffle.io/saasbook/rag) to manage our work on features and bugfixes, and it helps if feature/bug-fix branches start with the id of the relevant github issue, e.g.

```
git checkout -b 72_add_contribution_docs
```

Whatever you are working on, or however far you get please open a "Work in Progress" (WIP) [pull request](https://help.github.com/articles/creating-a-pull-request/) so that others in the team can comment on your approach.  Even if you hate your horrible code :-) please throw it up there and we'll help guide your code to fit in with the rest of the project.

When you make your pull request please add the following somewhere in your pull request title or description:

```
closes #72
```

which will associate the pull request with the relevant GitHub issue, and then close the issue when the pull request is merged.

For more details on Waffle work flow see:

https://github.com/waffleio/waffle.io/wiki/FAQs

