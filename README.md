# Домашнее задание по дисциплине Базы данных
Репозиторий представляет собой набор SQL-скриптов для решения задач по работе с базами данных, выполненных с использованием PostgreSQL. Проект состоит из нескольких задач, связанных с созданием, наполнением и обработкой данных в базе данных. Этот репозиторий включает в себя скрипты для создания таблиц, наполнения данными и выполнения SQL-запросов для решения задач.
## Структура репозитория
В каждой директории своя часть задания.
* task.sql создает таблицы и наполняет их данными
* solutions.sql - решения задач
## Цели и задачи проекта
1. Создать структуру базы данных для хранения и обработки данных.
2. Наполнить базу данных тестовыми данными.
3. Реализовать SQL-запросы для решения задач, связанных с выборкой, фильтрацией и анализом данных.
4. Обеспечить правильность и работоспособность всех запросов.
## Запуск
```
cd part<1/2/3/4>
psql -h localhost -U postgres -f task.sql
psql -h localhost -U postgres -f solutions.sql
```
