#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 10;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

my $got;
my $expected;
my $testname;

$testname = "Two untracked files"; #{:
`
cd $workdir &&
git init &&
echo a > one.txt &&
echo b > two.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#1	one.txt
#2	two.txt
nothing added to commit but untracked files present (use "git add" to track)
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Added first file"; #{:
`
cd $workdir &&
git add one.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   one.txt
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#2	two.txt
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Added second file"; #{:
`
cd $workdir &&
git add two.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   one.txt
#2	new file:   two.txt
#
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Status with deleted file"; #{:
`
cd $workdir &&
rm -f two.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   one.txt
#2	new file:   two.txt
#
# Changes not staged for commit:
#   (use "git add/rm <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#3	deleted:    two.txt
#
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Status after commit and reset --hard"; #{:
`
cd $workdir &&
git commit -m 'initial commit' &&
git reset --hard
`;

# This is the price you pay when scripting against porcelain:
my $expected_regex = qr/# On branch master
nothing to commit,? \(?working directory clean\)?
/;
# In git 1.7, it was    "nothing to commit (working directory clean)"
# In git 1.8, it became "nothing to commit, working directory clean"
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected_regex, $testname); #:}

$testname = "git-number status foo.txt"; #{:
`
cd $workdir &&
echo foo > foo.txt
`;
$expected = <<EOT;
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#1	foo.txt
nothing added to commit but untracked files present (use "git add" to track)
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-number status 1"; #{:
$expected = <<EOT;
git status foo.txt
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	foo.txt
nothing added to commit but untracked files present (use "git add" to track)
EOT
$got = `cd $workdir; $srcdir/git-number --color=never status 1`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-number -c ls 1"; #{:
`cd $workdir; $srcdir/git-number`;
$expected = <<EOT;
ls foo.txt
foo.txt
EOT
$got = `cd $workdir; $srcdir/git-number -c ls 1`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-number -c ...' in different dir than 'git-number' was invoked in"; #{:
`cd $workdir; echo "Needle" > needle.txt; mkdir foo; cd foo; $srcdir/git-number`;
$expected = <<EOT;
cat needle.txt
Needle
EOT
$got = `cd $workdir; $srcdir/git-number -c cat 2`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-number -c echo' must run echo"; #{:
$expected = <<EOT;

EOT
$got=`git-number -c echo`;
eq_or_diff($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
