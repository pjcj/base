# Perl coding guidelines

## Rules

- Use [perlcritic](https://metacpan.org/dist/Perl-Critic/view/bin/perlcritic)
  - If `.perlcriticrc` exists
- Use [perltidy](https://metacpan.org/dist/Perl-Tidy/view/bin/perltidy)
  - If `.perltidy` exists
- Beyond that follow these rules, which one day may get codified into
  perlcritic and/or perltidy
  - Don't use empty parens on method calls: `$self->x` instead of `$self->x()`
  - Don't postfix dereference on simple variables: `@$var` instead of
    `@{$var}` or `$var->@*`
  - Do use postfix dereference otherwise: `$sub->()->@*` instead of
    `@{$sub->()}`
  - Don't use extraneous arrows: `$x->{a}{b}` instead of `$x->{a}->{b}`
  - Don't use unnecessary `scalar` keywords: `$count = @x` instead of
    `$count = scalar @x`
  - Use heredocs in preference to multi-line strings: `$x = <<~EOT;`
    - Use `<<~EOT` rather than `<<EOT` to remove leading whitespace
    - Prefer `<<~EOT` to `<<~'EOT'` in accordance with the quotng rules below
  - Use double quotes in preference to single: `"string"` instead of `'string'`
    - But use single quotes where that makes sense, eg for email addresses, or
      when there are already double quotes in the string
  - Use quotes in preference to `q` or `qq`: `"string"` instead of `qq{string}`
    - But use `q` or `qq` where that makes sense, eg where the string contains
      quotes
    - Try to use `qq()`, `qq[]`, `qq{}` or `qq<>` in order of preference
    - Use bracketing operators and not something like `qq//`
  - When using `qw` include a space after the opening delimiter and before the
    closing delimiter: `qw( a b c )` instead of `qw(a b c)`
  - Don't use unnecessary quotes in hash keys: `$x{a}` instead of `$x{'a'}` and
    `$x = { a => 1 }` instead of `$x = { 'a' => 1 }`
  - If you need to escape characters in a regexp because they match your
    delimiter consider changing the delimiter, ideally to `|`, otherwise to `!`
  - Use list map and grep on simple expressions:
    `@valid = grep defined, @values` instead of
    `@valid = grep { defined } @values`
  - Use signatures
  - Use postfix conditions for single statements where the meaning is clear
  - Don't use parentheses in postfix expressions unless they are needed for
    precedence: `$x++ if $y` instead of `$x++ if ($y)`
  - Use high precedence logical operators for conditions: `if ($x && $y)`
    instead of `if ($x and $y)`
    - This is even more important in postfix expressions: `do_stuff if $x && $y`
      instead of `do_stuff if $x and $y`
  - Use low precedence logical operators for flow control: `$x > 5 or next`
    instead of `$x > 5 || next`
  - Don't use else with unless
  - Try not to use negative expressions within unless conditions:
    `if ($x =~ /x/)` instead of `unless ($x !~ /x/)`
  - Use `for` instead of `foreach`: they are synonyms
  - Don't use spacer comments: `#----------------------------` and similar
  - To check whether an array has any elements use `@x` rather than
    `scalar @x` or `@x > 0`
  - If a subroutine returns values at its end, return them without an explicit
    `return` or trailing semicolon
  - For conditionals with a single statement prefer a postfix conditional
  - Use ternary `?:` instead of `if () {} else {}` for single statements
  - Prefer hashrefs and arrayrefs to hashes and arrays for data structures
- Strive for less punctuation rather than more so the important code can stand
  out

## Development

- All code must be tested
  - New code requires a test in the `t/` directory
  - The test must use the new `Test2` system, not `Test::More`
  - Tests should be run using `yath`, not `prove`
    - Unless instructed to the contrary, run with:

      ```bash
      yath test -j20 --no-color -v -T --term-width=200
      ```

    - Add the test to run if you only want to run a single test
  - Verify that code is tested by using Devel::Cover with the `json` report
- All code is required to pass all linting checks.  This includes:
  - `perlcritic`
  - `perlimports`
  - `pre-commit run --all-files`
  - LSP messages from the editor or ide
- You may not turn off any linting rules.  Ever.
  - You may suggest doing so, but never do it without explicit permission.
- All code must be formatted with `perltidy`
- Lines of code should not be longer than 80 characters
  - The only exception to this is for tables which cannot reasonably be
  shortened
- The rules are not optional
