#!/bin/bash

# Script to create a new release using git-cliff
# Usage: ./{{script_name}}.sh

set -e

# Проверяем наличие git-cliff
if ! command -v git-cliff &> /dev/null; then
    echo "❌ Error: git-cliff is not installed"
    echo ""
    echo "📋 git-cliff is required for automatic version bumping and changelog generation."
    echo "🔗 Install it from: https://github.com/orhun/git-cliff"
    echo ""
    echo "Installation options:"
    echo "  • Cargo: cargo install git-cliff"
    echo "  • Homebrew: brew install git-cliff"
    echo "  • Download binary: https://github.com/orhun/git-cliff/releases"
    echo ""
    exit 1
fi

# Определяем корневую директорию git репозитория
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Переходим в корневую директорию репозитория
cd "$GIT_ROOT"

# Определяем конфигурационный файл git-cliff (опционально)
CLIFF_CONFIG=""
if [ -f "cliff.toml" ]; then
    CLIFF_CONFIG="--config cliff.toml"
    echo "📋 Using cliff.toml configuration"
else
    echo "📋 Using git-cliff default configuration"
fi

# Приветствие для завершения скрипта
FAREWELL_MESSAGE="
🙏 {{farewell_message}}
💻 Created with ❤️ by @egortabula
⭐ If this script helped you, consider giving it a star on GitHub!
🔗 GitHub: https://github.com/egortabula/egortabula_scripts"

echo "🚀 Bump Release Script"
echo "====================="

# 1. Проверяем что мы в {{default_branch}} ветке
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "{{default_branch}}" ]; then
    echo "❌ Error: You must be on the {{default_branch}} branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi
echo "✅ On {{default_branch}} branch"

# 2. Проверяем что все закоммичено
if ! git diff-index --quiet HEAD --; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi
echo "✅ All changes committed"

# 3. Получаем текущий тег
CURRENT_TAG=$(git tag --list "v*" | sort -V | tail -n1)
if [ -z "$CURRENT_TAG" ]; then
    echo "❌ Error: No previous releases found"
    echo "💡 Create your first release manually with: git tag v0.1.0 && git push origin v0.1.0"
    echo "💡 Then run this script to create subsequent releases"
    exit 1
else
    CURRENT_VERSION=$(echo $CURRENT_TAG | sed 's/^v//')
    echo "📦 Current version: $CURRENT_VERSION"
fi

# 4. Определяем следующую версию через git-cliff
echo ""
echo "🔍 Analyzing changes since last release..."

# Создаем временный файл для git-cliff output
TEMP_OUTPUT=$(mktemp)

if git-cliff $CLIFF_CONFIG --bumped-version > "$TEMP_OUTPUT" 2>&1; then
    NEXT_VERSION=$(cat "$TEMP_OUTPUT")
    
    # Проверяем есть ли предупреждение о том, что нечего бампать
    if grep -q "There is nothing to bump" "$TEMP_OUTPUT"; then
        echo "❌ No changes requiring version bump found"
        echo "Current version $CURRENT_VERSION is already up to date"
        rm "$TEMP_OUTPUT"
        exit 1
    fi
    
    rm "$TEMP_OUTPUT"
    
    # Убираем возможные префиксы и очищаем от пробелов
    NEXT_VERSION=$(echo "$NEXT_VERSION" | sed 's/^v//' | tr -d '\n\r' | xargs)
    
    # Дополнительная проверка что версия отличается от текущей
    if [ -z "$NEXT_VERSION" ] || [ "$NEXT_VERSION" = "$CURRENT_VERSION" ]; then
        echo "❌ No changes requiring version bump found"
        echo "Current version $CURRENT_VERSION is already up to date"
        exit 1
    fi
else
    echo "❌ Error running git-cliff:"
    cat "$TEMP_OUTPUT"
    rm "$TEMP_OUTPUT"
    exit 1
fi

NEW_TAG="v$NEXT_VERSION"

echo "🎯 Next version: $NEXT_VERSION"
echo "🏷️ New tag: $NEW_TAG"

# 5. Показываем изменения
echo ""
echo "📋 Changes since last release:"
git log $CURRENT_TAG..HEAD --oneline --pretty=format:"  - %s" 2>/dev/null || echo "  No changes found"

# 6. Спрашиваем создать ли тег
echo ""
read -p "❓ Create tag $NEW_TAG? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Tag creation cancelled"
    echo "$FAREWELL_MESSAGE"
    exit 0
fi

# 7. Создаем локальный тег
echo "🏷️ Creating local tag..."
git tag "$NEW_TAG"
echo "✅ Local tag $NEW_TAG created"

# 8. Спрашиваем запушить ли тег
echo ""
read -p "❓ Push tag $NEW_TAG to remote? This will trigger CI/CD pipeline! (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⏸️ Tag created locally but not pushed"
    echo "💡 To push later: git push origin $NEW_TAG"
    echo "💡 To delete local tag: git tag -d $NEW_TAG"
    echo "$FAREWELL_MESSAGE"
    exit 0
fi

# 9. Пушим тег
echo "📤 Pushing tag to remote..."
git push origin "$NEW_TAG"

echo ""
echo "✅ Release $NEW_TAG created and pushed successfully!"
echo "🔗 CI/CD Pipeline will start automatically"
echo "🌐 Check progress: https://github.com/$(git remote get-url origin | sed 's/.*github\.com[:/]\([^.]*\)\.git/\1/')/actions"
echo "$FAREWELL_MESSAGE"
