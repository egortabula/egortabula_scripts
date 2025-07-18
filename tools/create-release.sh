
#!/bin/bash

# Script to create a new release for a brick
# Usage: ./create-release.sh

set -e

# Список доступных bricks (легко добавлять новые)
AVAILABLE_BRICKS=(
    "flutter_coverage_updater"
    # Добавьте здесь новые bricks
)

# Приветствие для завершения скрипта
FAREWELL_MESSAGE="
� Thank you for using Mason Brick Release Script!
� Created with ❤️ by @egortabula
⭐ If this script helped you, consider giving it a star on GitHub!
🔗 GitHub: https://github.com/egortabula/egortabula_scripts"

echo "🚀 Mason Brick Release Script"
echo "=============================="

# 1. Проверяем что мы в main ветке
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Error: You must be on the main branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi
echo "✅ On main branch"

# 2. Проверяем что все закоммичено
if ! git diff-index --quiet HEAD --; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi
echo "✅ All changes committed"

# 3. Выбор brick'а
echo ""
echo "📦 Available bricks:"
for i in "${!AVAILABLE_BRICKS[@]}"; do
    echo "  $((i+1)). ${AVAILABLE_BRICKS[$i]}"
done

echo ""
read -p "Select brick (1-${#AVAILABLE_BRICKS[@]}): " brick_choice

# Валидация выбора
if ! [[ "$brick_choice" =~ ^[0-9]+$ ]] || [ "$brick_choice" -lt 1 ] || [ "$brick_choice" -gt "${#AVAILABLE_BRICKS[@]}" ]; then
    echo "❌ Invalid choice"
    exit 1
fi

BRICK_NAME="${AVAILABLE_BRICKS[$((brick_choice-1))]}"
echo "Selected brick: $BRICK_NAME"

# 4. Получаем текущий тег для brick'а
CURRENT_TAG=$(git tag --list "$BRICK_NAME-v*" | sort -V | tail -n1)
if [ -z "$CURRENT_TAG" ]; then
    echo "📦 No previous releases found for $BRICK_NAME"
    CURRENT_VERSION="0.0.0"
else
    CURRENT_VERSION=$(echo $CURRENT_TAG | sed "s/$BRICK_NAME-v//")
    echo "📦 Current version: $CURRENT_VERSION"
fi

# 5. Определяем следующую версию через git-cliff
echo ""
echo "🔍 Analyzing changes since last release..."

# Создаем временный файл для git-cliff output
TEMP_OUTPUT=$(mktemp)

if git-cliff --config cliff.toml --bumped-version --include-path "$BRICK_NAME/**" > "$TEMP_OUTPUT" 2>&1; then
    NEXT_VERSION=$(cat "$TEMP_OUTPUT")
    rm "$TEMP_OUTPUT"
    
    # Убираем возможные префиксы
    NEXT_VERSION=$(echo "$NEXT_VERSION" | sed 's/^v//' | tr -d '\n\r' | xargs)
    
    # Проверяем что версия не пустая и отличается от текущей
    if [ -z "$NEXT_VERSION" ] || [ "$NEXT_VERSION" = "$CURRENT_VERSION" ]; then
        echo "❌ No changes requiring version bump found for $BRICK_NAME"
        echo "Current version $CURRENT_VERSION is already up to date"
        rm -f "$TEMP_OUTPUT"
        exit 1
    fi
else
    echo "❌ Error running git-cliff:"
    cat "$TEMP_OUTPUT"
    rm "$TEMP_OUTPUT"
    exit 1
fi

NEW_TAG="$BRICK_NAME-v$NEXT_VERSION"

echo "🎯 Next version: $NEXT_VERSION"
echo "🏷️ New tag: $NEW_TAG"

# 6. Показываем изменения
echo ""
echo "📋 Changes since last release:"
if [ -n "$CURRENT_TAG" ]; then
    git log $CURRENT_TAG..HEAD --oneline --pretty=format:"  - %s" -- $BRICK_NAME/ 2>/dev/null || echo "  No specific changes in $BRICK_NAME/"
else
    echo "  First release for $BRICK_NAME"
fi

# 7. Спрашиваем создать ли тег
echo ""
read -p "❓ Create tag $NEW_TAG? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Tag creation cancelled"
    echo "$FAREWELL_MESSAGE"
    exit 0
fi

# 8. Создаем локальный тег
echo "🏷️ Creating local tag..."
git tag "$NEW_TAG"
echo "✅ Local tag $NEW_TAG created"

# 9. Спрашиваем запушить ли тег
echo ""
read -p "❓ Push tag $NEW_TAG to remote? This will trigger CD pipeline! (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⏸️ Tag created locally but not pushed"
    echo "💡 To push later: git push origin $NEW_TAG"
    echo "💡 To delete local tag: git tag -d $NEW_TAG"
    echo "$FAREWELL_MESSAGE"
    exit 0
fi

# 10. Пушим тег
echo "📤 Pushing tag to remote..."
git push origin "$NEW_TAG"

echo ""
echo "✅ Release $NEW_TAG created and pushed successfully!"
echo "🔗 CD Pipeline will start automatically"
echo "🌐 Check progress: https://github.com/$(git remote get-url origin | sed 's/.*github\.com[:/]\([^.]*\)\.git/\1/')/actions"
echo "$FAREWELL_MESSAGE"
