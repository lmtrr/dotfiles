# Global instructions

## Behavior

- When you explore a project, read the build files at the project root first (package.json, Cargo.toml, pom.xml, Makefile). They show the commands, the structure, and the tools, and they save searches.
- Write all text in ASD-STE100 Simplified Technical English: chat answers, commit messages, PR bodies, and code comments. Use short sentences, one idea per sentence, and common words.
- Do not commit or push unless I ask, or unless you are on an issue branch for a ticket assigned to you.

## Model routing

- Planning: use the `planner` agent.
- Implementation: use the `implementer` agent.
- Adversarial review: run `/codex:adversarial-review --model gpt-6-astra --effort medium`.
  - If that model is not available, retry once with `--model gpt-5.5`.
  - If Codex is not available or has no quota, use the `reviewer` agent.
  - Tell me which reviewer ran.
- If you are Codex: plan and review with Astra 6 Medium, and implement with Sol 6 Medium.

## Code writing

- Add a comment only when the code cannot show the reason, for example a workaround, a non-obvious rule, or a link to a ticket. Do not add comments that repeat the code.
- Use early returns. Keep nesting to two levels or less where possible.
- Give each function one job. If you need "and" to describe it, split it.
- Use named constants or enums for numbers and strings that have a meaning.
- Use a mature, well-tested library when one exists. Do not write again what a library already does.
- Write only the code that the task needs. Do not add features, options, or abstractions for possible future needs.
- Follow the language rules below and the repo CLAUDE.md.

### Java

- Use `final` for fields, parameters, and local variables that do not change.

## Testing

- Test each public behavior that you add or change, and each bug fix.
- Do not test private helpers, trivial getters, or behavior that a library already tests.
- One test per behavior. Put edge cases in the same test only if they check the same rule.

## Verification

- Before you say that a task is done, run the tests, lint, and type check for the parts you changed. Show the result.
- If a check fails, say so and show the output. Do not report that a task is done when a check fails.
- If you cannot run a check, say which check did not run and why.

## Bug reports

When I report a bug, use this order. Do not start with the fix.

1. Analyze the report. Write down the expected behavior and the actual behavior.
2. Write a test that reproduces the bug. Run it and show that it fails.
   - If a unit test cannot reproduce the bug (UI layout, timing, platform-specific), write manual reproduction steps and ask me before you continue.
3. Give the failing test to one `implementer` agent to fix. If the first fix does not work, or if the bug has more than one possible cause, use more agents in parallel and compare their fixes.
   - For a trivial fix (one or two lines, the cause is clear), you can write the fix yourself after step 2.
4. The fix is complete only when the new test passes and all existing tests still pass.

## Commits

- Use Conventional Commits: `type(scope): summary`.
- Do not use emoji, em-dashes, or decorative symbols. They make the text hard to read.
- Do not add a co-author line or any AI signature.

## Pull requests

- If a ticket is assigned to you, name the worktree and the branch `feature/{TICKET_ID}-{short-summary}`.
  - `short-summary` is lowercase kebab-case and has a maximum of 8 words.
  - Example: ticket BDR-33 "Device-authorization login flow for onboarding" gives `feature/BDR-33-device-login-auth`.
- Create the PR with `gh`.
- The PR title uses Conventional Commit format and includes the ticket id, for example `BDR-100: fix agent reject unoffered option ids`.
- The PR body summarizes what changed on the branch compared to the base branch, and what you did to verify it.
