<details>
<summary>Шаг 1</summary>

```bash
# Создаем каталог и файлы
mkdir branching
cd branching

# Создаем merge.sh
cat > merge.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
for param in "$*"; do
    echo "\$* Parameter #$count = $param"
    count=$(( $count + 1 ))
done
EOF

# Создаем rebase.sh (такое же содержимое)
cp merge.sh rebase.sh

# Делаем файлы исполняемыми
chmod +x merge.sh rebase.sh

# Возвращаемся в корень репозитория
cd ..

# Добавляем и коммитим
git add branching/
git commit -m "prepare for merge and rebase"
git push
```

</details>

<details>
<summary>Шаг 2</summary>

```bash
# Создаем и переключаемся на ветку git-merge
git checkout -b git-merge

# Редактируем merge.sh (заменяем $* на $@)
cat > branching/merge.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "\$@ Parameter #$count = $param"
    count=$(( $count + 1 ))
done
EOF

# Коммитим
git add branching/merge.sh
git commit -m "merge: @ instead *"
git push -u origin git-merge

# Второе изменение merge.sh (версия с while/shift)
cat > branching/merge.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
while [[ -n "$1" ]]; do
    echo "Parameter #$count = $1"
    count=$(( $count + 1 ))
    shift
done
EOF

# Коммитим
git add branching/merge.sh
git commit -m "merge: use shift"
git push
```

</details>

<details>
<summary>Шаг 3</summary>

```bash
# Переключаемся на main
git checkout main

# Редактируем rebase.sh
cat > branching/rebase.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "\$@ Parameter #$count = $param"
    count=$(( $count + 1 ))
done

echo "====="
EOF

# Коммитим и пушим
git add branching/rebase.sh
git commit -m "update rebase.sh in main"
git push
```

</details>

<details>
<summary>Шаг 4</summary>

```bash
# Находим хеш коммита prepare for merge and rebase
git log --oneline | grep "prepare for merge and rebase"
# Копируем хеш (например: 8baf217)

# Переключаемся на этот коммит (ЗАМЕНИТЕ хеш на ваш)
git checkout 8baf217  # используйте ваш хеш

# Создаем ветку git-rebase
git checkout -b git-rebase

# Редактируем rebase.sh (первая версия)
cat > branching/rebase.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "Parameter: $param"
    count=$(( $count + 1 ))
done

echo "====="
EOF

# Коммитим
git add branching/rebase.sh
git commit -m "git-rebase 1"
git push -u origin git-rebase

# Второе изменение
cat > branching/rebase.sh << 'EOF'
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "Next parameter: $param"
    count=$(( $count + 1 ))
done

echo "====="
EOF

# Коммитим
git add branching/rebase.sh
git commit -m "git-rebase 2"
git push
```

</details>

<details>
<summary>Шаг 5</summary>

```bash
# Переключаемся на main
git checkout main

# Сливаем git-merge
git merge git-merge

# Если успешно, пушим
git push
```

</details>

<details>
<summary>Шаг 6</summary>

```bash
# Переключаемся на git-rebase
git checkout git-rebase

# Выполняем интерактивный rebase
git rebase -i main

# В открывшемся редакторе:
# - Первая строка: pick (оставляем)
# - Вторая строка: меняем pick на fixup
# - Сохраняем и закрываем

# Возникнет конфликт. Редактируем branching/rebase.sh:
# Удаляем строки с <<<<<<<, =======, >>>>>>>
# Оставляем: echo "\$@ Parameter #$count = $param"

# Добавляем и продолжаем
git add branching/rebase.sh
git rebase --continue

# Снова конфликт. Редактируем branching/rebase.sh:
# Оставляем: echo "Next parameter: $param"

# Добавляем и продолжаем
git add branching/rebase.sh
git rebase --continue

# В редакторе комментария - сохраняем (можно оставить по умолчанию)

# Пушим с принуждением
git push -u origin git-rebase -f
```

</details>

<details>
<summary>Шаг 7</summary>

```bash
# Переключаемся на main
git checkout main

# Сливаем git-rebase (будет fast-forward)
git merge git-rebase

# Пушим
git push
```

</details>

<details>
<summary>Проверка результата</summary>

```bash
# Просмотр графа коммитов
git log --graph --oneline --all
```

</details>