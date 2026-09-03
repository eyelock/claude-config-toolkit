.PHONY: help install validate clean test test-scripts eval serve

# Default target
help:
	@echo "Claude Config Toolkit - Available Targets"
	@echo ""
	@echo "Setup:"
	@echo "  make install      - Install Toolkit to ~/.claude/ for development (symlinks)"
	@echo ""
	@echo "Development:"
	@echo "  make validate     - Validate frontmatter (sessions/plans) + artifact structure (free, deterministic)"
	@echo "  make test-scripts - Run bundled-script unit tests + eval grading-logic tests (free, deterministic)"
	@echo "  make test         - validate + test-scripts (what CI always runs)"
	@echo "  make eval         - Run LLM-in-the-loop skill/agent triggering + e2e evals (uses your normal local"
	@echo "                      Claude Code auth; CI instead gates this on an ANTHROPIC_API_KEY secret — see evals/README.md)"
	@echo "  make clean        - Archive old session files, clean up workspace"
	@echo "  make serve        - Start docsify server for browsing docs (port 3000)"
	@echo ""
	@echo "Development workflow:"
	@echo "  1. make install     (first time only - symlink to ~/.claude/)"
	@echo "  2. Restart Claude Code"
	@echo "  3. Create artifacts in commands/, skills/, agents/, rules/"
	@echo "  4. make test        (validate + free eval tiers)"
	@echo "  5. make eval        (optional — costs tokens, uses your local Claude Code auth)"
	@echo "  6. git add/commit   (commit changes)"
	@echo ""
	@echo "Documentation:"
	@echo "  make serve          (browse docs at http://localhost:3000)"
	@echo "  evals/README.md     (the three eval tiers explained)"

install:
	@echo "🛠️  Toolkit Developer Install"
	@echo ""
	@echo "This creates symlinks to ~/.claude/ so /toolkit-* commands work everywhere."
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Checking existing configuration at ~/.claude/..."
	@echo ""
	@FOUND_ISSUES=0; \
	for artifact in commands/toolkit-*.md skills/toolkit-* agents/toolkit-*.md rules/toolkit-*.md; do \
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
	@[ -L ~/.claude/skills/toolkit ] && rm ~/.claude/skills/toolkit || true
	@[ -L ~/.claude/commands/toolkit ] && rm ~/.claude/commands/toolkit || true
	@[ -L ~/.claude/agents/toolkit ] && rm ~/.claude/agents/toolkit || true
	@[ -L ~/.claude/rules/toolkit ] && rm ~/.claude/rules/toolkit || true
	@# Create individual symlinks for each artifact
	@for cmd in commands/toolkit-*.md; do \
		[ -f "$$cmd" ] || continue; \
		name=$$(basename "$$cmd"); \
		[ -L ~/.claude/commands/$$name ] && rm ~/.claude/commands/$$name || true; \
		ln -s "$(CURDIR)/$$cmd" ~/.claude/commands/$$name; \
		echo "  ✓ Linked commands/$$name"; \
	done
	@for skill in skills/toolkit-*/; do \
		[ -d "$$skill" ] || continue; \
		name=$$(basename "$$skill"); \
		[ -L ~/.claude/skills/$$name ] && rm ~/.claude/skills/$$name || true; \
		ln -s "$(CURDIR)/$$skill" ~/.claude/skills/$$name; \
		echo "  ✓ Linked skills/$$name"; \
	done
	@for agent in agents/toolkit-*.md; do \
		[ -f "$$agent" ] || continue; \
		name=$$(basename "$$agent"); \
		[ -L ~/.claude/agents/$$name ] && rm ~/.claude/agents/$$name || true; \
		ln -s "$(CURDIR)/$$agent" ~/.claude/agents/$$name; \
		echo "  ✓ Linked agents/$$name"; \
	done
	@for rule in rules/toolkit-*.md; do \
		[ -f "$$rule" ] || continue; \
		name=$$(basename "$$rule"); \
		[ -L ~/.claude/rules/$$name ] && rm ~/.claude/rules/$$name || true; \
		ln -s "$(CURDIR)/$$rule" ~/.claude/rules/$$name; \
		echo "  ✓ Linked rules/$$name"; \
	done
	@echo ""
	@echo "✅ Installed to ~/.claude/"
	@echo ""
	@echo "Restart Claude Code to see /toolkit-* commands and skills"

validate:
	@echo "Validating frontmatter in session and plan files..."
	@if [ -f skills/toolkit-validate/scripts/validate-frontmatter.sh ]; then \
		bash skills/toolkit-validate/scripts/validate-frontmatter.sh; \
	else \
		echo "⚠️  Validation script not found at skills/toolkit-validate/scripts/validate-frontmatter.sh"; \
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
	@echo ""
	@echo "Validating Toolkit artifacts (commands/, skills/, agents/, rules/)..."
	@bash skills/toolkit-validate/scripts/validate-artifacts.sh

clean:
	@echo "Cleaning up workspace..."
	@echo "Archiving old session files (>7 days old)..."
	@if [ -f commands/toolkit/archive.md ]; then \
		echo "Running /toolkit/archive..."; \
		echo "⚠️  Manual cleanup needed - run '/toolkit/archive' in Claude Code"; \
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
	@echo "1. Checking Toolkit artifacts (optional)..."
	@test -d commands/toolkit && echo "  ✅ commands/toolkit exists" || echo "  ℹ️  commands/toolkit not present (optional)"
	@test -d skills/toolkit && echo "  ✅ skills/toolkit exists" || echo "  ℹ️  skills/toolkit not present (optional)"
	@test -d agents/toolkit && echo "  ✅ agents/toolkit exists" || echo "  ℹ️  agents/toolkit not present (optional)"
	@test -d rules/toolkit && echo "  ✅ rules/toolkit exists" || echo "  ℹ️  rules/toolkit not present (optional)"
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
	@echo "4. Artifact structure/frontmatter (empty files, skill name==dir, agent/command/rule frontmatter)..."
	@echo "   → covered by 'make validate' (skills/toolkit-validate/scripts/validate-artifacts.sh), already run above"
	@echo ""
	@echo "5. Script correctness (bundled *.sh scripts + eval grading logic, no LLM/network)..."
	@$(MAKE) test-scripts
	@echo ""
	@echo "✅ All checks complete"

test-scripts:
	@bash evals/scripts/run-all.sh

eval:
	@bash evals/scenarios/lib/run-all.sh

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
