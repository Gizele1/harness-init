# Skill Authoring

## Rule
SKILL.md is an index that orchestrates phases — keep it concise, delegate details to references.

## DO

```markdown
<!-- Good: SKILL.md points to reference for details -->
4. **Phase 3 — Architecture boundary test**
   - `Read references/boundary-test-template.md` for test skeletons
   - `Read references/stack-routing.md` for import parser per stack
```

## DON'T

```markdown
<!-- Bad: SKILL.md inlines the entire test template -->
4. **Phase 3 — Architecture boundary test**
   Here is the full Jest test skeleton:
   [200 lines of code pasted directly in SKILL.md]
```

## DO

```markdown
<!-- Good: Each reference is standalone -->
# Boundary Test Template          (references/boundary-test-template.md)
# Stack Routing                   (references/stack-routing.md)
<!-- Each file is self-contained, no cross-references -->
```

## DON'T

```markdown
<!-- Bad: Reference files depend on each other -->
# Boundary Test Template
See references/stack-routing.md for the import parser...
<!-- Creates fragile coupling between reference files -->
```

## Exceptions
- SKILL.md frontmatter (name, description, triggers) must be inline — it's plugin metadata
- Short inline examples (under 10 lines) in SKILL.md are acceptable for illustration
