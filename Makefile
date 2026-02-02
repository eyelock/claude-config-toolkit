.PHONY: help install validate clean test serve

# Default target
help:
	@echo "LLMC Claude Code Configuration - Available Targets"
	@echo ""
	@echo "Setup:"
	@echo "  make install    - Install LLMC to ~/.claude/ for development (symlinks)"
	@echo ""
	@echo "Development:"
	@echo "  make validate   - Validate frontmatter in all session and plan files"
	@echo "  make test       - Run all validation and checks"
	@echo "  make clean      - Archive old session files, clean up workspace"
	@echo "  make serve      - Start docsify server for browsing docs (port 3000)"
	@echo ""
	@echo "Development workflow:"
	@echo "  1. make install     (first time only - symlink to ~/.claude/)"
	@echo "  2. Restart Claude Code"
	@echo "  3. Create artifacts in commands/, skills/, agents/, rules/"
	@echo "  4. make validate    (check frontmatter)"
	@echo "  5. make test        (run all checks)"
	@echo "  6. git add/commit   (commit changes)"
	@echo ""
	@echo "Documentation:"
	@echo "  make serve          (browse docs at http://localhost:3000)"

install:
	@echo "🛠️  LLMC Developer Install"
	@echo ""
	@echo "This creates symlinks to ~/.claude/ so /llmc-* commands work everywhere."
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Checking existing configuration at ~/.claude/..."
	@echo ""
	@FOUND_ISSUES=0; \
	for artifact in commands/llmc-*.md skills/llmc-* agents/llmc-*.md rules/llmc-*.md; do \
		if [ ! -e "$$artifact" ]; then continue; fi; \
		BASENAME=$$(basename "$$artifact" .md); \
		TYPE=$$(echo "$$artifact" | cut -d/ -f1); \
		if [ -d "$$artifact" ]; then \
			BASENAME=$$(basename "$$artifact"); \
		fi; \
		TARGET="$$HOME/.claude/$$TYPE/$$BASENAME"; \
		if [ -L "$$TARGET" ]; then \
			LINK_TARGET=$$(readlink "$$TARGET"); \
			EXPECTED="$(CURDIR)/$$artifact"; \
			if [ "$$LINK_TARGET" = "$$EXPECTED" ]; then \
				echo "  ✓ $$TYPE/$$BASENAME → Already linked"; \
			else \
				echo "  ⚠️  $$TYPE/$$BASENAME → Will be updated"; \
			fi; \
		elif [ -e "$$TARGET" ]; then \
			echo "  ❌ $$TYPE/$$BASENAME → Exists (not a symlink)"; \
			FOUND_ISSUES=1; \
		else \
			echo "  ➕ $$TYPE/$$BASENAME → Will be created"; \
		fi; \
	done; \
	echo ""; \
	if [ $$FOUND_ISSUES -eq 1 ]; then \
		echo "⚠️  Found blocking issues. Move/remove conflicting files first."; \
		exit 1; \
	fi
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@read -p "Proceed with install? (y/n): " confirm && [ "$$confirm" = "y" ] || exit 0
	@echo ""
	@echo "🛠️  Installing to user level..."
	@mkdir -p ~/.claude/skills ~/.claude/commands ~/.claude/agents ~/.claude/rules
	@# Remove old namespace symlinks if they exist
	@[ -L ~/.claude/skills/llmc ] && rm ~/.claude/skills/llmc || true
	@[ -L ~/.claude/commands/llmc ] && rm ~/.claude/commands/llmc || true
	@[ -L ~/.claude/agents/llmc ] && rm ~/.claude/agents/llmc || true
	@[ -L ~/.claude/rules/llmc ] && rm ~/.claude/rules/llmc || true
	@# Create individual symlinks for each artifact
	@for cmd in commands/llmc-*.md; do \
		[ -f "$$cmd" ] || continue; \
		name=$$(basename "$$cmd"); \
		[ -L ~/.claude/commands/$$name ] && rm ~/.claude/commands/$$name || true; \
		ln -s "$(CURDIR)/$$cmd" ~/.claude/commands/$$name; \
		echo "  ✓ Linked commands/$$name"; \
	done
	@for skill in skills/llmc-*/; do \
		[ -d "$$skill" ] || continue; \
		name=$$(basename "$$skill"); \
		[ -L ~/.claude/skills/$$name ] && rm ~/.claude/skills/$$name || true; \
		ln -s "$(CURDIR)/$$skill" ~/.claude/skills/$$name; \
		echo "  ✓ Linked skills/$$name"; \
	done
	@for agent in agents/llmc-*.md; do \
		[ -f "$$agent" ] || continue; \
		name=$$(basename "$$agent"); \
		[ -L ~/.claude/agents/$$name ] && rm ~/.claude/agents/$$name || true; \
		ln -s "$(CURDIR)/$$agent" ~/.claude/agents/$$name; \
		echo "  ✓ Linked agents/$$name"; \
	done
	@for rule in rules/llmc-*.md; do \
		[ -f "$$rule" ] || continue; \
		name=$$(basename "$$rule"); \
		[ -L ~/.claude/rules/$$name ] && rm ~/.claude/rules/$$name || true; \
		ln -s "$(CURDIR)/$$rule" ~/.claude/rules/$$name; \
		echo "  ✓ Linked rules/$$name"; \
	done
	@echo ""
	@echo "✅ Installed to ~/.claude/"
	@echo ""
	@echo "Restart Claude Code to see /llmc-* commands and skills"

validate:
	@echo "Validating frontmatter in session and plan files..."
	@if [ -f skills/llmc/validate/validate-frontmatter.sh ]; then \
		bash skills/llmc/validate/validate-frontmatter.sh; \
	else \
		echo "⚠️  Validation script not found at skills/llmc/validate/validate-frontmatter.sh"; \
		echo "Checking for required frontmatter fields manually..."; \
		for file in sessions/*.md plans/*.md; do \
			if [ -f "$$file" ] && [ "$$(basename $$file)" != "README.md" ] && [ "$$(basename $$file)" != "TEMPLATE.md" ]; then \
				echo "Checking $$file..."; \
				if ! grep -q "^---" "$$file"; then \
					echo "  ❌ Missing frontmatter"; \
				else \
					echo "  ✅ Has frontmatter"; \
				fi; \
			fi; \
		done; \
	fi

clean:
	@echo "Cleaning up workspace..."
	@echo "Archiving old session files (>7 days old)..."
	@if [ -f commands/llmc/archive.md ]; then \
		echo "Running /llmc/archive..."; \
		echo "⚠️  Manual cleanup needed - run '/llmc/archive' in Claude Code"; \
	else \
		echo "Moving old session files to archive..."; \
		mkdir -p sessions/archive/$$(date +%Y-%m); \
		find sessions -name "*.md" -type f -mtime +7 \
			-not -name "README.md" -not -name "TEMPLATE.md" \
			-exec mv {} sessions/archive/$$(date +%Y-%m)/ \; 2>/dev/null || true; \
	fi
	@echo "✅ Cleanup complete"

test: validate
	@echo "Running all checks..."
	@echo ""
	@echo "1. Checking LLMC artifacts (optional)..."
	@test -d commands/llmc && echo "  ✅ commands/llmc exists" || echo "  ℹ️  commands/llmc not present (optional)"
	@test -d skills/llmc && echo "  ✅ skills/llmc exists" || echo "  ℹ️  skills/llmc not present (optional)"
	@test -d agents/llmc && echo "  ✅ agents/llmc exists" || echo "  ℹ️  agents/llmc not present (optional)"
	@test -d rules/llmc && echo "  ✅ rules/llmc exists" || echo "  ℹ️  rules/llmc not present (optional)"
	@echo ""
	@echo "2. Checking workspace structure (required)..."
	@test -d sessions && echo "  ✅ sessions exists" || echo "  ❌ sessions missing"
	@test -d plans && echo "  ✅ plans exists" || echo "  ❌ plans missing"
	@echo ""
	@echo "3. Checking key files (required)..."
	@test -f README.md && echo "  ✅ README.md exists" || echo "  ❌ README.md missing"
	@test -f Makefile && echo "  ✅ Makefile exists" || echo "  ❌ Makefile missing"
	@test -f .gitignore && echo "  ✅ .gitignore exists" || echo "  ❌ .gitignore missing"
	@echo ""
	@echo "4. Checking for common issues..."
	@if [ -d commands ] || [ -d skills ] || [ -d agents ] || [ -d rules ]; then \
		! find commands skills agents rules -name "*.md" -type f -size 0 2>/dev/null | grep -q . && \
			echo "  ✅ No empty files" || \
			(echo "  ⚠️  Found empty files:" && find commands skills agents rules -name "*.md" -type f -size 0); \
	else \
		echo "  ℹ️  No artifact directories to check"; \
	fi
	@echo ""
	@echo "5. Validating skill name fields match directories..."
	@if [ -d skills ]; then \
		SKILL_ERRORS=0; \
		for skill_file in $$(find skills -name "SKILL.md" -type f); do \
			skill_dir=$$(basename $$(dirname "$$skill_file")); \
			skill_name=$$(grep "^name:" "$$skill_file" | head -1 | sed 's/name: *//'); \
			if [ "$$skill_dir" != "$$skill_name" ]; then \
				echo "  ❌ $$skill_file: name '$$skill_name' ≠ directory '$$skill_dir'"; \
				SKILL_ERRORS=$$((SKILL_ERRORS + 1)); \
			fi; \
		done; \
		if [ $$SKILL_ERRORS -eq 0 ]; then \
			echo "  ✅ All skill names match their directories"; \
		else \
			echo ""; \
			echo "  ⚠️  Found $$SKILL_ERRORS skill name mismatch(es)"; \
			echo "  Per agentskills.io spec: name field must match parent directory"; \
			exit 1; \
		fi; \
	else \
		echo "  ℹ️  No skills directory to check"; \
	fi
	@echo ""
	@echo "✅ All checks complete"

serve:
	@echo "Starting docsify server..."
	@if command -v docsify >/dev/null 2>&1; then \
		echo "📚 Documentation server starting at http://localhost:3000"; \
		docsify serve .; \
	elif command -v npx >/dev/null 2>&1; then \
		echo "📚 Documentation server starting at http://localhost:3000"; \
		npx docsify-cli serve .; \
	else \
		echo "❌ docsify not found. Install with:"; \
		echo "   npm install -g docsify-cli"; \
		echo "   or use: npx docsify-cli serve ."; \
		exit 1; \
	fi
