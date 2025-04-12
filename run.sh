#!/bin/bash

# Путь к корневой директории проекта
PROJECT_DIR="$(pwd)/"

# Функция для отображения меню
show_menu() {
    clear
    echo "============================================"
    echo "              МЕНЮ ЗАДАНИЙ                 "
    echo "============================================"
    echo "1. Задание 2.28"
    echo "2. Задание 3.26"
    echo "3. Задание 4.2"
    echo "4. Задание 4.8"
    echo "5. Задание 5.1"
    echo "6. Задание 5.27"
    echo "7. Задание 6.5"
    echo "0. Выход"
    echo "============================================"
    echo -n "Выберите задание (0-7): "
}

# Функция для запуска задания
run_task() {
    local task_number=$1
    local task_dir=""
    local executable=""
    
    case $task_number in
        1)
            task_dir="$PROJECT_DIR/2.28"
            executable="./228"
            ;;
        2)
            task_dir="$PROJECT_DIR/3.26"
            executable="./326"
            ;;
        3)
            task_dir="$PROJECT_DIR/4.2"
            executable="./42"
            ;;
        4)
            task_dir="$PROJECT_DIR/4.8"
            executable="./48"
            ;;
        5)
            task_dir="$PROJECT_DIR/5.1"
            executable="./51"
            ;;
        6)
            task_dir="$PROJECT_DIR/5.27"
            executable="./527"
            ;;
        7)
            task_dir="$PROJECT_DIR/6.5"
            executable="./65"
            ;;
        *)
            echo "Неверный выбор!"
            return 1
            ;;
    esac
    
    # Проверка существования директории
    if [ ! -d "$task_dir" ]; then
        echo "Директория задания не существует: $task_dir"
        return 1
    fi
    
    # Переход в директорию задания
    cd "$task_dir" || return 1
    
    # Проверка наличия исполняемого файла
    if [ ! -x "${executable#./}" ]; then
        echo "Исполняемый файл не найден или не имеет прав на выполнение. Выполняется компиляция..."
        ./compile.sh
    fi
    
    # Запуск задания
    echo "Запуск задания..."
    $executable
    
    # Возврат в директорию проекта
    cd "$PROJECT_DIR" || return 1
    
    echo "Нажмите Enter для возврата в меню"
    read -r
}

# Сделать скрипт исполняемым
chmod +x "$0"

# Основной цикл программы
while true; do
    show_menu
    read -r choice
    
    if [ "$choice" == "0" ]; then
        clear
        echo "Выход из программы."
        exit 0
    elif [[ "$choice" =~ ^[1-7]$ ]]; then
        run_task "$choice"
    else
        echo "Неверный выбор! Нажмите Enter для продолжения."
        read -r
    fi
done
