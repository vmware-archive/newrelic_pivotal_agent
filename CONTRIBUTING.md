_Have something you’d like to contribute to the test of the manager? We welcome pull requests, but ask that you carefully read this document first to understand how best to submit them; what kind of changes are likely to be accepted; and what to expect from the Pivotal team when evaluating your submission._

_Please refer back to this document as a checklist before issuing any pull request; this will save time for everyone!_

## Understanding the basics
Not sure what a pull request is, or how to submit one?  Take a look at GitHub's excellent [help documentation][] first.

[help documentation]: http://help.github.com/send-pull-requests

## Search GitHub Issues first; create an issue if necessary
Is there already an issue that addresses your concern?  Do a bit of searching in our [GitHub issue tracker][] to see if you can find something similar. If not, please create a new issue before submitting a pull request unless the change is truly trivial, e.g. typo fixes, removing compiler warnings, etc.

[GitHub issue tracker]: https://github.com/pivotalsoftware/newrelic_pivotal_agent/issues

## Discuss non-trivial contribution ideas with committers
If you're considering anything more than correcting a typo or fixing a minor bug, please discuss it in a GitHub issue before submitting a pull request. We're happy to provide guidance, but please spend an hour or two researching the subject on your own including searching the mailing list for prior discussions.

## Sign the Contributor License Agreement
Please open an issue in the [GitHub issue tracker][] if you have any questions regarding the CLA.

Please print, sign, scan, and email per the instructions in the document appropriate for you

 * [Generic Corporate Contributor License Agreement.docx](https://github.com/pivotalsoftware/newrelic_pivotal_agent/blob/master/docs/Generic%20Corporate%20Contributor%20License%20Agreement.docx?raw=true)
 * [Generic Individual Contributor License Agreement.docx](https://github.com/pivotalsoftware/newrelic_pivotal_agent/blob/master/docs/Generic%20Individual%20Contributor%20License%20Agreement.docx?raw=true)

## Use short branch names
Branches used when submitting pull requests should preferably using succinct, lower-case, dash (-) delimited names, such as 'fix-warnings', 'fix-typo', etc. In [fork-and-edit][] cases, the GitHub default 'patch-1' is fine as well. This is important, because branch names show up in the merge commits that result from accepting pull requests, and should be as expressive and concise as possible.

[fork-and-edit]: https://github.com/blog/844-forking-with-the-edit-button

## Mind the whitespace
Please carefully follow the whitespace and formatting conventions already present in the code.

1. Space, not tabs
1. Unix (LF), not DOS (CRLF) line endings
1. Eliminate all trailing whitespace
1. Aim to wrap code at 120 characters, but favor readability over wrapping
1. Preserve existing formatting; i.e. do not reformat code for its own sake
1. Search the codebase using `git grep` and other tools to discover common naming conventions, etc.
1. Latin-1 (ISO-8859-1) encoding for sources; use `native2ascii` to convert if necessary

## Add MIT license header to all new files
```ruby
# The MIT License
# 
# Copyright (c) 2014 the original author or authors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require ...;
```
## Update Apache license header to modified files as necessary
Always check the date range in the license header. For example, if you've modified a file in 2014 whose header still reads

```ruby
# Copyright 2013 the original author or authors.
```

then be sure to update it to 2014 appropriately

```ruby
# Copyright 2013-2014 the original author or authors.
```

## Squash commits
Use `git rebase --interactive`, `git add --patch` and other tools to "squash" multiple commits into atomic changes. In addition to the man pages for git, there are many resources online to help you understand how these tools work. Here is one: <http://git-scm.com/book/en/Git-Tools-Rewriting-History>.

## Use real name in git commits
Please configure git to use your real first and last name for any commits you intend to submit as pull requests. For example, this is not acceptable:

```plain
Author: Nickname <user@mail.com>
```

Rather, please include your first and last name, properly capitalized, as submitted against the Pivotal contributor license agreement:

```plain
Author: First Last <user@mail.com>
```

This helps ensure traceability against the CLA, and also goes a long way to ensuring useful output from tools like `git shortlog` and others.

You can configure this globally via the account admin area GitHub (useful for fork-and-edit cases); globally with

```bash
git config --global user.name "First Last"
git config --global user.email user@mail.com
```

or locally for the `redis-manager-system-test` repository only by omitting the `--global` flag:

```bash
cd redis-manager-system-test
git config user.name "First Last"
git config user.email user@mail.com
```

## Format commit messages
Please read and follow the [commit guidelines section of Pro Git][].

Most importantly, please format your commit messages in the following way (adapted from the commit template in the link above):

```plain
Short (50 chars or less) summary of changes

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body. The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Further paragraphs come after blank lines.

 - Bullet points are okay, too

 - Typically a hyphen or asterisk is used for the bullet, preceded by a
   single space, with blank lines in between, but conventions vary here

Issue: #10, #11
```

1. Use imperative statements in the subject line, e.g. "Fix broken RubyDoc link"
1. Begin the subject line sentence with a capitalized verb, e.g. "Add, Prune, Fix, Introduce, Avoid, etc."
1. Do not end the subject line with a period
1. Keep the subject line to 50 characters or less if possible
1. Wrap lines in the body at 72 characters or less
1. Mention associated GitHub issue(s) at the end of the commit comment, prefixed with "Issue: " as above
1. In the body of the commit message, explain how things worked before this commit, what has changed, and how things work now

[commit guidelines section of Pro Git]: http://git-scm.com/book/en/Distributed-Git-Contributing-to-a-Project#Commit-Guidelines

## Run all tests prior to submission
See the [Running Tests][] section of the README for instructions. Make sure that all tests pass prior to submitting your pull request.

[Running Tests]: README.md#running-tests

# Submit your pull request
Subject line:

Follow the same conventions for pull request subject lines as mentioned above for commit message subject lines.

In the body:

1. Explain your use case. What led you to submit this change? Why were existing mechanisms in the system test insufficient? Make a case that this is a general-purpose problem and that yours is a general-purpose solution, etc.
1. Add any additional information and ask questions; start a conversation, or continue one from GitHub issue
1. Also mention that you have submitted the CLA as described above

Note that for pull requests containing a single commit, GitHub will default the subject line and body of the pull request to match the subject line and body of the commit message. This is fine, but please also include the items above in the body of the request.

## Expect discussion and rework
The Pivotal team takes a very conservative approach to accepting contributions to the system test. This is to keep code quality and stability as high as possible, and to keep complexity at a minimum. Your changes, if accepted, may be heavily modified prior to merging. You will retain "Author:" attribution for your Git commits granted that the bulk of your changes remain intact. You may be asked to rework the submission for style (as explained above) and/or substance. Again, we strongly recommend discussing any serious submissions with the Pivotal team _prior_ to engaging in serious development work.

Note that you can always force push (`git push -f`) reworked / rebased commits against the branch used to submit your pull request. i.e. you do not need to issue a new pull request when asked to make changes.
