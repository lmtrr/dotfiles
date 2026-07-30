<behavior>
- When exploring a project, check for existing build files at the project root FIRST before running any searches
- After finish writing code, you must spawn another sub-agent with the same level of intelligent as you to review the code changes, that subagent MUST only know the requirements and the expected outcomes without knowing how the implementation works
</behavior>

<code-writing>
- You MUST NOT add unnecessary comments to the codes, you only need to add comments when it's needed to
- You MUST ensure that the logic is clean, code is separate enough, use early return and minimize the nested conditions/nested loops
- You MUST write the code in the best way possible that reduce the cognitive load for the developres/reviewers
- You MUST minimize the "magic number"/"magic text" as using the constant/enums instead
- Unit test is a MUST to all the code you write.
- You MUST follow the best practices of each language you're working with, also following the rules for each language in the <language-specific> section
- You MUST NOT over-produce codes and tests. Make it concise, readable and maintainable
- You MUST prioritize using the mature/battle-tested libraries instead of re-writing everything
- You MUST prioritize deleting codes rather than producing codes, don't spam a lot of bloat codes
</code-writing>

<language-specific>
    <java>
        - You MUST always prioritize using the "final" keyword in Java for restricting unmodifiable variables/parameters
    </java>
</language-specific>

<bug-report>
- If there's a bug report, agent MUST NOT attempt to fix it directly, the mandatory workflow is analyze the bug report to understand expected vs. actual behavior -> writing a failing test that reproduces the bug, the test MUST fail, proving the bug exists before any fix is attempted -> delegate the fix to subagents, each subagent receives the failing test and MUST produce a patch that make it pass -> prove the fix, a bug fix is complete only when the reproduction test passes and no existing test regress
</bug-report>

<commit-rules>
- You MUST NOT auto commit or auto pushing to the remote origin unless I explicitly said so
- Commit MUST follow the conventional commit rules
- You MUST never use the emoji, em-dash or any symbol which will make the readers' read flow unnatural
- You MUST NOT add any signature that the commit is co-authored by anyone
- If the change won't effect the code behavior, always skip the CI in the commit for me 
</commit-rules>

<pull-request>
- If I say create a PR. You MUST create a PR using the gh tool, and if gh tool is unauthorized maybe because you're invoking it inside a sandbox
- If there exist pull request template in the repository, you MUST follow that template. Otherwise your PR MUST have the body which is summarization of what's changed in the current branch compare to the base branch
</pull-request>
